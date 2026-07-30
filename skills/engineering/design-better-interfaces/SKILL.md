---
name: design-better-interfaces
description: Product-interface quality gate for evidence-based UI decisions. Use when designing or implementing a user-facing UI, reviewing its usability, or refining an existing interface.
---

# Design Better Interfaces

Treat an interface as a complete product workflow. Use the quality gate below
as the single standard for design decisions and completion.

Use the inspection, rendering, browser, screenshot, accessibility, and test
capabilities available in the current environment.

## Route the request

Choose one branch and follow its path:

- **Review or diagnose:** Brief → Inspect → States/Risk → Verify → Report.
  Leave the artifact unchanged. Finish with every applicable gate criterion
  marked passed, failed, or unverified with evidence and findings ordered by
  impact.
- **Design or explore:** Brief → Inspect when an artifact exists → Decide →
  States/Risk → Report. Produce one coherent direction by default. When
  alternatives are requested, make them differ materially in hierarchy,
  interaction, or layout. Finish when every direction meets the Decide and
  States/Risk criteria, tradeoffs are explicit, and one is recommended unless
  the user requests a neutral comparison.
- **Build, refine, or fix:** Brief → Inspect → Decide → States/Risk → Implement
  → Verify → Report. Finish when the requested scope is implemented, the
  primary task succeeds under tested conditions, and every applicable gate
  criterion is recorded. Report external blockers to a passing result.

Treat external publication as a separate action that requires an explicit user
request.

## 1. Establish the brief

Resolve from available evidence:

- user, primary task, frequency, cost of error, and visible success;
- domain, brand, tone, and expected density;
- affected surfaces, target sizes, design system, and technical constraints;
- data states, permissions, and content extremes.

Investigate the product and repository before asking questions. Ask when a
missing choice would materially change the product; otherwise state a
reasonable assumption.

Complete this step when every item is resolved, marked inapplicable, or covered
by an explicit assumption.

## 2. Inspect the product

For an existing product:

1. Read project instructions and walk the affected flow.
2. Inventory tokens, components, typography, spacing, density, navigation,
   vocabulary, and interactions.
3. Capture a visual baseline at relevant sizes.
4. State the observed problem in user-visible terms.

Reuse suitable conventions. Replace an inaccessible or harmful convention with
the closest coherent alternative.

For a greenfield interface, derive the visual direction from the audience,
domain, content, task, and expected density.

For existing work, complete this step when the current flow, applicable
conventions, observed problem, and visual baseline are recorded; mark the
baseline unverified when the environment cannot render it. For greenfield work,
complete it when the direction is anchored in every brief item and
existing-artifact checks are marked inapplicable.

## 3. Decide with the quality gate

Apply this priority order:

1. The user can complete the primary task.
2. The state, hierarchy, and next action are clear.
3. Risk, failure, and recovery are represented honestly.
4. The result is coherent with the product and design system.
5. The result is accessible and robust across supported sizes and inputs.
6. The visual craft is deliberate and appropriate to the domain.

A lower-priority improvement passes only while every higher-priority criterion
remains satisfied.

Shape the interface around the primary outcome:

- Make the decisive state and most likely next action easy to find.
- Give supporting context less weight and offer a strong default with relevant
  alternatives available.
- Match interface complexity to task complexity: use tables for comparison,
  sequences for linear work, and spatial surfaces for spatial work.
- Prefer comprehension to compression; remove information that does not change
  a decision before shortening labels or hiding context.
- Disclose secondary detail progressively and label unfamiliar actions.
- Use decorative devices from the brand language to support hierarchy, state,
  affordance, or content.

Complete this step when the primary outcome, action hierarchy, information
structure, component strategy, responsive behavior, and visual rationale are
explicit and consistent with the brief.

## 4. Define states and risk

Account for every applicable lifecycle state: initial, populated, loading,
progress, empty, first-use, partial, stale, offline, validation, error, retry,
recovery, success, disabled, permission-limited, conflict, optimistic update,
and rollback.

Give every control defined behavior. Show success after the operation is
confirmed. Distinguish draft, preview, saved, applied, published, partial, and
failed states.

Classify each mutation by reach, consequence, and reversibility:

- Apply local, reversible actions directly and offer undo when practical.
- For broad but reversible changes, expose scope and allow review.
- Before destructive, costly, externally visible, or hard-to-reverse actions,
  show the exact target, reach, and consequence and require contextual
  confirmation.

Complete this step when every primary action has a destination, feedback,
failure behavior, recovery path, and verifiable final state, and every omitted
state is marked inapplicable with a reason.

## 5. Implement a vertical slice

Complete one usable path through the requested scope:

- Reuse tokens, components, product language, and interaction semantics.
- Use semantic structure, accessible names, keyboard operation, visible focus,
  sufficient contrast and target size, reduced motion, and readable type.
- Define responsive constraints that prevent clipping, overlap, overflow, and
  layout shift.
- Exercise realistic content, long strings, empty data, extreme values, and
  localization pressure within the requested scope.

Complete this step when the primary task works in code for its normal path and
every applicable exceptional state defined in the previous step.

## 6. Verify the quality gate

Judge visual quality from the rendered artifact using the strongest
capabilities available.

For responsive web interfaces, use the product's supported viewports. If none
are defined, use 375, 768, and 1440 CSS pixels and check for horizontal overflow
at 320 pixels.

Before finishing:

1. Complete the primary flow with pointer input and keyboard input.
2. Exercise every applicable state and high-risk action.
3. Inspect hierarchy, alignment, spacing, clipping, overlap, wrapping, focus,
   hover, active, disabled, and scroll behavior.
4. Check accessible names, focus order, contrast, semantics, and reduced motion
   with available automated and manual methods.
5. Check runtime errors and run relevant build, type, lint, and test validation.
6. Compare with an available baseline and revise every problem found within
   scope.

Record each applicable check as passed, failed, or unverified. For an unverified
check, perform the closest available inspection and state the limitation. A
claim of responsiveness, accessibility, polish, or correctness requires the
corresponding check to pass.

Complete this step when every applicable gate criterion has a recorded result.
For build work, correct in-scope failures or report a blocker. For review work,
turn failures into prioritized findings.

## 7. Report the evidence

Lead with the outcome. State what changed or was found, the observed problem,
important design choices, affected surfaces or files, checks that passed, and
anything failed or unverified.

Complete this step when the report is self-contained, every remaining unknown
is labeled, and every verification still feasible in the current task has been
performed.
