# Accessibility across AppleUI implementations

Use meaningful native/Cupertino/HTML controls first. Preserve name, role, value,
state, and action in the accessibility tree. A blur layer or a custom shader should
not replace the controls' semantics.

## Cross-platform mapping

| Need | SwiftUI/UIKit | Flutter | Web |
| --- | --- | --- | --- |
| Label and value | accessibilityLabel/accessibilityValue | Semantics or built-in widget semantics | Native label/name and value; ARIA where necessary |
| Decorative image | accessibilityHidden | ExcludeSemantics | aria-hidden or empty alt |
| Independent actions | Keep separate children | Keep distinct semantic nodes | Separate controls |
| Related read-only content | Combine when useful | MergeSemantics when suitable | Logical reading order/group |
| Keyboard | Native focus/shortcuts | Focus, Shortcuts, Actions | Native focus and key behavior |
| Reduce Motion | accessibilityReduceMotion | disableAnimations; inspect platform behavior | prefers-reduced-motion |
| Reduce Transparency | accessibilityReduceTransparency | Explicit signal/bridge if SDK does not expose it | prefers-reduced-transparency + solid fallback |
| Increase Contrast | colorSchemeContrast/UIAccessibility | highContrast | prefers-contrast / forced-colors |
| Scalable text | Dynamic Type/semantic fonts | TextScaler/MediaQuery + adaptive layout | Browser zoom and relative type |

## Controls and reading order

Localize semantic labels. Avoid redundant hints such as “double tap to activate” on
every button; assistive technology supplies standard instructions. Explain unusual
outcomes instead. An accessibility identifier is a test locator, not the spoken name.
Use stable project conventions for identifiers without creating a new framework.

Keep focus visible, reachable, and unobscured by floating glass. Modals contain focus
while open, provide an exit, and return focus appropriately. Do not combine a card's
children if that hides its independent links, buttons, or form fields. Announce
important status changes using supported platform APIs, without repeated chatter.
Do not invent a SwiftUI live-region modifier from a web analogy; verify the SDK.

Give essential dragging an alternate action, such as increment/decrement, selection,
or explicit move controls. Preserve keyboard and switch-control operation. A visible
small icon can have a larger hit area. For touch on iOS, a 44-by-44-point target is a
useful native baseline; do not conflate that with web CSS-pixel criteria or desktop
pointer targets. A 44-point fixed height must not truncate a larger label.

## Material and contrast

Assess foreground against the *composited* surface on actual backgrounds, including
text, photography, light/dark extremes, and moving content. Color alone must not
convey status. Use semantic color, text, symbols, borders, or shape as needed.
Contrast calculations based only on a declared translucent fill can be misleading.
Common text targets are 4.5:1 for normal text and 3:1 for large text; applying those
numbers alone is not a complete accessibility audit.

Native glass adjusts to system settings. Custom overlays, fixed colors, refraction,
and older-OS fallbacks must also respond. Reduced transparency may legitimately
remove the lens; increased contrast may need solid surfaces and a defined boundary.
Reduce Motion removes unnecessary displacement/elastic motion while preserving an
immediate or gentle state change. Check settings changed while the view is mounted.

## Reflow and verification

Check large accessibility text, long translations, RTL, bold text where relevant,
keyboard visibility, and narrow windows. Avoid fixed multiline heights, clipping,
blanket font shrinking, and disabled zoom. Read through the actual screen with
VoiceOver or the available semantics tools; inspect both order and action outcomes.
Automated tests and screenshots complement this, but neither proves the entire
experience accessible. Record the settings and platform actually checked.
