# Interface Failure Checklist

Use only the sections relevant to the surface map. This checklist catches
regressions that commonly survive a polished happy-path screenshot.

## Preservation

- Does the restyle preserve functional grouping and information architecture?
- Is every datum needed for the next decision still visible or reachable?
- Do hover, focus, selection, and compression preserve metadata and affordances?
- Do recurring actions stay in place during live updates and state changes?
- Does whitespace communicate a named grouping rather than an unexplained gap?
- Does decorative identity avoid repeating context already established nearby?

## State ownership

- Does each visible condition have one authoritative owner?
- Do rendering, spacing, fades, accessible labels, and side effects share the
  same derived visibility?
- Is status precedence defined centrally when several states compete?
- Are domain lifecycle, pending attention, and decoration separate signals?
- Does dismissal update every consumer?
- Do alternate entry points reuse the same eligibility and permission guards?

## Collections and compression

- Does the active item remain reachable through filter, pagination, virtualized
  rendering, and collapsed groups?
- Does an empty state use the real domain collection instead of the visible
  slice?
- Does a compact representation aggregate the most actionable status?
- Are rare bulk controls disclosed on demand while their consequences remain
  visible?
- Can a touch user reach actions revealed on hover?

## Transient and timed behavior

- Are success, cancellation, Escape, window exit, drop, unmount, retry, and
  eligibility changes balanced transitions?
- Can an event occur between render and effect subscription?
- Is there an explicit invalidation boundary for expiry or scheduled state?
- Can stale asynchronous responses overwrite newer state?
- Does retry preserve or clearly reset the user's work?

## Overlays and portals

- Does the overlay align with its trigger by anchor, width, and axis?
- Does it survive viewport edges, zoom, long content, and small heights?
- Do transformed or clipping ancestors change its positioning?
- Are focus entry, focus return, Escape, click-outside, and nested overlays
  coherent?
- Does it avoid covering the content or action the user must inspect?
- Are interactive roles siblings with valid semantics rather than controls
  nested inside controls?

## Shells and materials

- Does each continuous surface have one owner for background, border, radius,
  shadow, blur, clipping, and safe-area behavior?
- Do inner and outer radii describe the same geometry?
- Does repeated content use material only where elevation is meaningful?
- Did adopting a shared primitive remove obsolete offsets and local overrides?
- Is structural spacing owned by layout rather than empty decorative elements?
- Does every advanced CSS effect have a coherent fallback?

## Responsive and platform behavior

- Was the layout tested between named breakpoints?
- Do long labels, large values, localization, text zoom, and narrow heights fit?
- Are icon identifiers, fonts, gestures, and native conventions valid on each
  target platform?
- Are third-party and browser-default surfaces correct in every theme?
- Is platform-specific behavior proven on the target or marked unverified?

## Custom controls and accessibility

- Do keyboard, focus, pointer, and touch behaviors match the native control?
- Are accessible name, role, value, state, and error severity accurate?
- Are forced colors, reduced motion, and browser-specific pseudo-elements
  handled?
- Does an icon-only control have an accessible name and enough adjacent context?
- Does a disabled appearance agree with actual eligibility across every input
  path?

## Recovery and destructive actions

- Does every warning offer recovery or explicit continuation?
- Is confirmation based on current data?
- Does it name the exact target, reach, consequence, and reversibility?
- Can the user understand what will remain untouched?
- Is the recovery action located where the blocked state affects the user?

## Evidence

- Visual change: same-data, same-viewport, same-theme before/after screenshots.
- Motion, reorder, or timed state: short recording across the transition.
- Overlay: evidence that includes trigger and underlying content.
- Mobile or platform-specific behavior: target device or explicit `unverified`.
- Custom control: keyboard, focus, forced-colors, and fallback evidence.
- Collapse, filter, or pagination: proof that the active item remains reachable.
- Timed state: proof on both sides of expiry.
- Broad refresh: audit by component family after the page-level pass.

Tests, types, and lint support the evidence; they do not replace rendered proof.
