---
name: appleui-design-pro
description: >-
  Design, implement, refine, and review Apple-platform interfaces in SwiftUI,
  UIKit/AppKit, WidgetKit, or Flutter/Cupertino, including Liquid Glass,
  Tab Bar templates and interaction, adaptive layout, and accessibility. Use for Apple UI design,
  SwiftUI styling, 苹果 App 设计, 液态玻璃, and explicitly requested Apple-style web
  interfaces. Do not use for generic Swift/Dart logic, Figma work, or unrelated
  full-app rewrites.
metadata:
  version: "1.3.0"
---

# AppleUI Design Pro

Build interfaces that preserve people's attention and control: content first,
familiar navigation, immediate feedback, continuous motion, and readable materials.
This is an independently assembled skill based on Emil Kowalski's `apple-design`,
extended with SwiftUI architecture and Liquid Glass research; it is not an Apple
product. Respond in the user's language and carry out the requested work.

## Start with the actual product

Inspect the relevant screen, component, design tokens, state ownership, and project
deployment/toolchain settings. Establish the user's primary task and input modes.
For a design-only request, state reasonable platform assumptions and provide the
requested design; do not require a repository. For existing code, preserve its
framework, supported OS versions, and established conventions.

SwiftUI and Flutter are equally supported implementation paths. Use SwiftUI for a
native Swift project and Flutter/Cupertino for a Dart or cross-platform project.
For a new app with no framework context, state a reasonable choice or ask a brief
question only when that choice blocks implementation. Use the web
path when the user requests web/PWA/React or the existing project is web-based.
Use UIKit/AppKit where the project already does. Do not silently convert platforms
or add Figma, a dependency, a new style system, or a deployment step.

## Core glass coding model — required for glass work

For every glass design or implementation, read
[the optical core](references/optical-core.md), derived from the primary optical
source, **解密苹果最新 Liquid Glass 效果：如何用代码重现 iOS 设计系统的视觉魔法**.
Reason through **shape/SDF → smooth edge profile → source-sampling displacement →
map/shader encoding → background sampling → tint/highlights/shadow → interaction**.
This is the central implementation model, not an optional web appendix. Validate
against structured background content so refraction is visible, with foreground
labels kept sharp. Blur alone does not reproduce lensing.

Apply that model using the requested renderer: SwiftUI/UIKit native material when
appropriate; Flutter's supported rendering or explicit source-texture shader path;
SVG/Canvas for web. For custom refraction, implement and test the actual displacement
math. State which layers are system-supplied, implemented, approximated, or unsupported.
Do not substitute a blur-only demo for a request that explicitly requires refraction.

## Route to the needed detail

Read the matching references, not this entire library on every task.

| Work | Read |
| --- | --- |
| New screen, product flow, design direction, critique | [Design foundations](references/foundations.md) and [Layout and typography](references/layout-typography.md) |
| SwiftUI reusable component, styles, environment, tokens | [SwiftUI components](references/swiftui-components.md) |
| Flutter/Cupertino app, widgets, styles, gestures, glass | [Flutter implementation](references/flutter.md), plus the relevant shared design references |
| Native Liquid Glass or migration from blur | [Liquid Glass](references/liquid-glass.md) |
| System glass slider, incomplete coverage, weak range, native composition ghosting, scroll-edge blur | [System glass preferences](references/system-glass-preferences.md) |
| Glass optics, refraction, custom shader, material fidelity | [Optical core](references/optical-core.md), then the selected platform reference |
| Tab Bar design, reusable Flutter template, scroll-to-minimize, package integration | [Tab Bar design](references/tab-bars.md); use the [Flutter template](references/flutter-tab-bar-template.md) for copy-and-use code |
| Draggable lens, commit timing, held-edge/alpha artifacts | [Tab Bar design](references/tab-bars.md), then the selected platform reference |
| Tap, drag, sheet, spring, interruption, haptics | [Interaction and motion](references/interaction-motion.md) |
| VoiceOver, Dynamic Type, visual settings, keyboard | [Accessibility](references/accessibility.md) |
| SwiftUI state, concurrency, layout/animation performance | [State and performance](references/state-performance.md) |
| UIKit/AppKit glass or WidgetKit appearance | [UIKit and widgets](references/uikit-widgetkit.md) |
| Apple-style web, lens/refraction, SVG/Canvas | [Web and optical effects](references/web-glass.md) |
| Review, previews, regression validation | [Review and testing](references/review-testing.md) |
| Origins, conflicts, licenses, future updates | [Sources and reconciliation](references/sources.md) |

