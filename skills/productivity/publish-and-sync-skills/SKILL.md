---
name: publish-and-sync-skills
description: Release train for public agent skills in JoelFrancisco/skills. Use when adding, importing, or updating a skill in the repository, publishing it through GitHub, and syncing the merged version globally across local agent harnesses.
---

# Publish and Sync Skills

Run one release train:

Repository source → validation → GitHub merge → global installation → evidence.

Treat `JoelFrancisco/skills` as the source of truth. Treat global agent
directories as generated installations.

## Route the release

Choose one entry point:

- **Add or import:** run every step.
- **Update:** begin with repository preparation, edit the existing skill, then
  run registration through verification.
- **Sync only:** verify that the requested skill is already merged into `main`,
  then begin with global installation.

A full publish-and-sync request includes merge authorization. A request for a
PR stops after publishing the draft.

## 1. Prepare the repository

Resolve a checkout whose `origin` identifies `JoelFrancisco/skills`. Read its
repository instructions, `docs/creating-skills.md`, and accepted ADRs before
changing structure or release behavior.

Synchronize a clean `main` with `origin/main`, then create
`agent/<skill-name>`. Preserve unrelated work by isolating it or asking for
scope before staging.

Complete this step when the checkout is on a dedicated branch based on current
`origin/main` and every existing change has a known owner.

## 2. Add or update the skill

Choose the live category from the repository conventions. Keep the folder name,
frontmatter `name`, and kebab-case skill name identical.

For a new skill, use the current harness's skill-authoring scaffold. When the
harness provides manual authoring only, create:

```text
skills/<category>/<skill-name>/
├── SKILL.md
└── agents/openai.yaml
```

For an imported public skill, inspect its license, provenance, scripts, network
behavior, credential use, and destructive operations before adapting it. Keep
required attribution with the imported material.

Write a model-facing description that states what the skill does and gives one
trigger for each real branch. Keep the body imperative, self-contained, and
free of placeholders. Put detailed or conditional material in sibling files
with explicit context pointers.

Complete this step when the skill has one clear job, all placeholders are
resolved, UI metadata is valid, and every procedural step has a checkable
completion criterion.

## 3. Register and version the release

Regenerate the curated manifest:

```bash
node scripts/sync-skills.mjs
```

Advance the release version in both `.claude-plugin/plugin.json` and
`.claude-plugin/marketplace.json`. Keep the values equal. A new public skill
normally warrants a minor release; a compatible correction normally warrants a
patch release.

Complete this step when the new skill path appears exactly once in
`plugin.json`, the manifest contains exactly the live-category skills, and both
manifests carry the same intended version.

## 4. Validate before publication

Run every applicable check:

```bash
node scripts/sync-skills.mjs --check
jq empty .claude-plugin/plugin.json .claude-plugin/marketplace.json
git diff --check
npx --yes skills@latest add . --list --full-depth
```

Run the current harness's skill validator when available. Execute every bundled
script on a representative input. Forward-test complex skills with a fresh
agent that receives only the skill and a realistic task.

Complete this step when manifest discovery lists the skill, structural checks
pass, executable resources pass, and forward-test failures have been corrected
or explicitly reported.

## 5. Publish and merge

Inspect the full diff and stage only release files. Commit tersely on the
dedicated branch, push with tracking, and open a draft PR whose body explains
the change, reason, impact, and validation.

When the request includes the full release:

1. Verify the PR target, expected head SHA, mergeability, reviews, and checks.
2. Mark the PR ready and merge it with the repository's accepted method.
3. Switch the local checkout to `main` and pull with `--ff-only`.

Use the available GitHub integration first and an authenticated `gh` CLI as the
fallback for unsupported mutations.

For a PR-only release, complete this step when the draft PR contains the
intended diff and validation evidence. For a full release, complete it when
GitHub reports the PR merged, local `main` contains the merge, and the worktree
is clean.

## 6. Install the merged skill globally

Confirm the current Vercel Skills CLI syntax with
`npx --yes skills@latest --help`. Define this shell helper, then call
`sync_public_skill` with the exact merged skill name:

```bash
sync_public_skill() {
  local released_skill="$1"
  npx --yes skills@latest add JoelFrancisco/skills \
    --global \
    --agent codex claude-code hermes-agent opencode pi \
    --skill "$released_skill" \
    --yes \
    --full-depth
}
```

The command uses the CLI's default symlink installation model. The canonical
harness identifiers are `codex`, `claude-code`, `hermes-agent`, `opencode`, and
`pi`.

Complete this step when the CLI reports the requested skill installed for all
five harnesses.

## 7. Verify the local sync

List the global installation as JSON and select the released skill:

```bash
npx --yes skills@latest list --global --json
```

Verify:

- scope is global;
- source is `JoelFrancisco/skills`;
- Codex, Claude Code, Hermes Agent, OpenCode, and Pi are present;
- agent-specific links resolve to the canonical installation where the CLI uses
  symlinks;
- installed `SKILL.md` content matches the merged repository version.

Complete the release train when the GitHub merge, local `main`, manifest
version, global source, five harnesses, and installed content all agree.

## Report the release

Lead with the result. Include the skill name and path, release version, commit,
PR and merge, validations, installation source, harness coverage, and any
remaining unverified item.

Complete the report when it is self-contained and distinguishes passed, failed,
and unverified evidence.
