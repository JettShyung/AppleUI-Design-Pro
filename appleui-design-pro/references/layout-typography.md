# Layout, typography, and tokens

## Typography

SwiftUI: start with semantic fonts (`.body`, `.headline`, `.title`, `.caption`) and
semantic foreground styles. The system font already handles optical sizing/tracking.
For custom fonts, use a text-style-relative size and `@ScaledMetric` for dimensions
that should grow with text. Check glyph coverage and localized weights.

Flutter: start with `CupertinoTheme` / `CupertinoTextThemeData`, resolve dynamic
Cupertino colors in context, and preserve `MediaQuery` text scaling. Use current
`TextScaler` APIs when calculating text sizes; do not globally force a scale of 1.
Theme values are inputs, not a reason to prevent a label from wrapping.

Build hierarchy from size, weight, leading, and position together. Use monospaced
digits for changing values when helpful. Match symbol weight and scale to adjacent
text. Avoid global negative tracking, blanket font shrinking, fixed-height multiline
rows, and unannounced truncation of essential values. CJK and other scripts need
their own spacing/line-height checks; Latin display tracking is not universal.

## Content-adaptive layout

- Respect safe areas for text/actions; allow appropriate backgrounds to extend to
  screen edges. Keep primary controls clear of the keyboard and home indicator.
- Use intrinsic constraints. SwiftUI: `Layout`, `ViewThatFits`, adaptive grids.
  Flutter: `LayoutBuilder`, `Flexible`, `Wrap`, slivers, and `SafeArea` as appropriate.
- At accessibility text sizes, turn cramped horizontal groups into vertical groups;
  preserve reading order and control proximity.
- Test narrow iPad/Mac windows, not only full screen. Collapse columns without
  losing selection. A wider screen should support the work rather than stretch a
  phone layout indefinitely.
- Use directional alignment/insets; check RTL, long translations, localized dates,
  numbers, and mixed CJK/Latin copy. Keep content selectable where useful.
- Prefer platform shapes and even nested insets. A capsule suits a compact control,
  not a paragraph. Do not guess device-corner geometry from a screenshot.

## Tokens without a new framework

Reuse existing tokens. Otherwise start with a small set of repeated decisions,
not a dependency or configuration system for every constant.

| Family | Useful semantic roles |
| --- | --- |
| Type | Title, body, label, caption, scalable numeric value |
| Foreground | Primary, secondary, disabled, status |
| Background | Content, grouped content, raised surface, chrome fallback |
| Spacing | Short shared scale for related components |
| Shape | Control, card, panel; consistent nested geometry |
| State | Pressed, selected, focus, disabled, loading, error |
| Motion | Press, state change, settle; units and purpose documented |

SwiftUI uses asset colors and environment where appropriate. Flutter can use
immutable style data plus `CupertinoTheme` or an inherited app theme; use
`ThemeExtension` when the app already has a Material theme. Avoid introducing a
Material ancestor solely for a color token. Keep brand and status colors separate.

## Web translation

Prefer `system-ui`, relative units, and font-native tracking. Large display text may
need tighter tracking and leading; body text needs comfortable line spacing. Use
optical sizing only when the selected font supports it. Preserve browser zoom and
content selection. See [web-glass.md](web-glass.md) for viewport and touch rules.
