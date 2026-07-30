---
name: design-better-interfaces
description: Product-interface quality gate for evidence-based UI decisions. Use when designing or implementing a user-facing UI, reviewing its usability, refining an existing interface, or changing responsive, stateful, overlay, or cross-platform behavior.
---

# Design Better Interfaces

Treat an interface as a complete product workflow. Use this quality gate as the
single standard for design decisions and completion. Preserve task, information,
state, and behavior before improving appearance.

Use the inspection, rendering, browser, screenshot, accessibility, and test
capabilities available in the current environment.

## Route the request

Choose one branch and follow its path:

- **Review or diagnose:** Brief → Inspect → Map → States/Risk → Verify → Report.
  Leave the artifact unchanged. Finish with every applicable gate marked passed,
  failed, or unverified and findings ordered by user impact.
- **Design or explore:** Brief → Inspect when an artifact exists → Map → Decide →
  States/Risk → Report. Produce one coherent direction by default. Make requested
  alternatives differ materially in hierarchy, interaction, or layout. Finish
  when tradeoffs are explicit and one direction is recommended unless the user
  requests a neutral comparison.
- **Build, refine, or fix:** Brief → Inspect → Map → Decide → States/Risk →
  Implement → Verify → Report. Finish when the requested scope is implemented,
  the primary task succeeds under tested conditions, and every applicable gate
  has evidence. Report external blockers to a passing result.

Treat external publication as a separate action that requires an explicit user
request.

## 1. Establish the brief

Resolve from available evidence:

- user, primary task, frequency, cost of error, and visible success;
- domain, brand, tone, expected density, and attention budget;
- affected surfaces, target sizes and platforms, input methods, themes, design
  system, and technical constraints;
- data states, permissions, content extremes, and live or timed behavior.

Investigate the product and repository before asking questions. Ask when a
missing choice would materially change the product; otherwise state a reasonable
assumption.

Complete this step when every item is resolved, marked inapplicable, or covered
by an explicit assumption.

## 2. Inspect the product

For an existing product:

1. Read project instructions and walk the affected flow.
2. Inventory tokens, component families, typography, spacing, density,
   navigation, vocabulary, interactions, and platform variants.
3. Capture a rendered baseline with realistic data at relevant sizes.
4. State the observed problem in user-visible terms.

Reuse suitable conventions. Replace an inaccessible or harmful convention with
the closest coherent alternative.

For a greenfield interface, derive the visual direction from the audience,
domain, content, task, and expected density.

Complete this step when the current flow, applicable conventions, observed
problem, and baseline are recorded. Mark rendering unverified when the
environment cannot produce it. For greenfield work, complete it when the
direction is anchored in the brief and existing-artifact checks are marked
inapplicable.

## 3. Map preservation and surfaces

Write a preservation contract before changing an existing interface:

- information and hierarchy that must remain legible;
- tasks, interactions, shortcuts, and alternative entry points that must remain
  equivalent;
- stable positions or geometries users rely on;
- product conventions and semantic meanings that must survive the change.

Map every affected surface across:

- pages, repeated rows, toolbars, menus, dialogs, banners, tooltips, portals,
  overlays, and embedded or third-party content;
- small, intermediate, and large sizes; supported platforms and themes;
- pointer, keyboard, and touch;
- normal, long, empty, loading, error, stale, disabled, permission-limited,
  selected, collapsed, filtered, and paginated states.

For broad refreshes, overlays, custom controls, responsive or cross-platform
work, live or timed state, or filtering/collapse/pagination, read and apply the
relevant sections of
[references/interface-failure-checklist.md](references/interface-failure-checklist.md).

Complete this step when every contract item has a planned proof and every
applicable surface-state intersection is listed or explicitly excluded.

## 4. Decide with the quality gate

Apply this priority order:

1. The user can complete the primary task.
2. The state, hierarchy, and next action are clear.
3. Risk, failure, recovery, and reversibility are represented honestly.
4. The result is coherent with the product and design system.
5. The result is accessible and robust across supported sizes, inputs, themes,
   and platforms.
6. Spatial stability and runtime performance are preserved.
7. The visual craft is deliberate and appropriate to the domain.

A lower-priority improvement passes only while every higher-priority criterion
remains satisfied.

Shape the interface around the primary outcome:

- Make the decisive state and likely next action easy to find.
- Give supporting context less weight and offer a strong default with relevant
  alternatives available.
- Match interface complexity to task complexity: use tables for comparison,
  sequences for linear work, and spatial surfaces for spatial work.
