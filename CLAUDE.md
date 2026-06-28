# CLAUDE.md

Guidance for Claude when working **inside this repository**. This is a skills
repo: a distributable Claude Code plugin whose payload is a set of skills.

## What lives here

- `skills/<category>/<skill-name>/SKILL.md` — the skills themselves.
- `.claude-plugin/plugin.json` — the plugin manifest. Its `skills` array lists
  **each skill individually** (`./skills/<category>/<name>`). It is the source of
  truth for what the plugin ships and what the `skills` CLI offers for per-skill
  selection — a skill that isn't listed doesn't ship.
- `.claude-plugin/marketplace.json` — marketplace catalog so the repo installs
  via `/plugin marketplace add JoelFrancisco/skills`.
- `docs/creating-skills.md` — template and conventions for writing a skill.
- `docs/adr/` — architecture decision records. Read before revisiting a
  structural choice; add one when you make a new one.

## Conventions

- **Folder name = skill name = `name:` frontmatter**, all kebab-case and matching.
- **`description` frontmatter must say WHAT the skill does AND WHEN to use it.**
  The model only ever sees the description until the skill fires, so triggers
  belong here, not buried in the body.
- Keep `SKILL.md` focused. Push long reference material, examples, and scripts
  into sibling files and link them — they load on demand.
- A skill folder must be self-contained. Don't reference files outside the skill
  folder with `../` — plugin install copies skill folders in isolation.

## Categories

- `engineering` — code work (testing, debugging, refactoring, design).
- `productivity` — planning, workflow, writing, handoffs.
- `misc` — occasional utilities that don't fit above.
- `personal` — my own one-off skills.
- `in-progress` — WIP. **Not** in `plugin.json`; not loaded. Promote to a real
  category when ready.
- `deprecated` — retired. **Not** in `plugin.json`; kept for reference only.

## When adding or moving skills

- Adding a skill: create the folder + `SKILL.md`, then add
  `"./skills/<category>/<name>"` to the `skills` array in `plugin.json`. The
  manifest is the source of truth — an unlisted skill doesn't ship.
- Promoting from `in-progress` or restoring from `deprecated`: move the folder
  into a live category **and** add its path to `plugin.json`.
- Retiring a skill: move it to `deprecated` (or delete it) **and** remove its
  path from `plugin.json`.
- Bumping what users get: update `version` in both `plugin.json` and
  `marketplace.json`.

See [docs/adr/0003-per-skill-enumeration-in-plugin-json.md](docs/adr/0003-per-skill-enumeration-in-plugin-json.md)
for why the list is maintained by hand rather than auto-discovered.
