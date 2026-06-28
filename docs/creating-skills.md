# Creating a skill

A skill is a folder with a `SKILL.md`. Copy the template below into
`skills/<category>/<skill-name>/SKILL.md` and edit.

## Template

```markdown
---
name: my-skill
description: What it does AND when to use it. Be concrete about the triggers —
  the model decides whether to load the skill from this line alone.
---

# My Skill

Short framing: what problem this solves.

## Steps / Instructions

1. ...
2. ...

## Notes

- Link supporting files like [reference.md](reference.md); they load on demand.
```

## Frontmatter fields

| Field | Required | Notes |
| :-- | :-- | :-- |
| `name` | yes | kebab-case; must match the folder name. |
| `description` | yes | What + when. This is the only part the model sees until the skill fires. |
| `disable-model-invocation` | no | `true` → user-only skill, triggered with `/my-skill`. |
| `allowed-tools` | no | Restrict which tools the skill may use. |

## Conventions

- **Keep `SKILL.md` lean.** Move long examples, references, and scripts into
  sibling files and link them. They're pulled in only when needed.
- **Self-contained.** Don't reference files outside the skill folder (`../...`).
  Plugin install copies each skill folder in isolation.
- **One job per skill.** Compose small skills rather than building one mega-skill.
- **Write the description for retrieval.** Front-load the trigger words a user
  or task would actually use.

## Where it goes

| Category | Use for |
| :-- | :-- |
| `engineering` | code work — testing, debugging, refactoring, design |
| `productivity` | planning, workflow, writing, handoffs |
| `misc` | occasional utilities |
| `personal` | your own one-off skills |
| `in-progress` | WIP — not loaded until promoted to a live category |
| `deprecated` | retired — kept for reference, not loaded |

Adding a skill to a live category needs **no** manifest edit — it's
auto-discovered. See [../CLAUDE.md](../CLAUDE.md) for the rules.
