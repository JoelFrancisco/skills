#!/usr/bin/env bash
# goal-supervisor: supervision tree (one_for_one) for /goal.
#
# Layers:
#   launchd/systemd/tmux    <- keeps THIS script alive (optional, see SKILL.md)
#     supervise.sh          <- restart policy + backoff + stall detection
#       claude -p /goal ... <- worker (session pinned via --session-id)
#         subagents         <- survive on their own; the worker re-adopts them via transcript
#
# Resume state, in order of preference:
#   1. session transcript (claude -p --resume $SID) — full context
#   2. goals/<slug>/.supervisor/checkpoint.md — handoff written by the goal itself
#      (same mechanism as the claude-handoff skill), used if resume fails
#
# Usage:
#   supervise.sh <goal.md> [options] [-- extra args for claude]
#     --max-restarts N   restarts allowed within the window (default 10)
#     --window S         restart-policy window, in seconds (default 3600)
#     --stall S          seconds without transcript activity => kill and restart
#                        (default 1800; 0 disables)
#     --fresh            ignore the previous session and start over (keeps checkpoint)
#
# The goal finishes when the worker creates .supervisor/DONE (instructed via prompt).

set -uo pipefail

GOAL_MD=""
MAX_RESTARTS=10
WINDOW=3600
STALL_TIMEOUT=1800
FRESH=0
CLAUDE_EXTRA=()

while [ $# -gt 0 ]; do
  case "$1" in
    --max-restarts) MAX_RESTARTS="$2"; shift 2 ;;
    --window)       WINDOW="$2"; shift 2 ;;
    --stall)        STALL_TIMEOUT="$2"; shift 2 ;;
    --fresh)        FRESH=1; shift ;;
    --)             shift; CLAUDE_EXTRA=("$@"); break ;;
    -*)             echo "unknown option: $1" >&2; exit 2 ;;
    *)              GOAL_MD="$1"; shift ;;
  esac
done

[ -n "$GOAL_MD" ] && [ -f "$GOAL_MD" ] || { echo "usage: supervise.sh <goal.md> [options] [-- claude args]" >&2; exit 2; }

GOAL_MD="$(cd "$(dirname "$GOAL_MD")" && pwd)/$(basename "$GOAL_MD")"
GOAL_DIR="$(dirname "$GOAL_MD")"
SUP_DIR="$GOAL_DIR/.supervisor"
mkdir -p "$SUP_DIR"
SID_FILE="$SUP_DIR/session-id"
DONE_FILE="$SUP_DIR/DONE"
CHECKPOINT="$SUP_DIR/checkpoint.md"
SUP_LOG="$SUP_DIR/supervisor.log"
WORKER_LOG="$SUP_DIR/worker.log"

[ "$FRESH" = 1 ] && rm -f "$SID_FILE" "$DONE_FILE"

log() { printf '%s [supervisor] %s\n' "$(date '+%F %T')" "$*" | tee -a "$SUP_LOG" >&2; }

notify() {
  if command -v osascript >/dev/null 2>&1; then
    osascript -e "display notification \"$1\" with title \"goal-supervisor\"" 2>/dev/null
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send "goal-supervisor" "$1" 2>/dev/null
  fi
  true
}

# Portable mtime: GNU stat uses -c %Y, BSD/macOS uses -f %m
if stat -c %Y / >/dev/null 2>&1; then
  mtime() { stat -c %Y "$1" 2>/dev/null || echo 0; }
else
  mtime() { stat -f %m "$1" 2>/dev/null || echo 0; }
fi

new_uuid() {
  { command -v uuidgen >/dev/null 2>&1 && uuidgen; } \
    || cat /proc/sys/kernel/random/uuid 2>/dev/null \
    || python3 -c 'import uuid; print(uuid.uuid4())'
}

# Transcript lives at ~/.claude/projects/<cwd with / and . replaced by ->/<sid>.jsonl
transcript_path() {
  local proj="${PWD//[\/.]/-}"
  echo "$HOME/.claude/projects/$proj/$1.jsonl"
}

WPID=""
cleanup() {
  log "supervisor shutting down; killing worker ${WPID:-<none>}"
  [ -n "$WPID" ] && kill -TERM "$WPID" 2>/dev/null
  exit 130
}
trap cleanup INT TERM

