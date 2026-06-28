#!/usr/bin/env node
// Regenerate the `skills` array in .claude-plugin/plugin.json from the skills/ tree.
//
// Lists every skills/<category>/<name>/ that contains a SKILL.md, excluding the
// in-progress and deprecated categories. The manifest is the source of truth for
// what ships (see docs/adr/0003-per-skill-enumeration-in-plugin-json.md); this
// keeps it in sync without hand-editing.
//
// Usage:
//   node scripts/sync-skills.mjs          # rewrite plugin.json in place
//   node scripts/sync-skills.mjs --check  # exit 1 if out of sync (no write)
//
// Zero dependencies: plain node, no package.json (see ADR 0001).

import { readdirSync, readFileSync, writeFileSync, existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const SKILLS_DIR = join(ROOT, "skills");
const MANIFEST = join(ROOT, ".claude-plugin", "plugin.json");
const EXCLUDED = new Set(["in-progress", "deprecated"]);

const subdirs = (p) =>
  existsSync(p)
    ? readdirSync(p, { withFileTypes: true })
        .filter((e) => e.isDirectory() && !e.name.startsWith("."))
        .map((e) => e.name)
        .sort()
    : [];

const skills = [];
for (const category of subdirs(SKILLS_DIR)) {
  if (EXCLUDED.has(category)) continue;
  for (const name of subdirs(join(SKILLS_DIR, category))) {
    if (existsSync(join(SKILLS_DIR, category, name, "SKILL.md"))) {
      skills.push(`./skills/${category}/${name}`);
    }
  }
}

const manifest = JSON.parse(readFileSync(MANIFEST, "utf8"));
const current = JSON.stringify(manifest.skills ?? []);
const next = JSON.stringify(skills);
const plural = `${skills.length} skill${skills.length === 1 ? "" : "s"}`;

if (current === next) {
  console.log(`✓ plugin.json is in sync (${plural}).`);
  process.exit(0);
}

if (process.argv.includes("--check")) {
  console.error(
    "✗ plugin.json skills array is out of sync. Run: node scripts/sync-skills.mjs",
  );
  console.error(`  manifest: ${current}`);
  console.error(`  tree:     ${next}`);
  process.exit(1);
}

manifest.skills = skills;
writeFileSync(MANIFEST, JSON.stringify(manifest, null, 2) + "\n");
console.log(`✓ Wrote ${plural} to plugin.json:`);
for (const s of skills) console.log(`  ${s}`);
if (skills.length === 0) console.log("  (none yet)");
