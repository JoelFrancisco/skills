#!/usr/bin/env bash
# goal-supervisor: supervision tree (one_for_one) para /goal.
#
# Camadas:
#   launchd/tmux            <- mantém ESTE script vivo (opcional, ver SKILL.md)
#     supervise.sh          <- política de restart + backoff + detecção de stall
#       claude -p /goal ... <- worker (sessão pinada por --session-id)
#         subagentes        <- já sobrevivem sozinhos; o worker os re-adota via transcript
#
# Estado de retomada, em ordem de preferência:
#   1. transcript da sessão (claude -p --resume $SID) — contexto completo
#   2. goals/<slug>/.supervisor/checkpoint.md — handoff escrito pelo próprio goal
#      (mesmo mecanismo da skill claude-handoff), usado se o resume falhar
#
# Uso:
#   supervise.sh <goal.md> [opções] [-- args extras para claude]
#     --max-restarts N   restarts permitidos dentro da janela (default 10)
#     --window S         janela da política de restart, em segundos (default 3600)
#     --stall S          segundos sem atividade no transcript => kill e restart
#                        (default 1800; 0 desliga)
#     --fresh            ignora sessão anterior e começa do zero (mantém checkpoint)
#
# O goal termina quando o worker cria .supervisor/DONE (instruído via prompt).

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
    -*)             echo "opção desconhecida: $1" >&2; exit 2 ;;
    *)              GOAL_MD="$1"; shift ;;
  esac
done

[ -n "$GOAL_MD" ] && [ -f "$GOAL_MD" ] || { echo "uso: supervise.sh <goal.md> [opções] [-- claude args]" >&2; exit 2; }

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
  command -v osascript >/dev/null 2>&1 && \
    osascript -e "display notification \"$1\" with title \"goal-supervisor\"" 2>/dev/null || true
}

# Transcript fica em ~/.claude/projects/<cwd com / e . trocados por ->/<sid>.jsonl
transcript_path() {
  local proj="${PWD//[\/.]/-}"
  echo "$HOME/.claude/projects/$proj/$1.jsonl"
}

WPID=""
cleanup() {
  log "supervisor encerrando; matando worker ${WPID:-<nenhum>}"
  [ -n "$WPID" ] && kill -TERM "$WPID" 2>/dev/null
  exit 130
}
trap cleanup INT TERM

SUPERVISOR_BRIEF="Instruções do supervisor: você roda sob um supervisor que reinicia o processo se ele morrer ou travar.
1. Após CADA etapa concluída do plano, atualize $CHECKPOINT com um handoff curto: o que já foi feito, o que falta, próximo passo, e caminhos de arquivos relevantes. Sobrescreva o arquivo, não acumule.
2. Quando a condição de done do goal for atingida e verificada, crie o arquivo $DONE_FILE (conteúdo livre, ex.: resumo do resultado) — é assim que o supervisor sabe parar.
3. Não peça confirmações interativas; se bloquear em algo que só o humano resolve, escreva o bloqueio em $CHECKPOINT e crie $SUP_DIR/BLOCKED, depois encerre."

RESTART_STAMPS=()
attempt=0

while [ ! -f "$DONE_FILE" ]; do
  if [ -f "$SUP_DIR/BLOCKED" ]; then
    log "worker sinalizou BLOCKED; parando supervisão (veja $CHECKPOINT)"
    notify "Goal bloqueado: precisa de input humano"
    exit 3
  fi

  # Política de intensidade de restart (estilo Erlang max_restarts/max_seconds)
  now=$(date +%s)
  PRUNED=()
  for t in ${RESTART_STAMPS[@]+"${RESTART_STAMPS[@]}"}; do
    [ $((now - t)) -lt "$WINDOW" ] && PRUNED+=("$t")
  done
  RESTART_STAMPS=(${PRUNED[@]+"${PRUNED[@]}"})
  if [ "${#RESTART_STAMPS[@]}" -ge "$MAX_RESTARTS" ]; then
    log "limite de $MAX_RESTARTS restarts em ${WINDOW}s atingido; desistindo"
    notify "Goal supervisor desistiu após $MAX_RESTARTS restarts"
    exit 1
  fi
  RESTART_STAMPS+=("$now")

  if [ -s "$SID_FILE" ]; then
    SID=$(cat "$SID_FILE")
    attempt=$((attempt + 1))
    PROMPT="O processo que executava este goal morreu e o supervisor o reiniciou (tentativa $attempt). Retome de onde parou: releia $GOAL_MD, o plano do goal e o checkpoint em $CHECKPOINT (se existir); confira no repositório o que já está concluído de fato antes de refazer qualquer coisa; então continue a execução.

$SUPERVISOR_BRIEF"
    log "retomando sessão $SID (tentativa $attempt)"
    claude -p --resume "$SID" ${CLAUDE_EXTRA[@]+"${CLAUDE_EXTRA[@]}"} "$PROMPT" >>"$WORKER_LOG" 2>&1 &
    WPID=$!
  else
    SID=$(uuidgen | tr '[:upper:]' '[:lower:]')
    echo "$SID" >"$SID_FILE"
    PROMPT="/goal $GOAL_MD

$SUPERVISOR_BRIEF"
    log "iniciando goal em sessão nova $SID"
    claude -p --session-id "$SID" ${CLAUDE_EXTRA[@]+"${CLAUDE_EXTRA[@]}"} "$PROMPT" >>"$WORKER_LOG" 2>&1 &
    WPID=$!
  fi

  # Monitor: espera o worker com detecção de stall via mtime do transcript
  TRANSCRIPT=$(transcript_path "$SID")
  while kill -0 "$WPID" 2>/dev/null; do
    sleep 30
    [ -f "$DONE_FILE" ] && break
    if [ "$STALL_TIMEOUT" -gt 0 ]; then
      last=$(stat -f %m "$TRANSCRIPT" 2>/dev/null || echo 0)
      lw=$(stat -f %m "$WORKER_LOG" 2>/dev/null || echo 0)
      [ "$lw" -gt "$last" ] && last=$lw
      if [ "$last" -gt 0 ] && [ $(($(date +%s) - last)) -gt "$STALL_TIMEOUT" ]; then
        log "worker $WPID sem atividade há mais de ${STALL_TIMEOUT}s; matando para reiniciar"
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
    log "goal concluído (DONE presente); encerrando"
    notify "Goal concluído: $(basename "$GOAL_DIR")"
    exit 0
  fi

  # Se o resume falhou imediatamente 2x seguidas (transcript corrompido?),
  # cai para o mecanismo de handoff: sessão nova semeada pelo checkpoint.
  if [ "$rc" -ne 0 ] && [ -s "$SID_FILE" ] && [ ! -s "$(transcript_path "$(cat "$SID_FILE")")" ]; then
    log "transcript da sessão inacessível; descartando sessão e usando checkpoint como handoff"
    rm -f "$SID_FILE"
  fi

  backoff=$((5 * (2 ** (attempt < 6 ? attempt : 6))))
  [ "$backoff" -gt 300 ] && backoff=300
  log "worker saiu rc=$rc sem DONE; novo restart em ${backoff}s"
  sleep "$backoff"
done

log "goal concluído"
exit 0