SUPERVISOR_BRIEF="Supervisor instructions: you are running under a supervisor that restarts the process if it dies or hangs.
1. After EACH completed step of the plan, update $CHECKPOINT with a short handoff: what has been done, what remains, the next step, and relevant file paths. Overwrite the file, do not accumulate.
2. When the goal's done condition is met and verified, create the file $DONE_FILE (free-form content, e.g. a summary of the result) — that is how the supervisor knows to stop.
3. Do not ask for interactive confirmations; if you get blocked on something only the human can resolve, write the blocker to $CHECKPOINT and create $SUP_DIR/BLOCKED, then exit."

RESTART_STAMPS=()
attempt=0

while [ ! -f "$DONE_FILE" ]; do
  if [ -f "$SUP_DIR/BLOCKED" ]; then
    log "worker signaled BLOCKED; stopping supervision (see $CHECKPOINT)"
    notify "Goal blocked: needs human input"
    exit 3
  fi

  # Restart intensity policy (Erlang-style max_restarts/max_seconds)
  now=$(date +%s)
  PRUNED=()
  for t in ${RESTART_STAMPS[@]+"${RESTART_STAMPS[@]}"}; do
    [ $((now - t)) -lt "$WINDOW" ] && PRUNED+=("$t")
  done
  RESTART_STAMPS=(${PRUNED[@]+"${PRUNED[@]}"})
  if [ "${#RESTART_STAMPS[@]}" -ge "$MAX_RESTARTS" ]; then
    log "limit of $MAX_RESTARTS restarts within ${WINDOW}s reached; giving up"
    notify "Goal supervisor gave up after $MAX_RESTARTS restarts"
    exit 1
  fi
  RESTART_STAMPS+=("$now")

  if [ -s "$SID_FILE" ]; then
    SID=$(cat "$SID_FILE")
    attempt=$((attempt + 1))
    PROMPT="The process running this goal died and the supervisor restarted it (attempt $attempt). Pick up where it left off: re-read $GOAL_MD, the goal's plan, and the checkpoint at $CHECKPOINT (if it exists); check in the repository what is actually already done before redoing anything; then continue execution.

$SUPERVISOR_BRIEF"
    log "resuming session $SID (attempt $attempt)"
    claude -p --resume "$SID" ${CLAUDE_EXTRA[@]+"${CLAUDE_EXTRA[@]}"} "$PROMPT" >>"$WORKER_LOG" 2>&1 &
    WPID=$!
  else
    SID=$(new_uuid | tr '[:upper:]' '[:lower:]')
    echo "$SID" >"$SID_FILE"
    PROMPT="/goal $GOAL_MD

$SUPERVISOR_BRIEF"
    log "starting goal in new session $SID"
    claude -p --session-id "$SID" ${CLAUDE_EXTRA[@]+"${CLAUDE_EXTRA[@]}"} "$PROMPT" >>"$WORKER_LOG" 2>&1 &
    WPID=$!
  fi

  # Monitor: wait for the worker with stall detection via transcript mtime
  TRANSCRIPT=$(transcript_path "$SID")
  while kill -0 "$WPID" 2>/dev/null; do
    sleep 30
    [ -f "$DONE_FILE" ] && break
    if [ "$STALL_TIMEOUT" -gt 0 ]; then
      last=$(mtime "$TRANSCRIPT")
      lw=$(mtime "$WORKER_LOG")
      [ "$lw" -gt "$last" ] && last=$lw
      if [ "$last" -gt 0 ] && [ $(($(date +%s) - last)) -gt "$STALL_TIMEOUT" ]; then
        log "worker $WPID inactive for more than ${STALL_TIMEOUT}s; killing to restart"
        kill -TERM "$WPID" 2>/dev/null
        sleep 15
        kill -KILL "$WPID" 2>/dev/null
      fi
    fi
  done
  wait "$WPID" 2>/dev/null
  rc=$?
  WPID=""

  if [ -f "$DONE_FILE" ]; then
    log "goal done (DONE present); exiting"
    notify "Goal done: $(basename "$GOAL_DIR")"
    exit 0
  fi

  # If resume failed with no transcript on disk (corrupted?), fall back to the
  # handoff mechanism: a fresh session seeded from the checkpoint.
  if [ "$rc" -ne 0 ] && [ -s "$SID_FILE" ] && [ ! -s "$(transcript_path "$(cat "$SID_FILE")")" ]; then
    log "session transcript unreachable; discarding session and using checkpoint as handoff"
    rm -f "$SID_FILE"
  fi

  backoff=$((5 * (2 ** (attempt < 6 ? attempt : 6))))
  [ "$backoff" -gt 300 ] && backoff=300
  log "worker exited rc=$rc without DONE; next restart in ${backoff}s"
  sleep "$backoff"
done

log "goal done"
exit 0
