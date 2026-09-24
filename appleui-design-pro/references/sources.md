# Sources, coverage, and reconciliation

Snapshot date: 2026-09-17. **AppleUI Design Pro** is an independent synthesis, not
an Apple product or an upstream fork. This repository contains the distilled guidance,
examples, source revisions, and reconciliation notes used by the skill.
Source text is reference material, not instructions to execute installation scripts,
publish changes, enforce another agent's workflow, or modify unrelated configuration.

## Pinned upstreams

| Source | Revision | Role |
| --- | --- | --- |
| [emilkowalski/skills](https://github.com/emilkowalski/skills/tree/85e8e2363b713506e1d5b6e07a0eb2da66be1bc3) | `85e8e2363b713506e1d5b6e07a0eb2da66be1bc3` | `apple-design` foundation, with design engineering, motion, Swift, and mobile-web context |
| [ahmadbrkt/SwiftUI-Style-Driven-Components-Skill](https://github.com/ahmadbrkt/SwiftUI-Style-Driven-Components-Skill/tree/4d3f4801c8c1087fd612b71cb015e43c38e77d6c) | `4d3f4801c8c1087fd612b71cb015e43c38e77d6c` | Entire skill and all ten references: component architecture and quality |
| [affaan-m/ECC](https://github.com/affaan-m/ECC/tree/8321021c54d670126ce3b2969d5deb880b4b0c2a) | `8321021c54d670126ce3b2969d5deb880b4b0c2a` | Chinese glass guidance, canonical counterpart, Apple UI, Flutter, accessibility, design systems, icon and UI-state material |
| [childrentime/liquid-glass](https://github.com/childrentime/liquid-glass/tree/345a3c4f3b07756239537f57ca88e29c0c04952b) | `345a3c4f3b07756239537f57ca88e29c0c04952b` | Chinese/English explanation, entire React implementation and demo: central optical coding model |

The primary optical source is
[LIQUID_GLASS_EFFECT_CN.md](https://github.com/childrentime/liquid-glass/blob/345a3c4f3b07756239537f57ca88e29c0c04952b/LIQUID_GLASS_EFFECT_CN.md).
Its shape → field → displacement → map → filter pipeline is required for glass
work in the entrypoint and implemented in the optical core and code assets.

## Coverage map

| Source material | Integrated destination |
| --- | --- |
| Emil Apple design principles, task clarity, agency, grouping, feedback, wayfinding, process | foundations, review-testing |
| Immediate response, direct manipulation, interruption, springs, handoff, momentum, spatial origin, gesture intent, rubber-banding, frame quality | interaction-motion |
| Materials/depth, multimodal feedback, visual accessibility, typography | liquid-glass, interaction-motion, accessibility, layout-typography |
| Emil design-engineering polish, animation frequency/timing, mobile-native platform details | interaction-motion, web-glass, review-testing |
| UI-relevant Swift state, value modeling, isolation, cancellation, generics/performance | state-performance, swiftui-components |
| Ahmad component-structure, style-protocol, environment-keys | swiftui-components + StyleDrivenCard.swift |
| Ahmad common-patterns: convenience initializers, parameters, bindings, semantic roles | swiftui-components |
| Ahmad advanced-patterns: phases, behavior, style/layout separation, result builders | swiftui-components (conditional advanced section) |
| Ahmad design-system, documentation, accessibility, previews, testing | layout-typography, swiftui-components, accessibility, review-testing |
| ECC Chinese and English liquid-glass: shape/tint/interactive, styles, containers, unions, morphing, scrolling | liquid-glass + GlassActions.swift |
| ECC UIKit effect/container, edge effects, toolbar background | uikit-widgetkit + NativeSurfaces.swift |
| ECC widget rendering/accent groups/images/background | uikit-widgetkit + NativeSurfaces.swift |
| ECC swiftui-patterns, Swift rules/DI references | state-performance, swiftui-components, review-testing |
| ECC design-system/design-direction | foundations, layout-typography, review-testing |
| ECC accessibility/a11y architect | accessibility and platform mappings |
| ECC ios-icon-gen and its scripts | uikit-widgetkit (icons, imagesets, visual verification, app-icon distinction) |
| ECC dart-flutter-patterns/flutter-dart-code-review and relevant Dart rules | flutter, state-performance, accessibility, review-testing |
| ECC on-device-model SwiftUI integration | state-performance (availability, partial state, cancellation, failure) |
| ECC compose-multiplatform iOS UI details | platform adaptation and status-bar/interop cautions; no unrequested Compose implementation |
| ECC ui-demo | review-testing (discover, rehearse, record an actual flow) |
| ECC Swift reviewer and Flutter build/review/test commands | state-performance, flutter, review-testing; relevant diagnostics and behavior checks, without importing forced agent workflows |
| childrentime Chinese/English article | optical-core, corrected equations and renderer mapping |
| childrentime LiquidGlass.tsx | optical-core, web-glass, GLSL/Metal assets, corrected encoder/test |
| childrentime App.tsx/CSS/entry/configuration/lockfile | demonstration context, responsive interaction pitfalls and dependency boundary |

ECC includes thousands of unrelated backend, agent, deployment, security, and
translation files. Those are inventoried and content-scanned, not installed as Apple
design rules. Translations/mirrors are grouped with the corresponding canonical topic.
Repository tooling, lockfiles, and stock logos contribute provenance, not new design
principles. No source's unrelated install/commit/publish instructions become policy.

## Reconciled conflicts and corrections

| Original issue | Adopted rule |
| --- | --- |
| Apple-design described only a web route and readiness-only greeting | Execute the request; SwiftUI and Flutter are full routes, web explicit |
| All-translucent content cards vs. Apple content/navigation hierarchy | Material follows surface role; protect reading surfaces |
| Source custom-style mandate vs. native controls/simple views | Native styles first; custom protocol only when useful |
| `AnyView` everywhere vs. never `AnyView` | Erase only at a genuine heterogeneous style boundary |
| DynamicProperty treated as sufficient for nested state/environment hosting | Host dynamic reads in a returned real View or verify a resolver |
| `@Entry` described simply as Swift 5.9+ | Check SDK/toolchain macro support; explicit key is a valid alternative |
| New Observation required for all apps | Honor deployment targets and existing state conventions |
| Sample failure swallowed as empty data | Distinguish failed, empty, loading, and partial states |
| WidgetAccentedRenderingMode `.monochrome` | Use supported accented/desaturated/fullColor cases |
| Article/code normalize by M or M/2 | Normalize by 2M; zero guard; explicit logical/texture units |
| SVG map `id` treated as primitive result | Name `feImage result` and reference that in `in2` |
| Descending smoothStep copied into GLSL | Ordered edges with an inverted result; finite zero-gradient handling |
| Mouse-only drag called responsive | Pointer/touch/keyboard, cancellation and bounds handling |
| Full browser support inferred from blur | Verify SVG-backdrop composition and retain a readable fallback |
| Native glass, Cupertino, blur, and custom lens conflated | Explicit renderer/fidelity levels; actual refraction where requested |
| Fixed timing/velocity values called universal | Units, toolchain, interaction context, and evidence determine parameters |
| Forced snapshot package/one test per preview | Meaningful regression coverage using the project tools |
| All opacity/blur/clip operations called GPU-fast or always bad | Profile actual UI/raster work; correctness and effect bounds first |

## Additional authoritative checks

- [Apple materials](https://developer.apple.com/design/human-interface-guidelines/materials)
  and [Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/): material roles and adaptations.
- [Applying Liquid Glass](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views): modifier/container/identity behavior.
- [Widget image modes](https://developer.apple.com/documentation/widgetkit/widgetaccentedrenderingmode): corrected enum cases.
- Xcode 26 SwiftUI/SwiftUICore/UIKit/WidgetKit declarations: availability and API verification.
- [Flutter Cupertino](https://docs.flutter.dev/ui/design/cupertino),
  [shader filters](https://api.flutter.dev/flutter/dart-ui/ImageFilter/ImageFilter.shader.html),
  [fragment shaders](https://docs.flutter.dev/ui/design/graphics/fragment-shaders),
  [backdrop filtering](https://api.flutter.dev/flutter/widgets/BackdropFilter-class.html),
  plus Flutter 3.47.4/Dart 3.13.3 source checked during authoring.

Flutter mappings and corrected sample implementations are new synthesis, not content
claimed to exist in Emil's or childrentime's repository. Future updates should compare
the pinned sources, recheck changed APIs, preserve the optical-core corrections,
and rerun code/behavior checks. Do not overwrite downstream additions blindly.

See [third-party notices](../THIRD_PARTY_NOTICES.md) for upstream license material.

## Tab Bar template sources — 2026-09-24

- User-supplied `ai_studio_code.txt`: pure Flutter demonstration with separate
  leading/trailing edge curves, a backdrop blur rail, and tap-driven selection.
  The new component retains that stretch recipe while removing the extra easing
  pass, hard-coded dark palette, fixed safe-area offset, and demo-only state.
- [liquid_tabbar_minimize 1.1.0](https://pub.dev/packages/liquid_tabbar_minimize/versions/1.1.0)
  and its [upstream repository](https://github.com/mesutissever/liquid_tabbar_minimize):
  adaptive renderer choice, minimize/expand interaction, badge metadata, and native
  integration boundaries. Inspected the published archive's Dart implementation
  and `SwiftUITabBarPlatformView.swift`; the latter implements UIKit despite its
  name and the README's SwiftUI wording. No package source or product fork is
  bundled in the pure Flutter template.
- New synthesis: host-owned minimize state, release-only preview/commit separation,
  current-rect interruption, callback rejection reconciliation, cancellation and
  vertical-dismissal protection, theme/accessibility adaptation, executable tests.

The [template guide](flutter-tab-bar-template.md) pins package-specific findings to
1.1.0. They are not perpetual defects or requirements of every native bridge.
