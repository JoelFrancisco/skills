---
name: goal-supervisor
description: Run a goal (/goal) or a Workflow script under a supervision tree that restarts it from where it stopped whenever the process dies or hangs.
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
worker is instructed to keep `.supervisor/checkpoint.md` (a short
claude-handoff-style summary) updated after every step; when the session
becomes unresumable (transcript missing, or resume failing fast repeatedly),
the supervisor discards it and starts a fresh session whose prompt points at
that checkpoint, so progress carries over.

**Outcomes:** the supervisor exits 0 on every intentional stop and leaves a
sentinel telling which one — `.supervisor/DONE` (goal finished),
`.supervisor/BLOCKED` (needs a human; blocker described in `checkpoint.md`),
`.supervisor/GAVE_UP` (restart limit hit). A non-zero exit means the
supervisor itself crashed — which is exactly what the root supervisor
restarts on. While `BLOCKED` or `GAVE_UP` is present, relaunching the
supervisor exits 0 immediately — resolve the blocker and remove the sentinel
(or pass `--fresh`) to retry.

## Invocation

1. Decide the headless permission mode with the user's intent in mind — under
   `-p` there are no interactive prompts, so a goal without
   `--permission-mode acceptEdits` (or `bypassPermissions`, if the user asks
   for it) stalls on the first denied edit. Pass it through after `--`.
2. Launch in the background, outside the current session's process tree:

```bash
nohup "<path-to-this-skill>/supervise.sh" "goals/<slug>/goal.md" \
  -- --permission-mode acceptEdits >/dev/null 2>&1 &
```

3. Tell the user where to follow along, and which sentinel files signal the
   outcome:
   - `tail -f goals/<slug>/.supervisor/supervisor.log` — supervisor events
   - `tail -f goals/<slug>/.supervisor/worker.log` — claude output
   - `.supervisor/DONE` / `BLOCKED` / `GAVE_UP` — outcome sentinels (above)

## supervise.sh options

- `--max-restarts N` / `--window S` — restart intensity (default 10 restarts per 3600s, not counting the initial launch); once exceeded, it gives up, writes `GAVE_UP`, and notifies.
- `--stall S` — no session-transcript activity for S seconds → kill and restart (default 3600; 0 disables). Inactive while the transcript file is not found, so a path mismatch never kills a healthy worker. Raise it for goals with long silent phases (big builds, long subagent runs).
- `--fresh` — discard the previous session and outcome sentinels and start over (keeps the checkpoint as memory).

## Workflows (`--kind workflow`)

Long Workflow runs die when the conversation that hosts them compacts — the
fix is isolation: run the workflow in a dedicated supervised session whose
conversation stays tiny, so compaction never fires. Same tree, different
worker:

```bash
nohup "<path-to-this-skill>/supervise.sh" "path/to/workflow.js" --kind workflow \
  -- --permission-mode bypassPermissions --model sonnet >/dev/null 2>&1 &
```

- The runner session calls the Workflow tool on the script, persists the
  runId to `.supervisor/workflow-run-id`, waits for completion, writes
  `.supervisor/result.md` and `DONE`.
- On death, the resumed session calls Workflow with `resumeFromRunId` from
  that file: completed `agent()` calls replay from the journal cache and only
  the remainder runs live. The resume continues under the same runId/journal.
- The journal cache is session-bound: if the supervisor has to discard the
  session (unresumable transcript), the workflow restarts from scratch.
- **Permissions:** `acceptEdits` is NOT enough — executing a dynamic workflow
  script from a headless session hits an interactive approval and the run
  dies on the spot. Use `--permission-mode bypassPermissions` (validated), or
  a permission allowlist covering the Workflow tool if you want something
  narrower.
- Validated end-to-end: SIGKILL mid-run at stage 3/12 → resume → 3 stages
  from cache + 9 live, full result delivered.

## Supervisor of the supervisor (root of the tree)

To survive logout/reboot, run supervise.sh itself under the system init.
Because intentional stops exit 0, "restart only on failure" gives the right
semantics on both platforms: crashes are restarted, DONE/BLOCKED/GAVE_UP stay
stopped.

**macOS (launchd):** generate `~/Library/LaunchAgents/com.user.goal-<slug>.plist`
with `ProgramArguments` pointing at supervise.sh + goal.md, `WorkingDirectory`
set to the repo, `RunAtLoad`, and `KeepAlive: {SuccessfulExit: false}`, then
load it with `launchctl load`.

**Linux (systemd user unit):** the quick way is a transient unit:

```bash
systemd-run --user --unit=goal-<slug> \
  --property=Restart=on-failure --property=RestartSec=30 \
  --working-directory=<repo> \
  "<path-to-this-skill>/supervise.sh" "goals/<slug>/goal.md" -- --permission-mode acceptEdits
# follow along: journalctl --user -u goal-<slug> -f
```

To survive logout, enable linger: `loginctl enable-linger $USER`.
(Persistent equivalent: a `.service` in `~/.config/systemd/user/` with
`Restart=on-failure` + `WorkingDirectory` and `systemctl --user enable --now`.)

Simple alternative on both platforms: `tmux new -d -s goal-<slug> '...supervise.sh ...'`.
