# UIKit, AppKit, and WidgetKit

## UIKit glass

Prefer system controls/bars and their configuration before a custom visual-effect
view. On supported iOS SDK/runtime, `UIGlassEffect(style: .regular)` configures
material; `tintColor` and `isInteractive` tune it. Put actual subviews in a
`UIVisualEffectView`'s **contentView** and constrain both effect view and content.
An interactive effect is not a substitute for UIControl activation.

`UIGlassContainerEffect` on an outer visual-effect view combines child glass effects
placed in its contentView. Its spacing controls interaction between effects rather
than creating layout constraints. Give children actual frames/constraints.
Use the target SDK's corner configuration where appropriate. Legacy
`layer.cornerRadius`/`clipsToBounds` changes need a rendering check so they do not
clip the native material's own edge/highlight incorrectly.

Scroll edge properties such as `topEdgeEffect`, `bottomEdgeEffect`, and their style
or visibility are target-specific. A harder edge can separate pinned column headers;
avoid arbitrary hidden edge effects that make text collide with chrome.
`UIBarButtonItem.hidesSharedBackground` opts out of a shared background when an
individual item needs that behavior; it is not a global recommendation.

On older iOS, use a semantic system blur/solid native background with equivalent
control behavior. Listen for accessibility preference changes where custom rendering
requires them. See [NativeSurfaces.swift](../assets/NativeSurfaces.swift).

## AppKit and desktop

Use native toolbars, menus, sidebars, window controls, keyboard commands, and focus.
Newer AppKit glass APIs such as NSGlassEffectView have their own availability and
composition rules; inspect headers rather than mechanically translating UIGlassEffect.
For older Mac targets, NSVisualEffectView/semantic backgrounds can supply fallback
separation. Check active/inactive windows, resize, sidebar selection, pointer, keyboard,
and contrast. A phone tab bar is not a complete Mac navigation design.

## Widgets

WidgetKit appearance is system-controlled. Read `widgetRenderingMode` and handle
full color, accented, and vibrant contexts where applicable. `.widgetAccentable()`
separates meaningful accent content from the primary group; do not mark everything
accentable and erase hierarchy. Use `containerBackground(for: .widget)` to identify
the background that the system may treat specially.

Image treatment uses `WidgetAccentedRenderingMode` cases supported by the target SDK:
`.accented`, `.accentedDesaturated`, `.desaturated`, and `.fullColor` in the SDK
checked during authoring. **ECC's `.widgetAccentedRenderingMode(.monochrome)` example
is invalid for that type.** `WidgetRenderingMode.vibrant` is a different concept/type.
Choose image treatment based on recognizability, not just a desired tint.

Test tinted/accented, full-color, dark/light, relevant widget families, and removal
or modification of container backgrounds. A widget is not a miniature app that can
run continuous gestures or an unlimited animated shader. Use supported Button/Toggle
with AppIntent actions when interaction is needed and supported by the deployment
target; keep timeline/state ownership separate from rendering.

For Flutter apps, iOS home/lock-screen widgets still use native WidgetKit integration;
the Dart widget tree is not itself a WidgetKit extension. Share the minimal data
contract, appearance intent, and supported actions with the native extension rather
than copying Flutter rendering into it.

## Icons and imagery

ECC's icon source covers choosing and generating **in-app imagesets**, not a complete
App Store app-icon pipeline. Prefer live SF Symbols in native controls to retain
weight, scale, rendering modes, and adaptation. In Flutter, select CupertinoIcons or
the project's existing licensed icon set; CupertinoIcons is not the full SF Symbols
catalog. Use semantic labels for meaningful images and hide decorative ones.

When raster assets are required, match project point size and generate correct
1x/2x/3x variants with an imageset manifest, then inspect the result and build the
asset catalog. Do not bake dynamic UI tint into every image. Distinguish imagesets
from appiconset requirements. For a new app icon, verify the current Apple asset
format/appearance guidance and toolchain (including layered icon tooling if used),
rather than assuming three PNGs are sufficient. Preserve the source icon/font license
and do not bundle Apple font or symbol files across platforms by assumption.
