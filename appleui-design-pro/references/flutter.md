# Flutter / Cupertino implementation

This is a first-class route for AppleUI Design Pro. Shared Apple design principles
remain the same; translate implementation into the Flutter project rather than
generating SwiftUI code. Read [optical-core.md](optical-core.md) for all glass work.

## Establish the actual runtime

Inspect `pubspec.yaml`, the locked Flutter/Dart version, iOS/macOS deployment targets,
existing theme/router/state library, and renderer. Use local SDK declarations or
current official docs for version-sensitive APIs. Do not assume that Cupertino
automatically gains every new Apple material when the OS changes.

## Framework mapping

| Apple concept | Flutter starting point |
| --- | --- |
| Semantic app theme | CupertinoTheme / CupertinoThemeData / dynamic Cupertino colors |
| Navigation hierarchy | Existing router with CupertinoPageRoute-compatible transitions |
| Independent tabs | CupertinoTabScaffold + CupertinoTabView, preserving per-tab stacks |
| Large title and scroll | CupertinoSliverNavigationBar in CustomScrollView |
| Button/selection/input | CupertinoButton, CupertinoSwitch, CupertinoSlider, CupertinoTextField, CupertinoPicker |
| Grouped settings | CupertinoListSection / CupertinoListTile / form rows where SDK provides them |
| Temporary choice | CupertinoActionSheet + showCupertinoModalPopup |
| Alert | CupertinoAlertDialog + appropriate dialog route |
| Sheet task | CupertinoSheetRoute or existing supported sheet implementation |
| Safe layout | SafeArea, LayoutBuilder, directional insets and alignments |
| Motion | Framework route/scroll physics first; AnimationController + SpringSimulation for custom behavior |
| Accessibility | Semantics, Focus/Shortcuts/Actions, MediaQuery settings, scalable text |

Use platform controls to retain cancellation, focus, selection, disabled behavior,
and native-feeling text editing. A GestureDetector on a decorative Container is not
equivalent to a button. Do not rebuild the navigation root to change selected tabs.
Verify the actual semantic tree as well as callbacks for disabled controls. The
checked Flutter 3.47.4 CupertinoButton could block activation while omitting an
explicit disabled semantic state. If this occurs in the project's SDK, supply
`Semantics(button: true, enabled: false, label: ...)` and exclude the disabled
child's redundant semantics; preserve the native semantics when enabled. Test the
live control node, not a retained node on an excluded Text. Avoid adding duplicate
tap handlers merely to change semantics.
Use device capabilities and actual constraints; avoid `dart:io Platform` in code
that must compile on web. Cupertino's iOS patterns do not cover every Mac convention:
desktop work also needs menus, shortcuts, pointer focus, resizing, and window behavior.

## Style-driven architecture in Dart

Use immutable style data for colors/spacing/shape and a widget builder for genuine
layout variation. Keep action, enabled/selected state, input value, and semantics
owned by the component. Resolve styles from an existing theme or a small inherited
theme when subtree cascading is needed. A local override should affect only its
subtree. Avoid a Swift-style protocol/configuration hierarchy translated mechanically
into dozens of Dart classes.

For one appearance, a simple widget is enough. For several layouts, an immutable
configuration with semantic state and `child`, plus a builder, is often sufficient.
Use a true customization interface when library clients need to add variants. Do
not use a stringly typed registry for compile-time-known variants. No `AnyView`
analogue is required: Dart widgets already have a common widget base.

Keep visual tokens semantic. Resolve `CupertinoDynamicColor` in `BuildContext`.
Use text themes and `TextScaler`; preserve Dynamic Type. Implement large-text
reflow with constraints/Wrap/vertical layouts instead of clipping. State stays local
for ephemeral pressed/expanded state; preserve Riverpod/BLoC/Provider/etc. when the
project already uses it. A new visual component does not justify a state-library migration.

## Liquid Glass: three explicit rendering levels

### A. Material approximation

A clipped `BackdropFilter(ImageFilter.blur(...))` plus a restrained translucent fill,
edge highlight, and shadow can approximate diffusion/depth. It does **not** create
refraction. Use it as a compatibility fallback or when only that material is requested.
`ImageFiltered` filters its child; `BackdropFilter` filters content already behind it.
Keep foreground labels outside the filter's sampled source. Avoid unbounded filters.

### B. Refraction through the optical core

The Flutter 3.47.4 SDK checked during authoring supports `ImageFilter.shader` on
Impeller. Query
`ImageFilter.isShaderFilterSupported` where that API exists; using a shader filter
on an unsupported backend throws. Older SDKs may not have the constructor at all.

