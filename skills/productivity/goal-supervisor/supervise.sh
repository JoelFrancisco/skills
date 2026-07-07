#!/usr/bin/env bash
# goal-supervisor: one_for_one supervisor for /goal (see SKILL.md for the tree).
#
# Runs `claude -p "/goal <goal.md>"` pinned to a session UUID; if the worker
# dies without creating .supervisor/DONE, relaunches with `claude -p --resume`.
# If the session becomes unresumable, falls back to a fresh session seeded
# from .supervisor/checkpoint.md (handoff written by the goal itself).
#
# Usage:
#   supervise.sh <goal.md> [options] [-- extra args for claude]
#     --max-restarts N   restarts allowed within the window (default 10)
#     --window S         restart-policy window, in seconds (default 3600)
#     --stall S          seconds without transcript activity => kill and restart
#                        (default 3600; 0 disables; inactive while the session
#                        transcript file is not found)
#     --fresh            ignore the previous session and start over (keeps checkpoint)
#
# Exit semantics: intentional stops exit 0 — goal done (.supervisor/DONE),
# blocked on a human (.supervisor/BLOCKED), or gave up on restart intensity
# (.supervisor/GAVE_UP). Check those sentinel files for the outcome. Non-zero
# means the supervisor itself malfunctioned, so a root supervisor (launchd
# KeepAlive {SuccessfulExit: false} / systemd Restart=on-failure) restarts it
# only on real crashes.

set -uo pipefail

GOAL_MD=""
MAX_RESTARTS=10
WINDOW=3600
STALL_TIMEOUT=3600
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
mkdir -p "$SUP_DIR" || { echo "cannot create $SUP_DIR" >&2; exit 1; }
SID_FILE="$SUP_DIR/session-id"
DONE_FILE="$SUP_DIR/DONE"
BLOCKED_FILE="$SUP_DIR/BLOCKED"
GAVE_UP_FILE="$SUP_DIR/GAVE_UP"
CHECKPOINT="$SUP_DIR/checkpoint.md"
SUP_LOG="$SUP_DIR/supervisor.log"
WORKER_LOG="$SUP_DIR/worker.log"

[ "$FRESH" = 1 ] && rm -f "$SID_FILE" "$DONE_FILE" "$BLOCKED_FILE" "$GAVE_UP_FILE"

log() { printf '%s [supervisor] %s\n' "$(date '+%F %T')" "$*" | tee -a "$SUP_LOG" >&2; }

notify() {
  local msg="${1//\\/}"; msg="${msg//\"/}"
  if command -v osascript >/dev/null 2>&1; then
    osascript -e "display notification \"$msg\" with title \"goal-supervisor\"" 2>/dev/null
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send "goal-supervisor" "$msg" 2>/dev/null
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
  log "supervisor shutting down; terminating worker ${WPID:-<none>}"
  if [ -n "$WPID" ]; then
    kill -TERM "$WPID" 2>/dev/null
    for _ in 1 2 3 4 5; do kill -0 "$WPID" 2>/dev/null || break; sleep 2; done
    kill -KILL "$WPID" 2>/dev/null
  fi
  exit 130
}
trap cleanup INT TERM

SUPERVISOR_BRIEF="Supervisor instructions: you are running under a supervisor that restarts the process if it dies or hangs.
1. After EACH completed step of the plan, update $CHECKPOINT with a short handoff: what has been done, what remains, the next step, and relevant file paths. Overwrite the file, do not accumulate.
2. When the goal's done condition is met and verified, create the file $DONE_FILE (free-form content, e.g. a summary of the result) — that is how the supervisor knows to stop.
3. Do not ask for interactive confirmations; if you get blocked on something only the human can resolve, write the blocker to $CHECKPOINT and create $BLOCKED_FILE, then exit."

RESTART_STAMPS=()
started_once=0   # the initial launch is a start, not a restart
attempt=0        # resumes of the current session
fails=0          # consecutive short-lived exits, drives backoff
fastfails=0      # consecutive short-lived non-zero exits, drives session fallback

while [ ! -f "$DONE_FILE" ]; do
  if [ -f "$BLOCKED_FILE" ]; then
    log "worker signaled BLOCKED; stopping supervision (see $CHECKPOINT)"
    notify "Goal blocked: needs human input"
    exit 0
  fi
  if [ -f "$GAVE_UP_FILE" ]; then
    log "a previous run gave up (GAVE_UP present); not restarting — remove it or pass --fresh to retry"
    exit 0
  fi

  # Restart intensity policy (Erlang-style max_restarts/max_seconds);
  # counts restarts only, never the initial launch.
  if [ "$started_once" = 1 ]; then
    now=$(date +%s)
    PRUNED=()
    for t in ${RESTART_STAMPS[@]+"${RESTART_STAMPS[@]}"}; do
      [ $((now - t)) -lt "$WINDOW" ] && PRUNED+=("$t")
    done
    RESTART_STAMPS=(${PRUNED[@]+"${PRUNED[@]}"})
    if [ "${#RESTART_STAMPS[@]}" -ge "$MAX_RESTARTS" ]; then
      log "limit of $MAX_RESTARTS restarts within ${WINDOW}s reached; giving up"
      date '+%F %T' >"$GAVE_UP_FILE" || { log "cannot write $GAVE_UP_FILE"; exit 1; }
      notify "Goal supervisor gave up after $MAX_RESTARTS restarts"
      exit 0
    fi
    RESTART_STAMPS+=("$now")
  fi
  started_once=1

  if [ -s "$SID_FILE" ]; then
    SID=$(cat "$SID_FILE")
    attempt=$((attempt + 1))
    PROMPT="The process running this goal died and the supervisor restarted it (attempt $attempt). Pick up where it left off: re-read $GOAL_MD, the goal's plan, and the checkpoint at $CHECKPOINT (if it exists); check in the repository what is actually already done before redoing anything; then continue execution.

