# System Liquid Glass preferences

Use this workflow when a user expects all glass to follow an OS appearance slider,
or reports that only some components change or that the range looks too small.

## Trace the actual material

Search every glass surface, native platform view, BackdropFilter, blur, shader,
fixed translucent fill, and explicit native opt-out. Include tab bars at rest and
while dragging, expanded/collapsed headers, search/input fields, transient notices,
sheets, chat accessories, media controls, and wide-layout navigation. Trace shared
builders and their callers before patching pages individually.

Record which layer supplies each component's shape, background sampling, diffusion,
tint/rim, and foreground. A native pill can follow the OS while its surrounding
Flutter header remains fixed. An optical shader may bend real content but still
have no connection to the user's system preference.

## Use the system's actual range

Check the installed SDK and current official documentation for the target OS.
In the Xcode 27.0 SDK inspected on 2026-09-20, UIKit publicly exposed regular/clear
UIGlassEffect styles, tintColor and isInteractive, but no continuous slider value
or slider-change notification. This is a versioned observation, not a permanent
claim about future SDKs.

Prefer the existing native integration and adaptive regular material when the
requested behavior is the system's own continuous range. Do not invent a public
API, read private preference keys, poll hidden settings, quantize into clear/regular,
or present custom blur constants as Apple's slider values. If a future public
scalar exists, consume it in one shared material resolver and test intermediate
values as well as endpoints. An app-specific slider is a different feature and
should only be added when requested.

Remove fixed fills, gradients, strong rims and child backgrounds that obscure the
native range. A transparent native surface behind an 86%-opaque input is still
visually almost opaque. Preserve focus rings, selection state, readable foregrounds
and accessibility backing; those serve a separate purpose.

Use one material for a composed control region. When a header already supplies
native glass, its embedded controls should reuse that background instead of stacking
another glass view. Preserve independent actions and their semantics. Custom lens
displacement can remain an interaction layer if it samples correctly and doesn't
add a second fixed diffusion/tint layer. Record any renderer change explicitly;
a prior custom-shader pixel test does not verify a new native composition.

## Flutter bridge details

Keep labels and hit targets outside the material filter and exclude decorative
platform views from semantics. Match the effect view itself to the clip geometry,
including corner masks for asymmetric sidebars; rounding only a parent can crop
a square optical rim. Check modal/offstage composition and disposal.
Platform-view creationParams do not update an existing native view: use a supported
update channel for frequent geometry changes; a stable key reflecting infrequent
creation-only settings can recreate it for appearance/configuration changes.
Do not recreate platform views on every animation frame.

Keep Reduce Transparency, Increase Contrast and Reduce Motion independent of the
appearance slider. Solid, readable accessibility fallbacks override personalization.
Check changing them with the control already mounted and restoring native glass.

## Fixed headers over scrolling text

Choose scroll continuity from the user's reference before choosing a viewport.
Clipping the list below a fixed header prevents overlap, but also changes the
interaction: it is wrong when content is meant to flow beneath the controls.
Initial top padding alone is insufficient in either case. Independent regions
can use a clipped viewport; an underlapping list needs a deliberate scroll edge.

For a progressive edge, keep the scroll viewport behind the header and apply a
spatially increasing blur plus a smooth fade to the scrolling content. Derive the
transition from the actual header height and safe-area inset, including large
text; keep the body below the transition unchanged. Blur/fade the owned content,
not the whole composed screen, so titles, native materials and hit targets stay
sharp. Avoid stacked glass slabs, per-control opaque coatings, discrete blur bands
and delayed scroll animations. Prevent obscured rows from receiving gap taps.

In Flutter, prefer an existing scroll-edge implementation when it meets the
reference. If variable blur needs a shader, ImageFiltered can sample its own child
without CPU captures. Check shader-filter support; an unsupported renderer may
fall back to a continuous fade, but do not call it variable blur. Keep this
content treatment distinct from native Liquid Glass and its system slider.
Reduce Transparency and Increase Contrast override it with readable solid backing.

Validate a populated list in motion, header actions, control gaps, light/dark,
large text and relevant widths. Inspect actual label clipping: no layout exception
does not prove text is fully visible. For custom variable blur, structured stripe
or text pixels should lose contrast progressively toward the top while the clear
region is unchanged; a fade-only test does not prove changing blur radius. Capture
the native simulator/device composition too. Debug rendering does not prove frame
cost on hardware. See Flutter's [ImageFilter.shader contract](https://api.flutter.dev/flutter/dart-ui/ImageFilter/ImageFilter.shader.html).

## Moving-lens ghosting in Flutter/native composition

When a custom interaction lens intentionally displaces controls, native platform
views can leave a transparent Flutter overlay. Painting displaced RGBA pixels with
srcOver may keep undistorted glyphs visible underneath. Check blend semantics
before reducing refraction or deleting aligned foreground copies. For a lens that
replaces its sampled region, evaluate BlendMode.src with the actual clip and
transparent backdrop; do not change every glass filter globally. A displaced
stroke on a transparent layer is a small regression: the new stroke remains,
while pixels vacated by it must become transparent.

Exercise both directions, fractional positions and release on the actual renderer.
RenderRepaintBoundary.toImage can verify Flutter glyph/shader pixels but excludes
UIKit platform-view material. Also capture the simulator/device composition;
remove test pointer crosshairs before judging glyphs. See Flutter's
[BackdropFilter blend-mode guidance](https://api.flutter.dev/flutter/widgets/BackdropFilter-class.html).

## Prove coverage and range

Use the same structured backdrop at the system slider's minimum, midpoint and
maximum, without restarting the app. Compare static and dragging navigation,
expanded/collapsed headers and representative transient/media controls. Include
light/dark and accessibility overrides. Inspect both material/background changes
and sharp, legible foregrounds; a uniform background can hide real differences.

Unit/widget tests can verify renderer selection, native view count, configuration
updates, semantics and solid fallbacks. They do not render UIKit glass. Capture the
actual simulator/device composition for visual claims. If UI control or the system
slider cannot be exercised, record that exact gap rather than claiming full-range
verification. Debug screenshots do not prove real-device frame cost.

Sources: [Apple Materials](https://developer.apple.com/design/human-interface-guidelines/materials),
[UIGlassEffect](https://developer.apple.com/documentation/uikit/uiglasseffect),
and the installed UIKit headers; application findings must be verified anew.
