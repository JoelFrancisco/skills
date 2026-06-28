# Architecture Decision Records

Short docs capturing notable decisions about how this repo is built and why —
so the reasoning survives even when the choice looks obvious in hindsight.
Format: [Michael Nygard's ADR template].

New record: copy the structure of an existing one, number it next in sequence
(`NNNN-kebab-title.md`), set `## Status` to `Accepted`, and add a row below.

| #                                            | Decision                                          | Status   |
| -------------------------------------------- | ------------------------------------------------- | -------- |
| [0001](0001-no-changesets-or-npm-tooling.md) | No changesets or npm release tooling              | Accepted |
| [0002](0002-distribute-as-native-marketplace-and-skills-cli.md) | Distribute as both a native marketplace and via the skills CLI | Accepted |
| [0003](0003-per-skill-enumeration-in-plugin-json.md) | Enumerate skills individually in plugin.json | Accepted |

[Michael Nygard's ADR template]: https://github.com/joelparkerhenderson/architecture-decision-record
