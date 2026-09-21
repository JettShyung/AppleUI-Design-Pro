# Native Liquid Glass

Read [the optical core](optical-core.md) first for glass work. The native framework
provides material behavior; use its design parameters without pretending to tune its
private SDF or per-pixel shader. SwiftUI/UIKit examples here derive from ECC, with
SDK-checked corrections and Apple material-role guidance.

## Decide what should be glass

Keep content readable and stable. Use glass for floating navigation/controls and
purposeful transient surfaces. Standard bars, tabs, menus, and sheets already carry
platform styling; try them before adding custom effects. Avoid glass-on-glass and
turning every content card or row into a lens. A translucent fallback material and
Liquid Glass are different rendering choices.

Use `.regular` as the normal adaptive choice. Reserve `.clear` for media-rich
backgrounds that tolerate dimming and have bold, bright foreground controls. Keep
variants coherent within one group. Tint selectively for a primary action rather
than coloring every element. Large surfaces need legible content and restrained
adaptation, not a magnified version of a tiny jewel-like button.

For system slider coverage and adjustment range, read
[system glass preferences](system-glass-preferences.md). Let native glass own its
adaptive fill and rim; fixed decorative layers can mask its clear endpoint.

## SDK and deployment

Xcode 26 SDK declarations checked during authoring mark `glassEffect`, `Glass`,
`GlassEffectContainer`, `glassEffectID`, `glassEffectUnion`, `.glass`, and
`.glassProminent` as introduced in iOS/macOS/tvOS/watchOS 26, unavailable on visionOS.
Check the current target SDK for exact platform availability. visionOS uses separate
glass APIs; a wildcard availability branch does not permit unavailable symbols.

For older runtime targets, use `if #available(iOS 26, macOS 26, *)` inside appropriate
platform compilation conditions, with a native control or standard-material/solid
fallback. Both branches still require a compiler SDK that recognizes all referenced
symbols. On an older SDK, omit/conditionally build the new API implementation.

## Controls and modifier order

Use `Button(...).buttonStyle(.glass)` or `.glassProminent` for ordinary actions.
Use `.glassEffect(.regular.tint(...).interactive(), in: shape)` when a genuinely
custom interactive surface needs the effect. `.interactive()` is visual response;
it does not create an action, disabled behavior, accessibility role, or keyboard support.
Do not put another glass effect around a button already using a glass button style.

Define content, font, padding, and final size before `.glassEffect`. Apply identity
and transition modifiers to that effect. Use one coherent shape for effect and hit
region. Prefer system foreground treatment; don't overwrite it with low-contrast gray.

## Multiple effects, unions, and identity

- Use a `GlassEffectContainer` for related custom glass siblings, both for rendering
  and coordinated geometry. A single effect does not require a gratuitous wrapper.
- Container `spacing` is a blending threshold, not the stack's layout gap. Increasing
  it lets effects merge sooner. If it exceeds the gap, surfaces can blend at rest.
  Test whether that still communicates separate actions.
- `glassEffectUnion(id:namespace:)` lets geometries contribute to a shared material
  shape. It is different from identity across an animated hierarchy change.
- `glassEffectID(_:in:)` supplies stable identity in a namespace; IDs should remain
  stable across state updates. Do not reuse one ID for unrelated simultaneous shapes.
- Change hierarchy with a scoped animation. Use the system matched-geometry behavior
  for nearby effects and materialization for more separated appearances when suitable.
  Honor Reduce Motion for custom transitions rather than forcing elasticity.

See [GlassActions.swift](../assets/GlassActions.swift). A namespace or container alone
does not animate anything; the state transition, geometry, and effect modifier order
must be correct. Repeated rapid toggles should not jump or discard actions.

## Scroll edges and spatial separation

Let content and scroll containers reach intended edges; use native safe-area,
toolbar, sidebar, and scroll-edge APIs for the target platform. Do not assume that
removing horizontal padding enables every under-sidebar effect in every hierarchy.
Verify actual scroll geometry and overlays. Keep text out from under glass at rest
when the overlap harms reading. Use a stronger edge separation for pinned accessory
headers when needed; a hard border is not automatically wrong.

## Accessibility and performance

System glass reacts to visual accessibility settings. Custom foregrounds, transitions,
and older-OS fallbacks still need testing. Opaque material is the correct response
when needed for readability; the rule against an opaque layer accidentally hiding
glass does not forbid accessibility fallbacks.

Limit visible effects and sampled areas, group related effects, and avoid repeated
blur/mask/shadow on every scrolling row. Inspect hitches on a populated screen and
realistic hardware. Validate light/dark, busy backgrounds, high contrast, reduced
transparency/motion, large text, keyboard, and VoiceOver.
