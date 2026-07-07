---
name: goal-supervisor
description: Runs a goal (/goal) under a supervision tree — restarts the process from exactly where it stopped if it dies or hangs, via claude -p --resume plus a handoff checkpoint. Use for "supervise a goal", "goal that survives crashes", "run a goal with automatic restart", "long-running goal in the background".
argument-hint: "goals/<slug>/goal.md [-- extra args for claude, e.g. --permission-mode acceptEdits]"
disable-model-invocation: true
---

# Goal Supervisor

When the `claude` process orchestrating a `/goal` dies, its subagents survive
but nothing drives the loop anymore. The state, however, lives on in the
session transcript — `claude -p --resume <session-id>` picks it back up with
full context. This skill launches [supervise.sh](supervise.sh) (in the same
directory as this SKILL.md — resolve the absolute path from it) to exploit
that in a one_for_one supervision tree:

```
launchd/systemd/tmux (optional) ← keeps the supervisor alive
  └── supervise.sh              ← restart policy + backoff + stall detection
        └── claude -p /goal     ← worker, session pinned via --session-id
              └── subagents     ← survive on their own; the worker re-adopts state
```

**How it resumes:** the supervisor picks the session UUID itself (`uuidgen` +
`--session-id`). If the worker dies without creating `.supervisor/DONE`, it
relaunches with `claude -p --resume <uuid>` — full context preserved. The
initial prompt instructs the goal to keep `.supervisor/checkpoint.md` (a short
claude-handoff-style summary) updated after every step; if the transcript is
ever lost, a fresh session is seeded from that checkpoint.

## Invocation

1. Confirm the argument is an existing `goal.md`.
2. Consider whether the goal will need headless permissions — under `-p` there
   are no interactive prompts; without `--permission-mode acceptEdits` (or
   `bypassPermissions`, if the user asks for it) the goal can stall on denied
   permissions. Pass these through after `--`.
3. Launch in the background, outside the current session's process tree:

```bash
nohup <path-to-this-skill>/supervise.sh goals/<slug>/goal.md \
  -- --permission-mode acceptEdits >/dev/null 2>&1 &
```

4. Tell the user where to follow along:
   - `tail -f goals/<slug>/.supervisor/supervisor.log` — supervisor events
   - `tail -f goals/<slug>/.supervisor/worker.log` — claude output
   - `.supervisor/DONE` — goal finished; `.supervisor/BLOCKED` — needs a human

## supervise.sh options

- `--max-restarts N` / `--window S` — restart intensity (default 10/3600s); once exceeded, it gives up and notifies.
- `--stall S` — no transcript activity for S seconds → kill and restart (default 1800; 0 disables).
- `--fresh` — discard the previous session and start over (keeps the checkpoint as memory).

## Supervisor of the supervisor (root of the tree)

To survive logout/reboot, run supervise.sh itself under the system init. The
desired semantics are the same on both platforms: restart the supervisor if it
dies with an error, and STOP restarting once it exits 0 (goal done).

**macOS (launchd):** generate `~/Library/LaunchAgents/com.user.goal-<slug>.plist`
with `ProgramArguments` pointing at supervise.sh + goal.md, `WorkingDirectory`
set to the repo, `RunAtLoad`, and `KeepAlive: {SuccessfulExit: false}`, then
load it with `launchctl load`.

**Linux (systemd user unit):** the quick way is a transient unit:

```bash
systemd-run --user --unit=goal-<slug> \
  --property=Restart=on-failure --property=RestartSec=30 \
  --working-directory=<repo> \
  <path-to-this-skill>/supervise.sh goals/<slug>/goal.md -- --permission-mode acceptEdits
# follow along: journalctl --user -u goal-<slug> -f
```

To survive logout, enable linger: `loginctl enable-linger $USER`.
(Persistent equivalent: a `.service` in `~/.config/systemd/user/` with
`Restart=on-failure` + `WorkingDirectory` and `systemctl --user enable --now`.)

Simple alternative on both platforms: `tmux new -d -s goal-<slug> '...supervise.sh ...'`.