- Prefer comprehension to compression; remove information that does not change
  a decision before shortening labels or hiding context.
- Disclose secondary detail progressively and label unfamiliar actions.
- Keep recurring targets stable during hover, selection, and live updates.
- Use decorative devices only when they support hierarchy, state, affordance,
  content, or brand meaning.

Complete this step when the primary outcome, action hierarchy, information
structure, component strategy, responsive behavior, and visual rationale are
explicit and consistent with both the brief and preservation contract.

## 5. Define state, transitions, and risk

Account for every applicable lifecycle state: initial, populated, loading,
progress, empty, first-use, partial, stale, offline, validation, error, retry,
recovery, success, disabled, permission-limited, conflict, optimistic update,
rollback, cancellation, expiry, and unmount.

For each visible condition, define one authoritative owner and make rendering,
layout, accessible description, and side effects consume the same derivation.
Define precedence when multiple statuses compete. Keep domain state, pending
attention, and decoration conceptually separate.

Give every control defined behavior. Show success after the operation is
confirmed. Distinguish draft, preview, saved, applied, published, partial, and
failed states. Keep the active item reachable through filters, pagination, and
collapsed groups. Derive empty states from domain truth, not only the rendered
slice.

Classify each mutation by reach, consequence, and reversibility:

- Apply local, reversible actions directly and offer undo when practical.
- For broad but reversible changes, expose scope and allow review.
- Before destructive, costly, externally visible, or hard-to-reverse actions,
  show the exact target, current reach, and consequence and require contextual
  confirmation.
- Make warnings actionable with recovery or an explicit continuation path.

Complete this step when every primary action has an owner, destination,
feedback, exit paths, failure behavior, recovery path, and verifiable final
state, and every omitted state is marked inapplicable with a reason.

## 6. Implement a vertical slice

Complete one usable path through the requested scope:

- Reuse tokens, components, product language, and interaction semantics.
- Apply the same eligibility and permission guards to every entry point for an
  action.
- Use semantic structure, non-nested interactive roles, accessible names,
  keyboard operation, visible focus, sufficient contrast and target size,
  reduced motion, and readable type.
- Give each continuous surface one owner for background, border, shadow, blur,
  clipping, and safe-area behavior. Remove obsolete local compensations when a
  shared primitive takes ownership.
- Treat overlays as systems: anchor, width, collision, clipping, focus, Escape,
  click-outside, scroll, and underlying-content occlusion.
- Define responsive constraints that prevent clipping, overlap, overflow, and
  layout shift at intermediate widths, not only named breakpoints.
- Exercise realistic content, long strings, empty data, extreme values, and
  localization pressure within the requested scope.

Complete this step when the primary task works in code for its normal path and
every applicable exceptional state defined in the previous step.

## 7. Verify with rendered evidence

Judge visual quality from the rendered artifact using the strongest capabilities
available. Static checks do not prove visual quality, responsive behavior, or
interaction correctness.

Use the product's supported viewports. If none are defined, inspect 375, 768,
and 1440 CSS pixels, an intermediate width around each layout transition, and
horizontal overflow at 320 pixels.

Before finishing:

1. Compare before and after using the same data, viewport, and theme.
2. Complete the primary flow with every supported input method.
3. Exercise every applicable state, transition, reverse action, and high-risk
   mutation.
4. Inspect hierarchy, alignment, spacing, clipping, overlap, wrapping, focus,
   hover, active, disabled, scroll behavior, and spatial stability.
5. Test small, intermediate, and large widths plus content extremes.
6. Check accessible names, focus order, contrast, semantics, reduced motion,
   forced colors, and platform or browser fallbacks when applicable.
7. Inspect overlays together with their trigger and underlying content.
8. Audit sibling component families for geometry, optical sizing, behavior, and
   token drift.
9. Check runtime errors and run relevant build, type, lint, and test validation.

Use screenshots for visual changes, short recordings for movement or timed
behavior, and target-device evidence for platform-dependent work. If target
hardware or a supported browser is unavailable, say `unverified` rather than
inferring success.

Record each applicable check as passed, failed, or unverified. For an unverified
check, perform the closest available inspection and state the limitation.

Complete this step when every preservation item and applicable surface-state
intersection has evidence. Correct in-scope failures or report a blocker; turn
review failures into prioritized findings.

## 8. Report the evidence

Lead with the outcome. State what changed or was found, the observed problem,
important design choices, affected surfaces or files, preservation results,
checks that passed, and anything failed or unverified.

Complete this step when the report is self-contained, every remaining unknown
is labeled, and every verification still feasible in the current task has been
performed.
