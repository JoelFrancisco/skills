# 3. Enumerate skills individually in plugin.json

Date: 2026-06-28

## Status

Accepted (supersedes the initial scaffold, which used category-directory paths)

## Context

The `skills` field in `.claude-plugin/plugin.json` accepts either form:

- **(a) Category-directory paths** — e.g. `"./skills/engineering"`. The native
  Claude Code loader treats each as a container and expands it to every
  `<name>/SKILL.md` inside. Zero manifest edits when adding a skill.
- **(b) Explicit per-skill paths** — e.g. `"./skills/engineering/tdd"`, one entry
  per skill. This is what [mattpocock/skills] does.

The repo was first scaffolded with (a) to minimise maintenance. On review, we
want the manifest to be the **curated source of truth for exactly what ships**.

A nuance we checked: the `skills` CLI ([vercel-labs/skills]) walks the catalog
layout (`skills/<category>/<name>/SKILL.md`) on its own, so per-skill *CLI*
selection works under (a) too — it is not the deciding factor. The deciding
factor is the **native** `/plugin install`, which is all-or-nothing relative to
what the manifest declares. Under (a), every skill in a live category ships;
under (b), we can keep a skill in the repo while withholding it from the shipped
plugin just by not listing it.

## Decision

List each skill explicitly in `plugin.json`'s `skills` array
(`"./skills/<category>/<name>"`). The array is the authoritative manifest of
shipped skills. Skills under `in-progress` and `deprecated` are never listed.

## Consequences

- The manifest documents exactly what ships; nothing loads by accident, and
  native installs can be curated by including or omitting a path.
- Adding, moving, or retiring a skill now requires a one-line manifest edit, and
  it's easy to forget. Acceptable for a single maintainer.
- Keeping the list current is automated by `scripts/sync-skills.mjs`, which
  regenerates the array from the `skills/` tree (run it after adding/moving/
  retiring a skill, or `--check` it in CI). It's plain zero-dependency node with
  no `package.json`, so it stays within
  [ADR 0001](0001-no-changesets-or-npm-tooling.md)'s lean philosophy.

[mattpocock/skills]: https://github.com/mattpocock/skills
[vercel-labs/skills]: https://github.com/vercel-labs/skills
