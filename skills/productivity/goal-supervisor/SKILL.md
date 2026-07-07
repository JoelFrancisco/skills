---
name: goal-supervisor
description: Roda um goal (/goal) sob uma supervision tree — reinicia o processo do exato ponto onde parou se ele morrer ou travar, via claude -p --resume + checkpoint de handoff. Use para "supervisionar goal", "goal que não morre", "rodar goal com restart automático", "goal de longa duração em background".
argument-hint: "goals/<slug>/goal.md [-- args extras para claude, ex.: --permission-mode acceptEdits]"
disable-model-invocation: true
---

# Goal Supervisor

Quando o processo `claude` que orquestra um `/goal` morre, os subagentes
sobrevivem mas ninguém mais dirige o loop. O estado, porém, vive no transcript
da sessão — `claude -p --resume <session-id>` retoma com contexto completo.
Esta skill lança [supervise.sh](supervise.sh) (no mesmo diretório desta
SKILL.md — resolva o caminho absoluto a partir dela) para explorar isso numa
supervisão one_for_one:

```
launchd/tmux (opcional)      ← mantém o supervisor vivo
  └── supervise.sh           ← política de restart + backoff + stall detection
        └── claude -p /goal  ← worker, sessão pinada com --session-id
              └── subagentes ← sobrevivem sozinhos; o worker re-adota o estado
```

**Como retoma:** o supervisor escolhe o UUID da sessão (`uuidgen` +
`--session-id`). Se o worker morre sem criar `.supervisor/DONE`, religa com
`claude -p --resume <uuid>` — contexto completo preservado. O prompt inicial
instrui o goal a manter `.supervisor/checkpoint.md` (handoff curto, estilo
claude-handoff) após cada etapa; se o transcript se perder, uma sessão nova é
semeada por esse checkpoint.

## Invocação

1. Confirme que o argumento é um `goal.md` existente.
2. Pergunte-se se o goal vai precisar de permissões headless — em `-p` não há
   prompts interativos; sem `--permission-mode acceptEdits` (ou
   `bypassPermissions`, se o usuário pedir) o goal pode travar em negações.
   Repasse via `--`.
3. Lance em background, fora da árvore de processos da sessão atual:

```bash
nohup <caminho-desta-skill>/supervise.sh goals/<slug>/goal.md \
  -- --permission-mode acceptEdits >/dev/null 2>&1 &
```

4. Informe onde acompanhar:
   - `tail -f goals/<slug>/.supervisor/supervisor.log` — eventos do supervisor
   - `tail -f goals/<slug>/.supervisor/worker.log` — output do claude
   - `.supervisor/DONE` — goal concluído; `.supervisor/BLOCKED` — precisa de humano

## Opções do supervise.sh

- `--max-restarts N` / `--window S` — intensidade de restart (default 10/3600s); estourou, desiste e notifica.
- `--stall S` — sem atividade no transcript por S segundos → mata e reinicia (default 1800; 0 desliga).
- `--fresh` — descarta a sessão anterior e recomeça (mantém o checkpoint como memória).

## Supervisor do supervisor (raiz da árvore)

Para sobreviver a logout/reboot, rode o próprio supervise.sh sob o init do
sistema. A semântica desejada nas duas plataformas é a mesma: religar o
supervisor se ele morrer com erro, e PARAR de religar quando ele sai com 0
(goal concluído).

**macOS (launchd):** gere `~/Library/LaunchAgents/com.user.goal-<slug>.plist`
com `ProgramArguments` apontando para o supervise.sh + goal.md,
`WorkingDirectory` no repo, `RunAtLoad` e `KeepAlive: {SuccessfulExit: false}`,
e carregue com `launchctl load`.

**Linux (systemd user unit):** a forma rápida é transiente:

```bash
systemd-run --user --unit=goal-<slug> \
  --property=Restart=on-failure --property=RestartSec=30 \
  --working-directory=<repo> \
  <caminho-desta-skill>/supervise.sh goals/<slug>/goal.md -- --permission-mode acceptEdits
# acompanhar: journalctl --user -u goal-<slug> -f
```

Para sobreviver a logout, habilite linger: `loginctl enable-linger $USER`.
(Equivalente persistente: um `.service` em `~/.config/systemd/user/` com
`Restart=on-failure` + `WorkingDirectory` e `systemctl --user enable --now`.)

Alternativa simples nas duas plataformas: `tmux new -d -s goal-<slug> '...supervise.sh ...'`.
