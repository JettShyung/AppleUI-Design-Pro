# SwiftUI style-driven components

Source coverage: all ten references in Ahmad Barakat's repository: structure,
protocol/configuration, environment, common patterns, advanced patterns, tokens,
documentation, previews, testing, and accessibility.

## Choose the smallest useful customization boundary

Start with `ButtonStyle`, `ToggleStyle`, `LabelStyle`, `TextFieldStyle`, or an ordinary
view/modifier. A single-appearance component does not need its own style protocol.
Use a custom style when multiple meaningful layouts/appearances or actual client
extensions need one public semantic component. Different colors alone can be data.

The pattern is **component owns semantics/state → configuration describes content and
state → style renders → environment selects a style for a subtree**. Adding an
appearance should not require editing component behavior.

## Public API and internal rendering

- Use a generic `@ViewBuilder` content initializer. Accept the actual content,
  bindings, actions, and roles rather than a caller-created style configuration.
- Give the style an associated `Body: View`, a `Configuration` alias, and a
  `@ViewBuilder @MainActor makeBody(configuration:)` method.
- `DynamicProperty` is the source's style protocol convention. It does **not**
  itself mount a style's `@Environment` or `@State` merely because the style is
  stored inside an existential environment value and manually called.
- The conservative custom pattern: keep the style as immutable rendering policy;
  return a real nested `View` that owns dynamic properties. Or use a correctly
  hosted generic resolver and test updates. Prefer native style protocols when
  they already supply the desired hosting and semantics.
- Configuration creation is internal. Expose nested `Content`/`Label`/`Header`
  view wrappers as needed, with type erasure hidden inside, rather than exposing
  `AnyView` as the public property type. Keep input content generic.
- Open the environment's `any CardStyle` through a generic resolver before erasing
  its result to `AnyView`. Erase at that boundary; do not erase every conditional
  row or every list item unnecessarily.

See [StyleDrivenCard.swift](../assets/StyleDrivenCard.swift) for a complete passive
card example. The card does not accept an unused action. A tappable card should
contain or be a `Button`; decorative styling does not supply activation semantics.

## Environment, defaults, and convenience

Store a concrete default style using an environment entry; allow a parent subtree
to set it and a child to override it. The public modifier can take `some CardStyle`.
`@Entry` is a SwiftUI macro supplied by newer SDK/toolchains (Xcode 16 generation),
not a capability guaranteed merely by having Swift 5.9. Use an explicit
`EnvironmentKey` when the toolchain needs it; respect Swift 6 static/default-value
isolation rather than silencing warnings with unchecked sendability.

Constrained extensions can expose `.automatic`, `.compact`, or `.tinted(color)`.
Styles can carry immutable parameters. Put adaptive environment reads in the style's
returned view. Verify theme/Dynamic Type updates after mounting, not just initial render.

For text initializers distinguish localized keys from runtime/verbatim strings. For
editable components pass a `Binding` in configuration so styles operate on the same
source of truth. Never copy a parent value into child state simply to style it.

Semantic roles should drive native behavior: password → secure field, email →
appropriate keyboard/autocorrection/content type, OTP → one-time-code content type.
Do not hardwire a digits-only phone keyboard for every international number. Keep
platform-specific keyboard APIs behind platform conditions.

## Structure and documentation

Use `Component`, `ComponentStyle`, `ComponentStyleConfiguration`, a default style,
and environment modifier names consistently. A small component can keep these in
one file; a library may split environment keys/styles/previews/tests. Shared layout
belongs in a helper view only when actual styles reuse it. MARK sections and preview
enums are project conventions, not correctness requirements.

Document public semantics, parameters, state ownership, accessibility, style scope,
and one ordinary/one subtree usage example. Link related symbols with DocC when
publishing a package. Keep implementation details internal. Reuse design tokens;
do not generate a token type for every one-off numeric literal.

## Advanced patterns: use only where they buy independence

| Need | Pattern | Boundary |
| --- | --- | --- |
| Distinct mutually exclusive visual phases | Enum state plus explicit transitions | Start with an enum, not one protocol/struct per phase |
| Several interchangeable transition policies | Separate pure behavior from rendering | Test all transitions; avoid passing UI closures/bindings across actor boundaries |
| Styles and layouts can combine independently | Separate style and layout customization | Use SwiftUI `Layout` when it covers the arrangement |
| Repeated declarative child descriptors | Result builder | Support conditionals/arrays only as needed; prefer ViewBuilder for ordinary views |

Sendability describes safe cross-isolation data, not “a protocol that looks pure.”
Do not mark behaviors `Sendable` while they transport non-Sendable UI configuration
across actors. A style should not mutate business state during rendering.

## Test the contract

Check default style, parent cascade, child override, live environment changes, and
state preservation when switching appearance. For controls check disabled, role,
press/cancel, keyboard, and VoiceOver behavior. Use localized labels, scalable text,
and an adequate hit region independent of the visible decoration. Do not merge an
entire card's accessibility children if it contains independent buttons or fields.

Previews: variants, realistic content, long/empty content, light/dark, large text,
and in-context placement. Stateful preview data belongs in a view, not a static enum.
Snapshot tests are optional tooling for meaningful visual regressions; don't add a
package or duplicate every preview into a test by decree. See [testing](review-testing.md).
