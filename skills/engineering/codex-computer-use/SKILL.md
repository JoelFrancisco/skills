---
name: codex-computer-use
description: Delegate browser/UI verification and computer-use tasks to Codex — launching the app, clicking through flows, verifying UI/UX changes visually. Use when a change needs to be seen working in a real browser and screenshots would burn main-loop tokens.
---

# Codex computer use — UI/UX verification delegate

Codex is markedly better and cheaper at computer use and UI/UX verification
than the main loop (screenshots are token furnaces).

1. Write a self-contained verification brief for Codex: how to launch the app
   (dev server command, port), the flow to exercise step by step, and what
   "correct" looks like (layout, copy, behavior, no console errors).
2. Run — ONE Bash call that captures the output path and reads it back (an
   inline `-o "$(mktemp)"` loses the path):
   `OUT=$(mktemp) && codex exec -s workspace-write -c sandbox_workspace_write.network_access=true -C <repo-root> -o "$OUT" "<brief>" </dev/null >"$OUT.log" 2>&1; echo "exit=$?"; cat "$OUT"`
   Always close stdin with `</dev/null` (codex blocks on a non-TTY stdin pipe).
   `network_access=true` is required: the default sandbox blocks ALL network,
   including localhost, so codex cannot reach the dev server without it.
   Tell it to use its browser tooling, take its own screenshots, and end with
   PASS/FAIL per checkpoint plus anything unexpected it saw.
3. Report only the verdict and findings — never pull raw screenshots into the
   main context.
4. If codex reports the sandbox blocked the real browser launch and it fell
   back to jsdom: DOM behavior checks still count, but rendering/layout/visual
   claims do not — verify those yourself with the browser skill (Pinchtab) or
   claude-in-chrome instead.
5. FAIL or ambiguous → inspect yourself (browser skill / claude-in-chrome)
   before fixing.