$SUPERVISOR_BRIEF"
    log "resuming session $SID (attempt $attempt)"
    LAUNCHED_AT=$(date +%s)
    claude -p --resume "$SID" ${CLAUDE_EXTRA[@]+"${CLAUDE_EXTRA[@]}"} "$PROMPT" >>"$WORKER_LOG" 2>&1 &
    WPID=$!
  else
    SID=$(new_uuid | tr '[:upper:]' '[:lower:]')
    echo "$SID" >"$SID_FILE" || { log "cannot write $SID_FILE"; exit 1; }
    attempt=0
    CHECKPOINT_HINT=""
    [ -s "$CHECKPOINT" ] && CHECKPOINT_HINT="A previous attempt at this goal left a handoff at $CHECKPOINT — read it first, check in the repository what is actually already done, and continue from there instead of starting over.

"
    PROMPT="/goal $GOAL_MD

$CHECKPOINT_HINT$SUPERVISOR_BRIEF"
    log "starting goal in new session $SID"
    LAUNCHED_AT=$(date +%s)
    claude -p --session-id "$SID" ${CLAUDE_EXTRA[@]+"${CLAUDE_EXTRA[@]}"} "$PROMPT" >>"$WORKER_LOG" 2>&1 &
    WPID=$!
  fi

  # Monitor: wait for the worker, with stall detection via transcript mtime.
  # Only the transcript is a heartbeat — under `claude -p`, worker.log stays
  # silent mid-run. While the transcript file is absent, stall detection is
  # inactive (a wrong path must not kill a healthy worker).
  TRANSCRIPT=$(transcript_path "$SID")
  stall_warned=0
  while kill -0 "$WPID" 2>/dev/null; do
    sleep 30
    if [ -f "$DONE_FILE" ]; then
      # done signaled; give the worker a grace period to exit on its own,
      # then terminate it so wait() below cannot block forever
      sleep 30
      if kill -0 "$WPID" 2>/dev/null; then
        log "DONE present but worker still running; terminating it"
        kill -TERM "$WPID" 2>/dev/null
        sleep 10
        kill -KILL "$WPID" 2>/dev/null
      fi
      break
    fi
    if [ "$STALL_TIMEOUT" -gt 0 ]; then
      last=$(mtime "$TRANSCRIPT")
      if [ "$last" -eq 0 ]; then
        if [ "$stall_warned" = 0 ] && [ $(($(date +%s) - LAUNCHED_AT)) -gt 120 ]; then
          log "transcript not found at $TRANSCRIPT; stall detection inactive for this run"
          stall_warned=1
        fi
      elif [ $(($(date +%s) - last)) -gt "$STALL_TIMEOUT" ]; then
        log "worker $WPID: no transcript activity for more than ${STALL_TIMEOUT}s; killing to restart"
        kill -TERM "$WPID" 2>/dev/null
        sleep 15
        kill -KILL "$WPID" 2>/dev/null
      fi
    fi
  done
  wait "$WPID" 2>/dev/null
  rc=$?
  WPID=""
  RAN_FOR=$(( $(date +%s) - LAUNCHED_AT ))

  if [ -f "$DONE_FILE" ]; then
    log "goal done (DONE present); exiting"
    notify "Goal done: $(basename "$GOAL_DIR")"
    exit 0
  fi
  # BLOCKED is handled at the top of the loop; skip the backoff on the way there
  [ -f "$BLOCKED_FILE" ] && continue

  # Session fallback: a session whose resume keeps failing fast (transcript
  # corrupt or incompatible — present or not) would burn the whole restart
  # budget. Discard it and seed a fresh session from the checkpoint handoff.
  if [ "$rc" -ne 0 ] && [ "$RAN_FOR" -lt 60 ]; then
    fastfails=$((fastfails + 1))
  else
    fastfails=0
  fi
  if [ -s "$SID_FILE" ]; then
    if [ ! -s "$TRANSCRIPT" ]; then
      log "session transcript unreachable; discarding session and falling back to checkpoint handoff"
      rm -f "$SID_FILE"; fastfails=0
    elif [ "$fastfails" -ge 3 ]; then
      log "3 consecutive fast failures resuming; discarding session and falling back to checkpoint handoff"
      rm -f "$SID_FILE"; fastfails=0
    fi
  fi

  # Backoff grows with consecutive short-lived exits; a worker that ran a
  # while before dying made progress, so it restarts quickly.
  if [ "$RAN_FOR" -lt 300 ]; then fails=$((fails + 1)); else fails=0; fi
  backoff=$((5 * (2 ** (fails < 6 ? fails : 6))))
  [ "$backoff" -gt 300 ] && backoff=300
  log "worker exited rc=$rc after ${RAN_FOR}s without DONE; next restart in ${backoff}s"
  sleep "$backoff"
done

log "goal done"
exit 0
