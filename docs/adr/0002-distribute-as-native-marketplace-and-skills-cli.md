# 2. Distribute as both a native marketplace and via the skills CLI

Date: 2026-06-28

## Status

Accepted

## Context

There are two established ways to share Claude Code skills:

- **Native Claude Code plugin marketplace** — a `.claude-plugin/marketplace.json`
  + `plugin.json`, installed with `/plugin marketplace add JoelFrancisco/skills`
  then `/plugin install joel-skills@joel-skills`. First-party, no external
  dependency, and supports updates via `/plugin marketplace update`.
- **The `skills` CLI** ([vercel-labs/skills]) — `npx skills@latest add
  JoelFrancisco/skills`. Cross-agent (not Claude Code-specific), and supports
  selecting individual skills (`--skill <name>`, `'*'` for all).

They are not mutually exclusive: both read the same `skills/` directory layout
and the same `.claude-plugin/` manifests. [mattpocock/skills] ships a
`plugin.json` (the CLI path) only.

Options considered: native only, CLI only, or both.

## Decision

Support both, from one set of files. Keep `marketplace.json` + `plugin.json` for
the native install, and rely on the same manifests and `skills/` layout for the
`skills` CLI. No duplication — one source serves both install paths.

## Consequences

- Widest reach: Claude Code users get a first-party install with managed
  updates; users on other agents, or who want per-skill selection, use the npx
  CLI.
- Both paths must keep working. Changes to the manifests or layout should be
  sanity-checked against both — low burden since they share the same source.
- Two install flows to document (done in the README).

[vercel-labs/skills]: https://github.com/vercel-labs/skills
[mattpocock/skills]: https://github.com/mattpocock/skills
