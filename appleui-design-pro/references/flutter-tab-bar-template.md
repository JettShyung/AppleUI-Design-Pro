# Flutter Tab Bar template

Use this route when someone asks for a reusable, pure Flutter glass-style Tab Bar.
Start with the working asset, not a newly invented control. Keep the app's routes,
labels, icons, theme, and accepted selection. For native iOS glass, follow the
[package route](#when-native-ios-glass-is-required) instead.

## Copy and use

Copy [apple_tab_bar.dart](../assets/flutter_tab_bar/lib/apple_tab_bar.dart) into the
app's `lib/` directory. It depends only on the Flutter SDK. Keep
`uses-material-design: true` in `pubspec.yaml` if using Material icons.

```dart
// In an existing State: int selected = 0;
Scaffold(
  extendBody: true,
  body: IndexedStack(index: selected, children: pages),
  bottomNavigationBar: AppleTabBar(
    selectedIndex: selected,
    onSelected: (index) => setState(() => selected = index),
    items: const [
      AppleTabItem(icon: Icons.home_outlined, label: 'Home'),
      AppleTabItem(icon: Icons.explore_outlined, label: 'Explore'),
      AppleTabItem(icon: Icons.mail_outline, label: 'Inbox', badgeCount: 3),
    ],
    badgeLabel: (count) => '$count unread',
  ),
)
```

The host must supply one page per item and a valid accepted index. The component
supports 2–5 items; use another navigation pattern beyond five. Replace icons and
labels, including badge/expand accessibility strings, for the product's locale.
`selectedIcon`, per-item `enabled`, optional `tint`, `motionDuration`, and a nullable
`onSelected` cover normal integration. Treat items as immutable. Reset/remap the
accepted index when changing their count/order.

The component owns bottom/side safe-area padding. Do not add another bottom
SafeArea. With `extendBody`, give scroll content enough bottom padding for the
bar's **actual** height at the current text scale. Preserve each page's scroll and
navigation state; pause inactive tickers. The complete
[demo](../assets/flutter_tab_bar/lib/main.dart) shows four pages, independent scroll
positions, live light/dark appearance, badges, and scroll-to-minimize.

For a standalone demo, create a **new** Flutter app, copy the asset's `lib/` files
into it, and run it. Do not run `flutter create` over the user's existing app.
Alternatively copy the whole [template folder](../assets/flutter_tab_bar) to a new
location, run `flutter create --project-name appleui_tab_bar_example .`, remove the
generated counter test, then run `flutter run`. Keep the supplied template tests.

### Optional scroll-to-minimize

The host owns `bool minimized = false`. Wrap the active vertical list:

```dart
NotificationListener<ScrollNotification>(
  onNotification: (event) {
    final next = appleTabBarMinimizedFor(event);
    if (next != null && next != minimized) {
      setState(() => minimized = next);
    }
    return false;
  },
  child: list,
)
// Pass to AppleTabBar:
// minimized: minimized,
// onExpand: () => setState(() => minimized = false),
// expandLabel: 'Expand navigation',
```

The helper uses direct user scroll updates: down past 40 logical pixels collapses,
upward movement or returning to the top expands; deltas within ±4 are ignored.
These are adjustable starter values, not Apple constants. Ballistic, programmatic,
horizontal, and nested scroll updates do not change state. A nested-scroll product
should connect its actual primary scroll source, not forward every notification.
Tapping the small capsule **only expands**. Each host has its own minimize state;
there is no static controller or cross-instance subscription.

## Interaction and rendering contract

- The app owns committed selection; the bar owns a temporary presentation rect.
  Dragging and holding never invoke `onSelected`. A real horizontal preview followed
  by release requests one selection; cancellation or a disabled target restores
  the accepted selection. Vertical dismissal does not accidentally activate a tab.
- Taps, keyboard activation, and semantic actions use the same callback. Navigation
  can be rejected by retaining the old index; external selection cancels stale
  dragging. There is no timer that commits a stationary held finger.
- Stretch motion retains the supplied sample's leading/trailing edge idea, using
  ease-out/ease-in on raw controller time once. New motion starts from the currently
  displayed rect, including a mid-animation reversal/re-grab. Geometry uses logical
  visual slots with RTL mapping; a width change during drag cancels its release.
- Material sparkle/ripple is disabled so it cannot resemble dark edge particles.
  Keyboard focus and hover retain a visible overlay.
- One clipped backdrop blur, one adaptive rail fill/rim, one selection fill/rim,
  and one icon/label layer. No duplicate glyph sampling, shader dispersion, or
  shadow rendered into its own backdrop. Whole-bar vertical feedback is subtle
  and shares the motion clock; its transform leaves hit testing stationary.
- This is **Flutter frosted material and elastic geometry**, not refraction or
  Apple's native shader. If real optical displacement is requested, read the
  [optical core](optical-core.md) and use a renderer with an explicit sample source.

The API reads theme, direction, text scaling, high contrast, and reduced animation
settings live. Reduced motion removes elastic transitions and lift; high contrast
uses a solid rail. Supply `reduceTransparency` from a platform bridge or the app's
setting: Flutter `MediaQuery` does not supply that preference across platforms.
Use the theme's accessible primary color; a custom tint still needs contrast review.
Labels may wrap to two lines and then ellipsize; semantics retains their full text.
The auxiliary badge count keeps its compact text size; the complete count is
announced in the tab label. The compact state keeps that badge and an explicit
expand action.

### Template calibration (logical pixels, not Apple measurements)

| Setting | Current starter value |
| --- | --- |
| Rail height | `max(76, 48 + 2.2 × scaled(11))`; height updates immediately for new text size |
| Side/bottom minimum safe padding; inner inset | 16 / 8; 8 |
| Rail / selection corner radius | 32 / 24 |
| Backdrop Gaussian sigma | 18 (Flutter `ImageFilter.blur`) |
| Selection movement / press / release feedback | 380 / 110 / 180 ms; reduced motion disables these effects |
| Whole-bar lift | Up to 1.5; no nonuniform scaling or secondary glyph sample |
| Collapsed width | `min(availableWidth, 144)` |
| Scroll offset / directional delta threshold | 40 / 4; direct vertical user input only |

Tune constants in the copied component if the product needs different geometry.
Do not expose every optical constant as an API or reuse the old native-rail
calibration table as this template's specification.

## When native iOS glass is required

Consider [liquid_tabbar_minimize](https://pub.dev/packages/liquid_tabbar_minimize)
when the user requests native iOS glass or already uses that dependency. Version
**1.1.0** was inspected on 2026-09-24. Keep the pure Flutter template as a separate
choice: `forceCustomBar: true` in the package selects **its** fallback, not this
template. Do not add the dependency to a pure Flutter-only request.

| Concept from the package | Treatment in this template |
| --- | --- |
| Controlled index and tab metadata | `selectedIndex`, `onSelected`, `AppleTabItem` |
| Scroll-to-minimize and expand capsule | Host-owned bool + filtered notification helper |
| Badge / selected icon / RTL | Included without a platform channel |
| Adaptive native-versus-custom renderer | Explicit implementation choice; not hidden OS detection |
| Optional separate action button | Keep in the host toolbar/FAB when needed; not another navigation destination |

**Verify implementation rather than repeating package marketing.** The published
1.1.0 iOS source uses `UITabBarController`/`UITabBar` through a Platform View; the
README calls it SwiftUI. Minimize manipulates native controller/layout state; it is
not evidence of SwiftUI `TabView`'s system scroll behavior. Its Flutter fallback
uses blur and tap selection; it does not provide this template's release-only drag.

Before shipping that version, verify these boundaries in the target app:

1. Bound the Platform View's height, handle safe-area inset once, and check actual
   native/Flutter composition under content, keyboard, pushed pages, and sheets.
2. Synchronize accepted selection, theme, labels, badges, and disabled state on
   updates. The inspected native `didUpdateWidget` path only sends labels/badges;
   router changes need explicit bridge support. Rejecting a native tap must also
   restore the native selected item, not merely leave Dart's index unchanged.
3. Inspect `LiquidRouteObserver` coverage: 1.1.0 observes `PageRoute`, so do not
   assume a popup/modal bottom sheet receives the same protection.
4. Verify instance disposal and scroll routing: static `handleScroll`/native state
   can couple hosts. Prefer one mounted bar or an instance-scoped adapter/fix.
5. Preserve native controller identity on ordinary selection. Rebuilding all tab
   controllers on every tap can erase the native feedback being requested. Check
   light appearance rather than hard-coding a dark material. Update badge data in
   the original item set even while only the collapsed selected item is visible.
6. Audit actual constructor fields. `sfSymbolMapper` appears in the 1.1.0 README
   but not its Dart constructor. Project-fork additions such as `LiquidTabItem.key`,
   `reduceTransparency`, or a static `expand()` are not upstream 1.1.0 APIs.

Use a small, documented compatibility patch only for demonstrated failures; do not
copy a product-specific fork as a general solution. Preserve upstream MIT notices
if copying its source. Recheck these findings before applying them to later versions.

## Validation

From the template folder:

```sh
flutter pub get
flutter analyze
flutter test
```

The [tests](../assets/flutter_tab_bar/test/apple_tab_bar_test.dart) exercise release
timing, cancellation/vertical gestures, off-center grabs, interruption, rejection,
external navigation, disabled/RTL input, keyboard/semantics, minimize, and layout.
Optional render output:

```sh
flutter test --dart-define=TAB_BAR_ARTIFACT_DIR=/tmp/tab-bar-review
# Optional: add --dart-define=TAB_BAR_FONT=/path/to/a/locally/licensed/font.ttf
```

Without `TAB_BAR_FONT`, captures use Flutter test placeholder glyphs and prove
layout only. Supplying a local font loads it plus the SDK Material icon font for
visual review; it does not bundle or redistribute the supplied font. Captures
include light/dark idle, held, stretched, and 320pt/300% text states.

The template declares Dart 3.8 / Flutter 3.32 API floors; actual verification was
on Flutter 3.47.5 / Dart 3.13.4. Older supported toolchains need their own run.
Inspect light/dark, large text, moving/held edges, and expansion on target hardware
before claiming gesture feel or performance. Widget rendering cannot validate the
package's UIKit material. Keep source, automated, rendered, and device claims separate.
