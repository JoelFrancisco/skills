# 1. No changesets or npm release tooling

Date: 2026-06-28

## Status

Accepted

## Context

This repo is a personal collection of Claude Code agent skills, distributed as a
plugin/marketplace. [mattpocock/skills], the repo this one is modeled on,
includes [changesets] (`@changesets/cli`, `@changesets/changelog-github`), a
`package.json`, and a generated `CHANGELOG.md` to manage version bumps and
changelog entries — even though its package is `private: true` and never
published to npm.

We considered mirroring that. The question: does a skills repo need changesets?

How versioning actually works for a Claude Code plugin:

- The `version` field in `.claude-plugin/plugin.json` and `marketplace.json`
  determines what installed users receive. Bump it to publish an update; users
  pull it with `/plugin marketplace update`.
- If `version` is omitted, Claude Code falls back to the git commit SHA, so
  updates flow on every push.

Nothing about install or update resolution depends on changesets. Its only value
here would be (a) automated version bumping and (b) an auto-generated changelog —
release-discipline conveniences aimed at multi-contributor libraries.

## Decision

Do not add changesets, `package.json`, or `CHANGELOG.md`. Manage the plugin
version by editing the `version` field in `plugin.json` and `marketplace.json`
by hand when an update is worth cutting (or leave it and rely on the commit-SHA
fallback).

## Consequences

- The repo stays lean: no Node toolchain, lockfile, or `node_modules` to
  maintain for what is a markdown-and-docs project.
- Version bumps are a manual two-field edit. Easy to forget — acceptable for a
  single-maintainer repo; revisit if that changes.
- No structured changelog; git history is the record of changes. If a
  human-readable changelog later becomes desirable, adopting changesets is a
  small, additive change that would supersede this ADR.

[mattpocock/skills]: https://github.com/mattpocock/skills
[changesets]: https://github.com/changesets/changesets
