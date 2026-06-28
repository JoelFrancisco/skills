# Context

Shared vocabulary for this repo, so descriptions of the work stay short.

- **Skill** — a folder under `skills/<category>/` containing a `SKILL.md`.
  The unit of distribution.
- **SKILL.md** — the skill's entry file: YAML frontmatter (`name`,
  `description`, plus optional fields) followed by Markdown instructions for the
  agent.
- **Supporting file** — any extra file beside `SKILL.md` (`reference.md`,
  `scripts/`, etc.) that the body links to and the agent loads on demand.
- **Category** — a top-level folder under `skills/` grouping related skills
  (`engineering`, `productivity`, `misc`, `personal`, `in-progress`,
  `deprecated`).
- **Live category** — one listed in `plugin.json`'s `skills` array, so its
  skills are loaded (`engineering`, `productivity`, `misc`, `personal`).
- **Model-invoked skill** — fires automatically when its `description` matches
  the task.
- **User-invoked skill** — triggered explicitly with `/skill-name`. Set
  `disable-model-invocation: true` in frontmatter to make a skill user-only.
- **Plugin** — what this whole repo installs as in Claude Code (`joel-skills`).
- **Marketplace** — the catalog (`marketplace.json`) that makes the plugin
  installable via `/plugin marketplace add`.
