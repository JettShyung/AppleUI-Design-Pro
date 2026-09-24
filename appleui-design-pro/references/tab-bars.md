# Tab Bar design — preview, commit, and glass

Use for primary navigation bars and draggable selection lenses. Preserve the app's
actual destinations, order, badges, per-tab navigation stacks, and selected-state
ownership. A Tab Bar is navigation; an intermediate lens position is not a route.
Read [interaction and motion](interaction-motion.md) and, for glass,
[the optical core](optical-core.md) plus the renderer's reference.

## Choose the implementation

- **Pure Flutter / copy-and-use template:** read the
  [Flutter Tab Bar template](flutter-tab-bar-template.md), copy its component, and
  adapt its working demo. It includes stretch motion, release-only drag selection,
  optional scroll-to-minimize, theme, badges, keyboard and semantic controls.
- **Native iOS glass from Flutter:** use the template reference's
  [package route](flutter-tab-bar-template.md#when-native-ios-glass-is-required).
  Inspect the installed package version before choosing a bridge or patch. A
  pure Flutter request does not authorize silently replacing it with native views.
- **Native SwiftUI/UIKit project:** use the system tab container and public APIs;
  keep this reference's state/input/verification rules.
- **Existing optical defect:** isolate the renderer/composition first using the
  held-edge diagnostic below. Do not replace a working bar just to adopt a template.

## Establish the observed contract

Inspect the reference at rest, pointer down, slow drag, stationary hold, reversal,
release, cancellation, and rapid re-grab. Watch the page as well as the bar: a still
image cannot distinguish release commitment from a dwell timer. Record the app/OS,
input method, and observed phases. Mirroring or remote-control latency is not an
animation constant. If holding cannot be observed, label it unverified; honor an
explicit user requirement without inventing an observation.

Match geometry and light as a system: rail, selection shape, insets, item centers,
press lift, edge highlights, tint, shadow, and settling. Preserve the product's own
icons and number of destinations unless their replacement is requested. Do not
infer Apple's private shaders, spring coefficients, or duration from a screenshot.

Reference observation (GitHub on iPhone Mirroring, 2026-09-21): post-release
frames showed a wider raised translucent capsule, local glyph magnification and
prismatic rim, then a pale neutral idle pill with accent icon and label. Neighboring
icons/labels covered by the moving lens could both carry accent color. The available
drag tool was atomic, so a stationary held finger was not independently observed;
the no-page-change-during-drag contract came from the user's explicit report. These
are scoped visual observations, not Apple's public API or shader specification.

## Keep navigation separate from preview

For a release-to-select reference, keep three concepts distinct:

- **Committed index:** owned by the app/router; selects the page and the semantic
  `selected` state. Only an accepted activation changes it.
- **Preview position:** local continuous position of the lens while dragging.
  A rounded preview index may color/highlight a candidate, but never opens a page.
- **Presentation:** the currently rendered position/activity during press or
  settling. Re-grab from this value, not the previous destination.

A small widget-local state machine is enough; reuse the existing route owner and
animation controllers. Trace all callback callers before changing the behavior.
A route callback also triggers page lifecycle, loading, playback, analytics, and
haptics; filtering only the visible page leaves these side effects wrong.

| Event | Lens / preview | Navigation |
| --- | --- | --- |
| Down | Capture current presentation and grab offset; begin press feedback | Unchanged |
| Horizontal drag accepted | Follow local movement directly; clamp to supported travel | Unchanged |
| Stationary hold | Retain preview; velocity-dependent lighting may decay | Unchanged; no dwell timer |
| Valid release | Choose the final eligible target and settle toward the accepted selection | Commit at most once |
| Tap / keyboard / accessibility activation | Animate from current presentation | Activate through the same commit path |
| Cancel / rejected gesture / interrupted input | Return to the current committed selection | No preview commit |

Do not wait for a decorative settle animation to finish before committing an
otherwise accepted release. If the actual reference demonstrably commits at a
different phase, use that contract and test it explicitly. Re-tapping the selected
tab may scroll to top or pop its stack only when the product already defines it.

The minimal event split is:

```text
down:    grab = localX - displayedLensCenter; stop current settle
move:    previewCenter = clamp(localX - grab); repaint the bar
release: requestSelection(nearestEligibleSlot(previewCenter)) once
         settle from displayedLensCenter to acceptedSelectionCenter
cancel:  settle to committedSelectionCenter without requesting selection
```

Keep the grab point stable even at the selected pill's edge. Tap targeting uses the
hit-tested item; dragging uses its continuous lens position. Crossing multiple tabs
must not emit multiple route callbacks. Do not apply pager/fling momentum that
skips destinations unless the reference calls for it. Resolve RTL/visual ordering
through the same mapping used to draw, hit-test, and expose semantics.

The parent may reject navigation, select another route, or change eligibility.
Reconcile with its accepted index; do not leave a local selected index in conflict
with the displayed page. Cancel stale callbacks on re-grab, disposal, interruption,
or external navigation. Geometry changes mid-drag need rebasing or cancellation,
not a jump through old coordinates.

## Motion, light, and compositing

Direct manipulation follows input 1:1 after the gesture is accepted. Animate press
lift, optical activity, and release settling independently from page selection.
Light can ease or decay when movement stops while the finger remains held; that
must never become an implicit navigation timer. Settling must be interruptible.

Use one adaptive material for the rail and a purposeful selection treatment. With
native Liquid Glass, prefer system-supplied material/light behavior. Fixed opaque
fills or exaggerated rims can hide its adaptive range. With a custom lens, align
its SDF, clip, highlight and shadow; test refraction against structured content.
A shadow indicates elevation, while the bright rim describes a surface edge.
Neither alone establishes actual refraction or native equivalence.

A transparent backdrop lens must not sample its own edge decoration. Paint the
shadow and highlight after refraction, and clip an offset shadow outside the
**unshifted** lens silhouette. An outer blur alone is insufficient: its cutout
moves with the shadow offset, so it can still paint inside the actual lens. Do not
hide a sampled shadow with an opaque white fill. Verify with a uniform background
as well as structured content.

Keep control labels legible and the semantic/hit-test layer stable. A reference may
visually magnify icons through a moving lens: treat that as an explicit decorative
sampling layer, excluded from semantics, rather than moving or duplicating controls.
When the reference accents everything beneath the lens, use a clipped accent-color
visual copy of eligible items, with the inactive copy excluded from the same
coverage; do not color only the committed tab or mutate the
route just to tint the nearest candidate. Geometry determines optical coverage;
the committed index still determines the page and semantic selection. A transient
rim and local neutral idle pill are distinct from a fixed coating on the whole rail.
Keep a sharp readable center and avoid doubly composited glyphs. In mixed
native/Flutter composition, see the scoped replacement-blend guidance in
[system glass preferences](system-glass-preferences.md#moving-lens-ghosting-in-flutternative-composition).
Do not change a shared glass renderer just to repair one navigation composition.

## Platform implementation and accessibility

SwiftUI/UIKit: start with the project's native TabView/UITabBarController and its
public customization. Verify actual SDK/runtime behavior before replacing a system
control. Native material plus a custom gesture is still custom navigation behavior.

Flutter: preserve the existing Cupertino/tab/router structure. Cupertino rendering
does not automatically inherit new UIKit Tab Bar behavior. Isolate per-frame lens
updates from the page subtree; never drive PageController or the app's selected
index from drag updates. Reuse installed/native integration only where it can
sample the intended layers and preserve input, semantics, and lifecycle.

Keep one semantic node per tab with label, action, badge context, and committed
selection. Decorative duplicated icon layers are excluded. Every destination must
remain reachable by a normal tap and assistive activation, without requiring a
drag. Respect text scaling, contrast, Reduce Transparency and Reduce Motion live;
reduced motion removes elastic/distortion animation, not selection or feedback.
A reference's compact default height is not a ceiling for scaled content: verify
icon-plus-label layout at the supported largest text setting before reducing rail
height. Matching the accent treatment also requires checking the chosen brand hue;
a bright icon accent may need a darker label variant on a pale selection surface.

## Checks that catch the real failures

Use the existing test framework, not a new component library. A focused gesture test
should cross several tabs and hold beyond the animation duration, asserting zero
navigation callbacks and an unchanged page/semantic selection; release then emits
exactly one accepted selection. Also cover cancellation, an off-center grab,
mid-settle re-grab, external selection, and accessible tap activation as relevant.

Render the real bar in light/dark and large text. Inspect both drag directions,
fractional positions, stationary hold and release for ghosted glyphs, clip seams,
incorrect foreground colors and fixed overlays hiding native material. Flutter
widget tests do not render UIKit glass; Flutter image capture alone excludes native
platform views. Record full simulator/device composition for optical claims and
real hardware profiling for performance claims. Report source, automated behavior,
rendered appearance and device feel separately.


## Diagnose a held edge before tuning its appearance

Wait past lift and velocity decay while the pointer remains down. Compare the
complete native composition with a Flutter-only capture when platform views are
present; those two images contain different layers. A stationary double contour
is not evidence of animation lag.

| Observation | Isolate | Likely correction |
| --- | --- | --- |
| Original and displaced glyph strokes coexist | Sparse transparent glyph, displaced opaque/clear pixel assertions | Remove overlapping representations; use replacement compositing only at the affected lens boundary |
| Dark/color dots at transparent glyph edges | One-color input; inspect straight RGB where alpha is meaningful | Do not combine differently premultiplied RGB channels with one unrelated alpha; fade dispersion where coverage is too low to unpremultiply reliably |
| Grey strip or second contour appears inside a clear held capsule | Uniform white source, sample an empty interior band away from rim/icons | Remove shadow/highlight from the refraction input; paint afterward with an exterior mask |
| Rim and refraction separate after size/transform changes | Compare clip, optical field and painter in the same final coordinate space | Preserve the same corner shape/aspect through transforms, not only the bounding rectangle |
| Extra border appears only in one renderer branch | Toggle native/fallback material without changing geometry | Check duplicate fallback strokes and whether a native rail edge is actually present in the sampled texture |

Chromatic sampling uses premultiplied textures. Recover a channel with its own
sample alpha, then premultiply the result by a deliberate common coverage. Avoid
dividing by nearly zero alpha; low-coverage samples should converge to the central
sample. An opaque-color test cannot catch this failure. Keep an executable test
that demonstrably failed before the fix; a generic icon screenshot that already
passed is not regression evidence.

For whole-bar feedback, animate the decorative rail, content and lens together;
keep hit targets, focus and committed semantics stable. Reuse the existing activity
clock where it preserves interruption continuity. Nonuniform scale makes circular
arcs elliptical: a circular SDF rebuilt from a transformed bounding box no longer
matches the painted clip. Use a common canonical coordinate space or retain a
shape-preserving transform. Do not repair geometric disagreement with thicker rims.

## Historical calibration — scoped custom-renderer example

This is a historical custom-renderer record, superseded in that product by a native
package integration. It is **not the current template specification**. The data
comes from a five-item Flutter implementation checked on iPhone
18 Pro / iOS 27 with Impeller and a native UIKit rail, 2026-09-21. It is a tunable
example, **not a GitHub/Apple measurement or a universal Tab Bar preset**. Logical
points, durations and renderer-specific blur values must retain their units.

| Property | Example value / rule |
| --- | --- |
| Rail / visual slot height | 56pt / 64pt at default text size |
| Text scaling | Actual rail height `max(56, scaled(10.5) + 37)`; checked at 200%/300% |
| Horizontal safe inset / inner item inset | max(20pt, safe inset) / 6pt |
| Idle capsule | 48pt high, 1.06 × item width; neutral fill light `#000000` alpha 0.078, dark `#FFFFFF` alpha 0.122 |
| Held capsule | 1.24 × item width, 1.10 × actual rail height; same centre as presentation slot |
| Lift / route slide / settle / lighting decay | 70 / 380 / 180 / 140 ms; durations are separate roles |
| Whole-bar response | Peak up 1.6pt, uniform scale 1.02; circular clip and optical field preserve the same shape |
| Rim | 1pt inset stroke, directional neutral highlight; not a second material fill |
| Shadow | Black alpha 0.12, offset (0,4)pt, Flutter BoxShadow blurRadius 12; painted after refraction and clipped outside the actual silhouette |
| Activation | Drag/hold preview only; valid release once; cancellation none; tap and assistive activation use the same route owner |
| Visual accessibility | Reduced Motion removes deformation; higher contrast/reduced transparency replace optical rendering with a readable solid treatment |

Retain renderer/OS, actual input method, text scale, source/automated/rendered
verification levels and unresolved limits with a calibration record. In this case,
mirrored reference dragging was atomic, while the app's held-state checks used a
real simulator test harness. These are different kinds of evidence. Update the
record when measurements or implementation change; do not promote an unverified
approximation into a platform rule.


Held-edge regression in this example: the previous offset outer blur was painted
before the lens. A white empty interior band fell to RGB 241/255 under stationary
hold; moving the exterior-masked shadow after refraction restored 255/255 while
retaining exterior elevation. This proves removal of that sampled shadow, not
pixel equivalence to the reference app. The earlier independent transparent-color
check caught 529 invalid pixels in 5,665 covered samples and reached zero after
alpha-safe dispersion; edge geometry and alpha contamination require separate tests.
