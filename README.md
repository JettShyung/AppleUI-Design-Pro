# AppleUI Design Pro

AppleUI Design Pro is an independent Agent Skill for designing, implementing,
and reviewing Apple-platform interfaces in SwiftUI, UIKit/AppKit, WidgetKit, and
Flutter/Cupertino. It also includes an explicitly scoped web path and practical
Liquid Glass optics examples.

This project is not affiliated with or endorsed by Apple Inc. Apple and related
product names are trademarks of Apple Inc.

## What it covers

- Apple interface hierarchy, navigation, typography, motion, and accessibility.
- Tab Bar design: ready-to-copy Flutter component and demo, release-only dragging,
  stretch motion, scroll-to-minimize, badges, accessibility, and native package guidance.
- Native Liquid Glass APIs, compatibility fallbacks, and custom refraction math.
- SwiftUI component architecture and state/performance guidance.
- Flutter/Cupertino implementation and shader-backed glass examples.
- Review criteria that distinguish compiled, rendered, and device-tested claims.

The skill uses progressive disclosure: `SKILL.md` routes each task to only the
relevant files under `references/`. Reusable code examples live under `assets/`.

## Design model

AppleUI Design Pro treats Apple interface design as a hierarchy of decisions, not
as a collection of rounded cards and translucent effects:

1. Start with the person's task, current location, next action, and recovery path.
2. Preserve native platform semantics before customizing appearance.
3. Give each surface a role: content remains stable and readable; glass belongs to
   navigation, controls, and purposeful transient layers.
4. Specify interaction behavior before decoration: immediate feedback, direct
   manipulation, interruptible motion, and accessible alternatives.
5. Adapt to content, window size, input mode, accessibility settings, and older OS
   targets, then report separately what was compiled, rendered, and device-tested.

For custom Liquid Glass, the implementation model is:

```text
shape/SDF → smooth edge profile → source-sampling displacement → map or shader
→ background sampling → tint/highlights/shadow → interaction
```

Blur alone is therefore a material fallback, not refraction. Foreground labels and
real controls stay sharp and semantic while only the background sample is displaced.

Detailed theory and implementation guidance:

- [Design foundations](appleui-design-pro/references/foundations.md): purpose,
  agency, hierarchy, navigation, feedback, and surface roles.
- [Optical core](appleui-design-pro/references/optical-core.md): SDF geometry,
  displacement encoding, compositing, renderer mapping, and acceptance checks.
- [Tab Bar design](appleui-design-pro/references/tab-bars.md): committed navigation
  versus drag preview, lens layering, interruption, and behavioral checks.
- [Interaction and motion](appleui-design-pro/references/interaction-motion.md):
  gesture lifecycle, interruption, springs, momentum, boundaries, and haptics.
- [Layout and typography](appleui-design-pro/references/layout-typography.md):
  semantic type, adaptive layout, localization, and lightweight design tokens.
- [Accessibility](appleui-design-pro/references/accessibility.md): semantics,
  focus, reflow, contrast, Reduce Motion, and Reduce Transparency.
- [Sources and reconciliation](appleui-design-pro/references/sources.md): pinned
  sources, coverage, corrected conflicts, and provenance.

## Install

Download this repository and copy the `appleui-design-pro` directory to your user
skills directory:

- macOS / Linux: `~/.agents/skills/appleui-design-pro/`
- Windows: `%USERPROFILE%\.agents\skills\appleui-design-pro\`

The final path must contain `appleui-design-pro/SKILL.md`. Restart Codex if the
skill does not appear. See the
[official OpenAI documentation](https://developers.openai.com/zh-Hans/docs/build-skills)
for current skill locations and invocation behavior.

This repository currently ships a standalone skill, not a plugin package.

## Use

```text
Use $appleui-design-pro to review and improve this SwiftUI screen's navigation,
materials, interaction, and accessibility.
```

```text
Use $appleui-design-pro to build this Flutter floating toolbar with real edge
refraction, native control semantics, large-text reflow, and a solid fallback.
```

### Reusable Flutter Tab Bar

```text
用 $appleui-design-pro 的 Tab Bar 模板为我的 Flutter 项目实现底部导航：
保留现有页面，拖动只预览、松手才切换，支持滚动收起和明暗模式。
```

Copy the single [component](appleui-design-pro/assets/flutter_tab_bar/lib/apple_tab_bar.dart),
then adapt the [working demo](appleui-design-pro/assets/flutter_tab_bar/lib/main.dart).
The [integration guide](appleui-design-pro/references/flutter-tab-bar-template.md)
explains setup, customization, scroll handling, validation, and when to use
`liquid_tabbar_minimize` for native iOS rendering. The pure Flutter template needs
no third-party dependency; its blur material is explicitly an approximation.

## Validation

Run every check available on the current machine:

```sh
./scripts/check.sh
```

The script validates YAML metadata and local Markdown links, runs the JavaScript
optical checks, analyzes and tests the Flutter Tab Bar in a temporary copy,
type-checks the Swift examples, and compiles the Metal shader when
the required tools are installed. Review any `SKIP` lines before a release.

The JavaScript optical check can also run independently:

```sh
node appleui-design-pro/assets/displacement.test.mjs
```

Set `FLUTTER_BIN` to the Flutter executable if it is not on `PATH`. The Tab Bar
component/demo/tests were checked with Flutter 3.47.5 / Dart 3.13.4; the Swift
examples type-check for macOS and iOS with Swift 6.4. Device feel, VoiceOver, and
GPU profiling need their target environments. The Tab Bar is a copyable starter;
other `assets/` files remain examples to adapt, not a shared runtime framework.

## Maintain and improve

Treat this repository as the source of truth. The skill does not learn from usage or
edit itself in the background; update it only after an explicit maintenance request.

1. Reproduce a real failure or identify a concrete missing decision.
2. Make the smallest correction in `SKILL.md`, the relevant reference, or an asset.
3. Run `./scripts/check.sh` and review every skipped check.
4. Test observable behavior with a realistic use case.
5. Bump `metadata.version` for a material skill update. Commit, tag, or publish
   only when requested; a local skill update does not require a release.

For local development, point the installed skill directory at this repository's
`appleui-design-pro` directory with a symbolic link. Codex detects local skill
changes automatically; restart it if an update does not appear.

## License and attribution

Original contributions are released under the [MIT License](LICENSE). Source
revisions, adaptations, corrections, and upstream notices are documented in
[THIRD_PARTY_NOTICES.md](appleui-design-pro/THIRD_PARTY_NOTICES.md) and
[sources.md](appleui-design-pro/references/sources.md).
