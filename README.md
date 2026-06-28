# Joel's Skills

My personal collection of [agent skills](https://code.claude.com/docs/en/skills) for Claude Code. Inspired by [mattpocock/skills](https://github.com/mattpocock/skills).

A **skill** is a folder containing a `SKILL.md` with some frontmatter and instructions. Claude loads the frontmatter at startup and pulls in the full body only when the skill is relevant — so skills add capability without permanently bloating context.

## Install

This repo is both a **Claude Code plugin marketplace** and a plain skills bundle. Pick whichever you prefer.

### Native (Claude Code plugin)

```text
/plugin marketplace add JoelFrancisco/skills
/plugin install joel-skills@joel-skills
```

Update later with `/plugin marketplace update joel-skills`.

### npx (skills CLI)

```bash
npx skills@latest add JoelFrancisco/skills
```

## Layout

```text
skills/
├── engineering/     # day-to-day code work
├── productivity/    # planning, workflow, writing
├── misc/            # occasional utilities
├── personal/        # my own one-off / private skills
├── in-progress/     # WIP — NOT loaded by the plugin
└── deprecated/      # retired — NOT loaded by the plugin
```

Each skill lives at `skills/<category>/<skill-name>/SKILL.md`. Skills are listed
**individually** in [`.claude-plugin/plugin.json`](.claude-plugin/plugin.json)'s
`skills` array — that manifest is the source of truth for exactly what ships, and
it lets people cherry-pick individual skills when installing with the `skills`
CLI. Skills under `in-progress` and `deprecated` are deliberately kept out of the
manifest, so they're just storage and never ship.

## Adding a skill

1. Create `skills/<category>/<skill-name>/SKILL.md` (kebab-case folder name).
2. Add YAML frontmatter — `name` and `description` are required:

   ```markdown
   ---
   name: my-skill
   description: One sentence on what it does AND when to use it (this is how
     the model decides to invoke it — be specific about triggers).
   ---

   # My Skill

   Instructions for the agent go here. Reference supporting files like
   [reference.md](reference.md) and they'll be pulled in on demand.
   ```

3. Register it: add `"./skills/<category>/<skill-name>"` to the `skills` array in
   [`.claude-plugin/plugin.json`](.claude-plugin/plugin.json). This is what makes
   it ship and makes it individually selectable via the `skills` CLI.
4. Optionally add supporting files (`reference.md`, `scripts/`, etc.) beside `SKILL.md`.

See [docs/creating-skills.md](docs/creating-skills.md) for the full template and conventions.

## License

[MIT](LICENSE) © Joel Francisco
