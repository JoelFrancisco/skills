---
name: design-better-interfaces
description: Design, implement, review, and refine product interfaces around user outcomes, existing design systems, complete interaction states, risk-proportional friction, accessibility, responsiveness, and rendered evidence. Use for frontend UI work, interface redesigns, usability reviews, visual polish, product flows, dashboards, forms, onboarding, or any task where an agent must build or assess a user-facing interface.
---

# Design Better Interfaces

Treat an interface as a complete product workflow, not a screenshot. Optimize,
in order, for task completion, clarity, coherence with the product,
accessibility, visual craft, and technical robustness.

Use whatever inspection, rendering, browser, screenshot, accessibility, and
test capabilities the current environment provides. Never require a particular
harness or tool by name.

## Set the operating mode

Classify the request before acting:

- **Review or diagnose:** inspect the relevant product and report findings; do
  not implement changes.
- **Explore:** produce distinct directions only when the user asks for
  alternatives. Otherwise choose one coherent direction and explain the
  decision briefly.
- **Build, change, or fix:** complete the cycle from investigation through
  implementation and rendered verification.

Stay within the requested layer. Do not silently turn a review into a redesign
or a local implementation into an external publication.

## Establish the product brief

Resolve the smallest useful brief from available evidence:

- primary user and primary task;
- task frequency and cost of error;
- user-visible success condition;
- product domain, brand, tone, and expected density;
- affected surfaces and target devices or viewports;
- existing design system, components, and technical constraints;
- relevant data states, permissions, and content extremes.

Discover answers from the product and repository before asking. Ask only when a
missing choice would materially change the product; otherwise make a reasonable
assumption and state it.

## Inspect before designing

For an existing product:

1. Read the applicable project instructions.
2. Inspect the running interface and walk the affected flow.
3. Inventory tokens, components, typography, spacing, density, navigation,
   vocabulary, and interaction patterns.
4. Capture a visual baseline at the relevant sizes when possible.
5. Identify the observed problem before proposing a solution.

Preserve suitable existing conventions. Do not preserve a pattern that is
demonstrably inaccessible, inconsistent, or harmful merely because it already
exists.

For a greenfield interface, derive a deliberate visual direction from the
audience, domain, content, and task instead of falling back to generic
dashboard or landing-page patterns.

## Design around the outcome

Organize each surface around one primary user outcome:

- Make the decisive state and most likely next action easy to find.
- Give supporting context and alternatives less visual weight.
- Offer a strong default for the common case without hiding relevant choices.
- Match interface complexity to task complexity.
- Use a table for comparison, a form or sequence for linear work, and a spatial
  surface for spatial work; do not turn every task into a dashboard.

Optimize for comprehension, not maximum compactness:

- Remove information that does not change a decision before abbreviating
  labels, shrinking text, or hiding context.
- Use progressive disclosure for secondary detail.
- Use icon-only controls only for universally understood actions in a clear
  context; label unfamiliar actions.
- Add helper text only when it reveals a constraint, consequence, or condition
  the control cannot communicate by itself.

Use decoration intentionally. A card, gradient, shadow, pill, illustration,
animation, or visual effect must support hierarchy, state, affordance, content,
or an established brand language. Do not use common generated-UI motifs as a
substitute for a design direction.

## Design complete interaction states

Treat the applicable states as part of the feature:

- initial and populated;
- loading and progress;
- empty and first-use;
- partial, stale, or offline;
- validation and error;
- retry and recovery;
- success and confirmation;
- disabled and permission-limited;
- conflict, optimistic update, and rollback.

Do not add a control without defined behavior. Do not show success before the
operation is confirmed. Make draft, preview, saved, applied, published, partial,
and failed states unambiguous.

Scale friction with risk:

- Apply local, reversible actions directly and offer undo when practical.
- For broad but reversible changes, expose scope and allow review.
- Before destructive, costly, externally visible, or hard-to-reverse actions,
  show the exact target, reach, and consequence and require contextual
  confirmation.
- Avoid generic confirmation dialogs for low-risk actions.

## Implement a vertical slice

When implementation is requested, complete a usable path rather than a visual
shell:

- reuse design tokens and components before adding one-off primitives;
- preserve product language and established interaction semantics;
- use semantic structure, accessible names, keyboard operation, and visible
  focus;
- preserve contrast, target size, reduced-motion behavior, and readable type;
- define responsive constraints that prevent clipping, overlap, overflow, and
  layout shift;
- exercise realistic content, long strings, empty data, extreme values, and
  localization pressure where relevant;
- avoid unrelated features or decorative scope expansion.

Every primary action must have a destination, feedback, failure behavior,
recovery path, and verifiable final state.

## Verify the rendered result

Never infer visual quality from source code alone. Render and inspect the real
artifact with the strongest capabilities available.

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
6. Compare with the baseline and revise problems found.

If a check cannot run, mark it as unverified and perform the closest available
inspection. Never claim that an interface is responsive, accessible, polished,
or working without evidence.

## Evaluate in priority order

Judge design decisions using this order:

1. Can the user complete the primary task?
2. Is the state, hierarchy, and next action clear?
3. Does the interaction handle risk and failure honestly?
4. Is it coherent with the product and design system?
5. Is it accessible and robust across supported sizes and inputs?
6. Is the visual craft deliberate and appropriate to the domain?

Do not accept a visual improvement that regresses a higher-priority criterion.

## Report with evidence

Lead with the outcome. State:

- what changed or what was found;
- which observed problem motivated the decision;
- the important design choices;
- the surfaces or files affected;
- which visual, interaction, accessibility, and code checks passed;
- what failed or remains unverified.

Do not make the user reconstruct the result from progress updates, and do not
end by promising verification that can still be performed in the current task.
