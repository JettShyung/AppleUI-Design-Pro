# Review, previews, and verification

## Review the experience and its implementation

Start from current screenshots, a runnable view, or relevant code; be explicit if
only code is available. Trace state and input paths before recommending a redesign.
Evaluate task clarity, navigation, hierarchy, type, spacing, component consistency,
materials, purposeful motion, accessibility, responsive layout, and real data states.
Avoid arbitrary numeric scores unless the user requested a rubric.

For each actionable finding, give location/evidence, user consequence, and the
smallest effective correction. A before/after/why table can clarify alternatives.
Do not report generic gradients, system fonts, or rounded corners as defects without
context. Review behavior, not personal preference alone.

## Useful preview matrix

| Dimension | Cases to select based on the change |
| --- | --- |
| Style | Default, each meaningful variant, parent cascade, local override |
| Content | Short, long, localized/RTL, empty, realistic dense content |
| State | Enabled, disabled, pressed/cancelled, selected, focused, loading/error |
| Appearance | Light/dark, busy/bright/dark background, contrast/transparency settings |
| Size | Small phone, narrow/wide window, large accessibility text, keyboard |
| Motion | Enter/exit, rapid repeat, interruption, release velocity, reduced motion |

Select relevant cases rather than taking the Cartesian product every time. SwiftUI
previews may share helper views with snapshots; keep state in an actual view. Flutter
widget tests should drive interactions and inspect semantics, not merely confirm
that a class name exists. Golden tests need known fonts, environment, and explicit
baseline review. Don't automatically re-record a changed baseline to make tests pass.

## Bundled examples

- [StyleDrivenCard.swift](../assets/StyleDrivenCard.swift): custom style environment,
  internal configuration, nested content type erasure, dynamically adapting body.
- [GlassActions.swift](../assets/GlassActions.swift): native controls, custom effect
  identity/container, older-runtime fallback, reduce-motion handling.
- [NativeSurfaces.swift](../assets/NativeSurfaces.swift): UIKit/WidgetKit API examples.
- [apple_ui_glass.dart](../assets/apple_ui_glass.dart) and
  [apple_ui_lens.frag](../assets/apple_ui_lens.frag): bounded Flutter refraction with
  explicit shader support, safe fallback, and accessibility inputs.
- [AppleUILens.metal](../assets/AppleUILens.metal) and
  [OwnedImageLens.swift](../assets/OwnedImageLens.swift): SwiftUI custom distortion
  for owned source content with matching circular corner geometry and declared
  maximum sample offset. Add the Metal file to the app target; this does not capture
  arbitrary sibling backdrops.
- [displacement.mjs](../assets/displacement.mjs): corrected map encoding and optical
  primitives; [math checks](../assets/displacement.test.mjs) validate real invariants.

Examples are independently adapted for this skill. Read deployment notes before
copying. Their small local constants are tuneable defaults, not mandatory design tokens.

## What each verification proves

Frontmatter/link validation proves discoverability and packaging, not design quality.
Swift typechecking and Flutter analysis catch API/type errors, not visual fidelity.
Widget/unit tests check the exercised behavior/math. Shader compilation checks the
shader program's validity, not background sampling in every composition.
Screenshots help assess geometry and contrast. Device interaction and profiling are
needed to assess gesture feel and frame cost. Report those levels separately.

For a UI demo requested by the user, first explore the flow, rehearse its input and
wait conditions, and record a coherent task. Use pacing and captions to explain real
behavior; do not record an untested script or manufacture successful states. A demo
recording workflow does not authorize publishing or sending it to another service.
