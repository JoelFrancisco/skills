# T3 Code Taste Profile

This is an interpretive profile inferred from public T3 Code design commits,
reviews, issues, and before/after evidence. It is not an official T3 Code design
standard or endorsement.

## Leading ideas

### Quiet shell

Let the working content dominate. Prefer a small number of calm, continuous
surfaces over nested panels, mini-cards, and repeated outlines. A shell should
describe a real region; avoid decorative layers that imply a second window,
panel, or safe area.

- Prefer rows or sections for repeated settings and list content.
- Use cards when items are genuinely independent objects, not as default
  spacing containers.
- Let spacing and type establish hierarchy before borders and fills.
- Name a region quietly when whitespace alone leaves its meaning ambiguous.
- Give one layer ownership of background, border, radius, shadow, blur, and
  clipping.

### Semantic ink

Spend color where it carries meaning. Keep the neutral field broad enough that
working, blocked, failed, selected, or actionable states remain salient.

- Separate lifecycle state from pending attention.
- Avoid repeating the same identity in artwork, badge, chip, heading, and color.
- Treat semantic tokens as hypotheses: inspect their actual contrast in light
  and dark contexts.
- Keep inactive content quieter without making metadata needed for a decision
  disappear.
- Use one dominant heading color per region unless another color communicates a
  distinct state.

### Contextual chrome

Keep the common path calm and reveal exception controls when their exception
exists.

- Show reset only when a value differs from its effective default.
- Put bulk selection behind an explicit editing mode.
- Keep advanced or infrequent settings behind progressive disclosure.
- Place recovery at the point where the blocked or hidden state affects the
  user.
- Prefer conventional chevrons, close behavior, menu semantics, and shortcut
  labels over novel micro-controls.

### Stable geometry

Preserve spatial memory. State changes should alter meaning before they alter
the location or footprint of a recurring action.

- Keep icon and chevron slots stable across base, hover, active, and collapsed
  states.
- Do not replace useful metadata with an action on hover.
- Group a modifier beside the action it modifies.
- Anchor menus and popovers to the full visual trigger with a related width and
  axis.
- Use coordinated inner and outer radii so a composed shell reads as one object.

## Typography and labels

- Prefer readable sentence case over ornamental uppercase or monospace labels.
- Use small labels to explain state or grouping, not to restate nearby context.
- Keep unfamiliar actions labeled; icon-only controls are for established,
  repeated actions with accessible names and surrounding context.
- Preserve raw semantic text for assistive technology when visually decorating
  tokens, commands, or statuses.
- Prefer an honest longer label over an ambiguous abbreviation; solve density
  structurally before compressing language.

## Density and hierarchy

- Favor compact utility without crowding.
- Make the decisive state and likely next action easy to scan.
- Let inactive rows recede while keeping time, branch, status, and other
  decision-bearing metadata reachable.
- Use a quiet divider or label when a lifecycle boundary matters.
- Aggregate compressed status by actionable priority, not merely by recency or
  count.
- Remove duplicated project, environment, or mode context once the surrounding
  region already establishes it.

## Materials and dark mode

- Maintain hierarchy in dark mode instead of mechanically inverting colors.
- Prefer slightly separated neutral surfaces and restrained inset definition to
  stacks of shadows.
- Reserve blur or glass for genuinely elevated surfaces; repeated rows remain
  materially quiet.
- Avoid large branded or highly colored panels when they compete with the work.
  Use stronger art only when product identity calls for it.
- Provide coherent fallbacks for unsupported compositing, clipping, or blur.
- Inspect light mode independently; a token that succeeds on dark can become
  weak or muddy on light.

These are defaults, not absolutes. Break one when the brief supplies a stronger
product reason and the rendered result preserves hierarchy.

## Motion and decorative identity

- Use motion to explain transition, causality, or reorientation.
- Keep decorative motion finite and quiet; reduced-motion support is required
  but does not justify otherwise distracting animation.
- Make strong decorative art optional when it occupies persistent workspace.
- Persist that preference and prevent hydration flashes or theme mismatch.
- Ensure artwork does not create a false boundary that makes one surface look
  like two windows.

## Platform fit

- Treat desktop, web, iOS, and Android as separate evidence surfaces when their
  APIs or primitives differ.
- Use platform-valid icon contracts rather than assuming a shared string name.
- Test third-party content, markdown, code blocks, tables, and native defaults
  in every theme.
- Test intermediate widths and physical target devices when possible; say
  `unverified` when not possible.

## Signature failure scan

- **Card soup:** repeated containers compete with their content.
- **Badge soup:** chips repeat context or turn every state into equal emphasis.
- **Double shell:** two layers claim the same surface or safe area.
- **Shape-shifting target:** hover or live state moves a recurring action.
- **Split-brain state:** visual visibility and parent layout use different
  sources.
- **Dead-end warning:** the interface reports a block without recovery or an
  explicit continuation path.
- **Stage prop:** an interactive demo looks complete but has fake, global, or
  unsynchronized controls.

## Public evidence basis

- Broad refresh and correction tail:
  <https://github.com/pingdotgg/t3code/pull/4319>
- Settings simplification and contextual reset:
  <https://github.com/pingdotgg/t3code/pull/1288>
- Stable collapsed-state A/B comparison:
  <https://github.com/pingdotgg/t3code/pull/1097>
- Separate sidebar polish pass:
  <https://github.com/pingdotgg/t3code/pull/4252>
- Timed and collapsed lifecycle state:
  <https://github.com/pingdotgg/t3code/pull/4418>
- Decorative backdrop iteration:
  <https://github.com/pingdotgg/t3code/pull/4130>
- Physical Android validation:
  <https://github.com/pingdotgg/t3code/pull/3692>
- Progressive disclosure for bulk controls:
  <https://github.com/pingdotgg/t3code/pull/872>
- Spatial-instability report:
  <https://github.com/pingdotgg/t3code/issues/245>
- Intermediate-width overflow report:
  <https://github.com/pingdotgg/t3code/issues/531>
