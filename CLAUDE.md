# CLAUDE.md

Guidance for Claude when working **inside this repository**. This is a skills
repo: a distributable Claude Code plugin whose payload is a set of skills.

## What lives here

- `skills/<category>/<skill-name>/SKILL.md` — the skills themselves.
- `.claude-plugin/plugin.json` — the plugin manifest. Its `skills` array lists
  the **category directories** that are loaded; skills inside them are
  auto-discovered by folder name.
- `.claude-plugin/marketplace.json` — marketplace catalog so the repo installs
  via `/plugin marketplace add JoelFrancisco/skills`.
- `docs/creating-skills.md` — template and conventions for writing a skill.

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

- Adding a skill to `engineering`/`productivity`/`misc`/`personal`: just create
  the folder + `SKILL.md`. No manifest edit needed (category dirs are already
  listed in `plugin.json`).
- Promoting from `in-progress` or restoring from `deprecated`: move the folder
  into a live category — that alone makes it load.
- Adding a **new** top-level category: add its path to the `skills` array in
  `plugin.json`.
- Bumping what users get: update `version` in both `plugin.json` and
  `marketplace.json`.