## Decision order

1. **Solve the task and navigation.** Make the primary action, current location,
   next destination, and exit clear. Include real loading, empty, error, and success
   states when relevant. Use explicit labels and preserve user input on failure.
2. **Choose platform semantics.** In SwiftUI, start with `Button`, `Toggle`, `Picker`, `List`,
   `Form`, `NavigationStack`/`NavigationSplitView`, `TabView`, toolbars, and sheets.
   In Flutter, start with Cupertino controls, routes, navigation bars, forms, and
   tabs. Customize supported styles before recreating a control or gesture recognizer.
3. **Choose a surface role.** Content stays readable and stable. Glass belongs to
   floating controls/navigation. Prefer system chrome; custom glass needs a clear
   role. Do not coat every card, row, or background with glass or stack glass layers.
4. **Choose component complexity.** A single appearance needs an ordinary view or
   native style. Introduce a custom style protocol only for genuinely different
   reusable appearances or an actual library extensibility requirement.
5. **Specify behavior before decoration.** Feedback begins on press; the action
   commits through the control's normal activation. Direct manipulation tracks
   input without lag. Settling can be interrupted and redirected. Motion must
   communicate feedback, state, origin, or continuity, not block the next action.
6. **Adapt, then verify.** Test the relevant appearances, input modes, accessibility
   settings, and OS fallback. Compile using the actual project toolchain; inspect
   rendered UI when available. Separate compiled, rendered, and device-tested claims.

## Invariants and conflict resolution

- User requirements and project constraints win over source preferences. Verified
  SDK declarations and official platform behavior win over community sample code.
- Treat spring/timing/spacing examples as starting values, not universal Apple
  constants. Never port CSS pixels directly into SwiftUI points or confuse spring
  response with a fixed animation duration.
- Retain native gesture cancellation, disabled behavior, focus, keyboard activation,
  roles, labels, and accessibility actions when changing a control's appearance.
  `.interactive()` on glass supplies visual feedback, not button semantics.
- Native glass APIs introduced with the 26-series OS require both a compatible SDK
  and availability checks for older deployment targets. `if #available` alone
  cannot make an old SDK recognize an unknown symbol. visionOS has distinct APIs.
- Built-in glass adapts to system accessibility settings. Custom motion, colors,
  shaders, and fallback surfaces must also respect Reduce Motion, Reduce
  Transparency, Increase Contrast, and Dynamic Type.
- The web's SVG displacement demo is an optical approximation. Never call it
  Apple's shader or claim full Safari/Firefox support from blur support alone.
- Flutter Cupertino widgets are Flutter-rendered. Do not assume that a Cupertino
  theme or OS upgrade automatically supplies native Liquid Glass. Distinguish
  native embedding, Flutter blur/material approximation, and custom refraction.
- Keep type erasure at genuine heterogeneous style boundaries. In a custom style
  system, `DynamicProperty` conformance alone does not prove nested state/environment
  updates are hosted correctly; see the component reference.

## Deliver the requested result

For implementation, make the change and summarize behavior and validation. For
design, deliver a concrete screen/flow proposal with component hierarchy, materials,
interaction states, and accessibility adaptations. For review, lead with actionable
findings, locations/evidence, and fixes; use a before/after table when it helps.
Do not fabricate visual inspection or require an elaborate report for a small edit.

Reusable examples are in [assets](references/review-testing.md#bundled-examples).
They are references to adapt, not a mandate to copy all files into an app.
