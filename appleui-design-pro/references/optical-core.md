# Optical core — the central glass implementation model

Primary source: [childrentime's Chinese explanation](https://github.com/childrentime/liquid-glass/blob/345a3c4f3b07756239537f57ca88e29c0c04952b/LIQUID_GLASS_EFFECT_CN.md),
its English counterpart, and `src/LiquidGlass.tsx`. This section reconstructs the
technical model and corrects issues found in the example. It is a controllable
optical approximation inspired by Apple UI, not a reconstruction of Apple's private
renderer or a physically complete simulation.

## 1. Define what is being sampled

There are two different images: the background seen through glass, and the foreground
label/icon placed on the glass. Distort the background only. Keep actionable labels
sharp and accessible. Start with a grid, text, or an image behind the surface; blur
over a uniform color cannot demonstrate refraction.

Coordinate contract: `p` is an output pixel in local surface coordinates; `q(p)` is
the source position to sample from the background. `d(p) = q(p) - p` is a **sampling
offset**, not a promise that the visible source feature moves in the same direction.
A constant positive x offset samples to the right and shifts visible features left.
Document whether values are normalized UV, logical pixels/points, or texture pixels.

## 2. Shape with an SDF

For a rounded rectangle centered at the origin, with half-extents `b=(bx,by)` and
radius `r`:

```
q = abs(p) - b + r
sdf(p) = length(max(q, 0)) + min(max(q.x, q.y), 0) - r
```

Negative is inside, zero is the boundary, positive is outside. Clamp radius into
`0...min(bx,by)`. Width and height in this formula are **half-extents**, unlike CSS
width/height. Preserve aspect ratio in physical coordinates rather than stretching
a normalized square field. Do not reuse the demo's illustrative radius/UV constants
as universal geometry; they are not constrained to a conventional rounded rectangle.

Use the same shape and coordinate mapping for the visible clip, optical field,
highlight and shadow mask. A bounding rectangle alone is insufficient after
nonuniform scale: circular corners become elliptical. Decorative deformation may
leave hit geometry stable; map input into the presentation space deliberately.
Otherwise optical and visible edges separate.

## 3. Smooth the edge profile

Normalize distance across an edge band, clamp it to `[0,1]`, then apply
`h(t)=t*t*(3-2*t)`. This gives zero slope at both ends. The article's JavaScript
helper supports descending endpoints through its explicit arithmetic; **GLSL's
built-in `smoothstep` has undefined results when edge0 >= edge1**. In shaders use
ordered endpoints and `1-smoothstep(a,b,x)` to reverse the curve. Avoid equal edges.

One useful tunable approximation: zero displacement in the deep interior, a smooth
falloff near the rim, and normal-directed sampling around the edge. A center-scaling
mapping like the article's is another option. Keep the choice explicit: central
magnification, rim lensing, and animated ripple are different profiles.

The SDF gradient supplies the outward normal. Normalize only when its length is
nonzero; return zero displacement in degenerate/flat regions. Limit amplitude to
protect readability. Highlight and tint come after the refraction field, not instead
of it. Parameters should express surface width/height, radius, edge-band width,
refraction strength, tint, and optional interaction input.

## 4. Encode displacement correctly

SVG `feDisplacementMap` samples approximately:

```
sourceX = outputX + scale * (R - 0.5)
sourceY = outputY + scale * (G - 0.5)
```

For raw offsets in texture pixels, let `M=max(abs(dx),abs(dy))` over the map and use
`S=2*M`, `R=0.5+dx/S`, `G=0.5+dy/S`. Then both channels fit in `[0,1]` without
clipping. Quantize to bytes only at the end. B is unused and A is opaque. At `M=0`,
return neutral channels and `scale=0`; never divide by zero. A byte cannot represent
0.5 exactly, so neutral 128 with nonzero scale has a small quantization bias.

If offsets were calculated at `D` texture pixels per logical pixel, SVG scale in a
matching logical coordinate system is `S/D`. Keep `feImage` dimensions and filter
units consistent. If the map is lower resolution, convert vectors as well as positions.

**Correction:** the repository implementation halves `maxScale` and then divides
offsets by it; its article divides by the un-doubled maximum. Both can exceed the
channel range and clip the strongest vectors. The `2*M` convention above keeps the
encoding invertible within quantization error. The bundled encoder has executable
checks for zero displacement, negative offsets, extrema, and density conversion.

Also give `<feImage>` a **`result` name** and pass that result to `in2`; an SVG node
`id` alone is not a filter primitive result. This is another correction to the demo.

## 5. Composite the material

Render order: background → sampling/refraction → restrained diffusion/blur → optional
material tint → rim highlights and grounding shadow → crisp semantic foreground.
Use clipping/filter bounds large enough for the intended samples but small enough
to avoid full-screen work. Prevent transparent/black fringes from out-of-bounds
sampling: expand source coverage or specify/clamp sampling deliberately.

Apple's native material supplies adaptive lighting, foreground contrast, and other
behaviors beyond this approximation. A custom implementation must choose its own
contrast and accessibility strategy. Do not claim automatic adaptive shadows or
physically accurate light transport just because an SDF is present.

## 6. Bind interaction without making it slow

Track drag offset in local coordinates; do not snap the grabbed point to the center.
Keep direct movement 1:1, use velocity-aware settling on release, and allow
interruption. Hover-lighting can be smoothed; the dragged surface must not lag.
Update a static map on geometry/material changes, not every pointer event. If the
field uses pointer or time input, update at most once per displayed frame, pause
offscreen, and reuse allocations. A time expression alone does not schedule frames.

Use native/Cupertino/HTML control semantics around decorative glass. Add keyboard or
accessible adjustment for essential drag operations. Cancel on lost pointer, removal,
or app interruption. Reduced motion disables elastic distortion and autonomous
ripples; reduced transparency uses a readable solid/frosted replacement.

## 7. Renderer mapping

| Layer | SwiftUI / UIKit | Flutter | Web |
| --- | --- | --- | --- |
| Normal app chrome | Native glass APIs | Supported Cupertino controls; explicitly scoped material approximation or native integration | Semantic controls with progressive visual enhancement |
| Shape | Shape / native corner configuration | ClipRRect / Path / shader SDF | CSS clip + matching SDF |
| Custom source image lens | Supported SwiftUI shader effect on owned source content | FragmentProgram sampling an explicit image texture | Canvas-generated map + SVG backdrop displacement when supported |
| Background of arbitrary app UI | Native material; custom shader cannot freely sample unrelated views | BackdropFilter blur is supported; refraction needs a supported backdrop shader path or explicit source capture | SVG `url()` backdrop filtering varies by engine |
| Interaction | Native control/gesture + spring | Cupertino control + gesture arena + controller | Pointer Events/capture + animation |

Do not introduce per-frame screenshot readback to fake arbitrary-background refraction
without measuring its cost and accepting its limitations. For native embedding in
Flutter, verify whether the native material can actually sample Flutter-rendered
content in the chosen composition; a platform view is not a guaranteed magic lens.

For an owned SwiftUI image, pair [OwnedImageLens.swift](../assets/OwnedImageLens.swift)
with [AppleUILens.metal](../assets/AppleUILens.metal) in the same app target.
`maxSampleOffset` must bound the shader's actual sampling displacement; when strength
changes, update that bound too. Keep the circular rounded-rectangle clip consistent
with this SDF; a continuous-corner shape uses different geometry. Add foreground
controls after the source effect. Native chrome usually remains better served by
the system glass APIs.

## Acceptance checks

- Grid lines bend at the intended rim, with a readable center and smooth transition.
- Labels are not warped; dense, bright, dark, and mixed backgrounds remain legible.
- Zero-strength rendering is an identity mapping; no NaN, channel clipping, or seams.
- Geometry changes preserve corner shape, sampling scale, and touch bounds.
- Drag, cancellation, reversal, pointer/touch/keyboard, and accessibility alternatives work.
- Record renderer, SDK/browser, frame cost, and fallback. “Code compiles” is not a
  claim of optical equivalence to native Liquid Glass.

Related: [web](web-glass.md), [Flutter](flutter.md), [native glass](liquid-glass.md),
[tested math asset](../assets/displacement.mjs).
