---
name: design-with-taste
description: Apply the restrained, utility-first interface taste inferred from public T3 Code design iterations. Use only when the user explicitly asks for T3 Code taste, Maria-rcks-style UI preferences, or this named taste profile.
---

# Design with Taste

Apply an opinionated taste overlay after usability constraints are known. This
skill chooses among quality-valid directions; it never overrides task success,
accessibility, product conventions, or the user's explicit visual direction.

Use `design-better-interfaces` as the quality gate when it is available. Read
[references/taste-profile.md](references/taste-profile.md) completely before
making visual decisions.

## 1. Anchor the interface

Identify the primary task, decisive state, established product language,
component families, density, and existing brand signals. Preserve the product's
information architecture unless changing it is part of the request.

Complete this step when the current hierarchy and the aspects allowed to change
are explicit.

## 2. Choose the quiet default

Start with the least ornamental composition that makes the hierarchy legible.
Prefer one calm shell, stable rows, semantic color, contextual controls, and
conventional affordances. Add emphasis only where it changes attention or
decision-making.

Complete this step when every visible border, surface, badge, color, effect, and
animation has one distinct job.

## 3. Run the subtraction pass

Remove duplicated context, nested containers without structural meaning,
always-visible exception controls, decorative status labels, and materials
owned by more than one layer. Restore a quiet label when subtraction makes a
zone or state ambiguous.

Complete this step when removing any remaining element would reduce
comprehension, state clarity, affordance, or brand identity.

## 4. Tune families, not isolated pixels

Compare sibling rows, buttons, menus, popovers, headers, and scroll regions.
Align geometry, optical weight, radii, icon sizing, transitions, and surface
ownership across the family. Preserve target positions across hover, selection,
and live updates.

Complete this step when siblings share intentional invariants and any exception
has a semantic reason.

## 5. Prove the taste in context

Render the primary flow with realistic data in light and dark themes and at
small, intermediate, and large widths. Inspect long content, hover, focus,
disabled, active, overlays, and reduced motion. Compare before and after using
the same data and viewport.

Revise when the result exhibits card soup, badge soup, double shells,
shape-shifting targets, decorative motion, weak light-theme contrast, or
unexplained gaps.

Complete this step when the interface is calmer without losing information,
recovery, platform fit, or task clarity, and every unverified environment is
named.

## Report

Describe the hierarchy retained, chrome removed, emphasis reserved, component
families aligned, and rendered evidence inspected. Distinguish product
requirements from choices made specifically by this taste profile.