Declare `.frag` under `flutter: shaders:` in pubspec and load it once through
`FragmentProgram.fromAsset`. Create per-effect mutable shader instances, reuse them,
and release them with their owner. In shader filters, the engine supplies **float
slots 0 and 1 for image dimensions and sampler slot 0 for input texture**. Do not
overwrite those from Dart. User uniforms follow them. Account for OpenGLES texture
y orientation using the documented compilation define.

Apply `ImageFilter.shader` through a bounded, matching clip. Use the SDF, ordered
smoothstep, finite normal, and displacement model in the core. GPU shaders can
sample offsets directly; they need not quantize through an RGBA displacement map.
Match texture bounds, logical size, pixel density, and clip radius in a visual test.
If the desired backdrop shader is unavailable, an explicit image-texture lens is
another implementable route; do not silently label a blur fallback “refraction.”

See [apple_ui_glass.dart](../assets/apple_ui_glass.dart) and
[apple_ui_lens.frag](../assets/apple_ui_lens.frag). They separate an actual SDF lens
from the fallback. Their coefficients are tuneable approximation defaults.
The foreground determines layout; a `Positioned.fill` background receives the
resulting finite size, so toolbars can grow with text rather than require a fixed
height. Keep the backdrop filter behind the actual controls. Use padding and reflow
to keep controls within the visual shape. The sample's `surfaceColor` is adjustable;
no single translucent tint guarantees contrast over every photo. Validate normal,
disabled, and accent-colored labels against busy/light/dark content; increase the
backing opacity or provide a local solid backing when needed.

### C. Native platform integration

If the product specifically requires system-rendered Liquid Glass, evaluate a
maintained native integration or a small bridge to SwiftUI/UIKit/AppKit. Verify
OS availability, composition with the Flutter surface, background sampling, input
forwarding, semantics, lifecycle, accessibility updates, and rendering cost. An iOS
platform view containing UIGlassEffect does not automatically sample every Flutter
layer correctly. Do not add a large dependency before checking the current SDK and
existing project packages.

For system appearance sliders and mixed native/Flutter materials, read
[system glass preferences](system-glass-preferences.md). A fixed blur or custom
shader does not subscribe to the OS preference merely because adjacent native
controls do.

## Interactions

Use Cupertino/page/scroll physics before custom gesture code. For custom dragging,
capture the current displayed position on start, accumulate local deltas 1:1, and
use release velocity to choose and settle toward a target. Cancel/rebase an active
simulation without resetting the object to its old endpoint. Dispose controllers;
keep unchanged descendants in AnimatedBuilder's child. Do not set state across the
whole screen on each frame just to move one lens.

Keep haptics tied to meaningful commits/snaps and avoid duplicating built-in feedback.
Give custom controls Focus/Shortcuts/Actions and Semantics where built-ins don't
supply them. Preserve back-swipe on iOS and back behavior on other targets. Coordinate
sheet dismissal with inner scrolling through the framework, not a global pan handler.

## Accessibility and lifecycle

Read `MediaQuery.disableAnimationsOf`, `highContrastOf`, and `textScalerOf` where
available. `accessibleNavigation` signals assistive navigation; it is not a synonym
for Reduce Transparency. If the Flutter version lacks a Reduce Transparency signal,
pass an explicit setting from a platform bridge or app accessibility preference and
choose a readable default. Native iOS `UIAccessibility.isReduceTransparencyEnabled`
and its change notification can supply that bridge.

Respect live setting changes. On reduced transparency/high contrast use a readable
solid surface; on reduced motion stop animated distortion/parallax/elasticity while
keeping feedback. Preserve semantic actions at large text sizes. Async work checks
mounted before using disposed context/state; ignore stale search results and preserve
input on failure. Cancel owned subscriptions/timers and dispose image/shader resources.

## Validation

Run `dart format`, `flutter analyze`, focused `flutter test`, then renderer/device
checks for refraction. Widget tests should verify real activation, disabled behavior,
theme cascade/overrides, semantics, text scaling, and fallbacks. Golden tests are
optional and platform/font-dependent. Profile populated scrolling/dragging screens in
profile mode with DevTools. Debug-frame timing is not a release benchmark.

Official support: [Cupertino](https://docs.flutter.dev/ui/design/cupertino),
[shader filters](https://api.flutter.dev/flutter/dart-ui/ImageFilter/ImageFilter.shader.html),
[shader authoring](https://docs.flutter.dev/ui/design/graphics/fragment-shaders),
[BackdropFilter](https://api.flutter.dev/flutter/widgets/BackdropFilter-class.html).
