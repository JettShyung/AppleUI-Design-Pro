# Web glass and mobile interaction

Read [optical-core.md](optical-core.md) first. This route retains Emil's web
translation and childrentime's complete SDF/Canvas/SVG concept. It does not replace
the native/Flutter route when the user is building an app in those frameworks.

## Progressive visual implementation

Start with semantic HTML and a readable solid surface. Add translucency and CSS
backdrop blur when supported. For explicitly requested refraction, use a real source
sampling/displacement path. `backdrop-filter: blur(...)` alone is not a lens.
Support for blur does not prove support for an SVG `url()` inside backdrop-filter;
test target Safari/Firefox/Chromium versions, composition, and capture output.

For a SVG map pipeline, generate an RGBA map from the optical field. Use corrected
encoding from [displacement.mjs](../assets/displacement.mjs). A minimal filter graph
needs `feImage href="..." result="lensMap"`, then `feDisplacementMap
in="SourceGraphic" in2="lensMap" xChannelSelector="R" yChannelSelector="G"` with
the matching scale. A primitive's `id` alone does not name its result. Use consistent
filter units, local dimensions, unique stable IDs, and `color-interpolation-filters`
appropriate to the numeric channels. Leave foreground text outside the distortion.

Do not import the demo's huge z-index, fixed capsule radius, mouse-only div, or global
layout styles as production defaults. Its CSS, root app, responsive breakpoints,
React hooks, and configuration are a demonstration, not an Apple UI specification.
Its README browser support table is not evidence that backdrop SVG displacement is
fully supported on every listed browser.

## Correctness improvements over the demo

- Use the `2*M` displacement range and a zero-scale identity case. Reject non-finite
  samples and invalid dimensions. Avoid clipping the strongest vectors into 0/255.
- Derive SDF shape from actual width/height/radius. Maintain a single coordinate
  model for clipping, mouse input, filter map, and pixel density.
- Use Pointer Events/capture, cancellation, and keyboard alternatives. The original
  mousedown/mousemove implementation does not cover mobile touch.
- Use stable ID generation appropriate to SSR/hydration rather than random IDs on
  server and client. Keep multi-instance filters distinct.
- If geometry exceeds the viewport, resize/clamp the surface so the bounds remain
  feasible. Handle zero size, resize, scroll offsets, and mobile keyboard changes.
- Do not recompute O(width*height) arrays and a data URL on every mouse event.
  Cache static fields; coalesce dynamic updates to one frame and reuse storage.
- A shader that reads time needs an actual scheduled render loop and cleanup.
  The original mouse-proxy dirty tracking does not itself animate a ripple.
- Keep filter definitions in an appropriate rendering context; test whether hiding
  an ancestor prevents the browser from resolving its filter references.

## Native-feeling web platform layer

Use a proper viewport (`width=device-width, initial-scale=1, viewport-fit=cover`)
and pad controls with safe-area insets. Use `dvh` for a dynamic app shell and `svh`
for a stable first-screen surface where appropriate. Verify keyboard behavior; no
viewport unit alone guarantees the desired keyboard avoidance on every browser.

Gate hover effects by capability. Keep instant :active feedback and visible focus.
Use `touch-action: manipulation` for simple controls; on a custom horizontal drag,
allow vertical browser panning. Prefer native scroll snap when it solves the carousel.
Use overscroll containment only where nested app surfaces need it, not globally on
every document. Never disable zoom. On iOS-facing forms, sufficiently sized text
(commonly at least 16 CSS px) avoids unintended input zoom; set appropriate inputmode,
autocomplete, autocorrection, and enter-key behavior.

Limit user-select suppression and custom tap-highlight removal to controls with a
replacement feedback state. Keep prose, codes, addresses, and errors selectable.
Keep theme-color consistent with light/dark appearance. Handle touch and pointer
on hybrid devices without user-agent detection.

## Motion, accessibility, and testing

Use transform/opacity for low-cost movement where possible; they are not a guarantee
of zero rendering cost. CSS transitions may retarget; velocity-continuous dragging
needs explicit controller support. Scope will-change to genuine motion, don't put
it on every element. Reduce Motion removes large travel/elastic distortion, Reduce
Transparency uses solid material, and high contrast/forced colors preserves controls.

Test actual target browsers and mobile hardware when available. Desktop emulation
can check layout but does not establish touch feel, keyboard behavior, or optical
equivalence. Record what was inspected and the fallback when displacement is absent.
