// Build with Xcode 26+ SDK. Fallback supports iOS 17 / macOS 14.
import SwiftUI

#if os(iOS) || os(macOS)
public struct ProGlassActions: View {
    public let onSave: () -> Void
    public let onFavorite: () -> Void
    @Binding private var expanded: Bool
    @Namespace private var effects
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(expanded: Binding<Bool>, onSave: @escaping () -> Void, onFavorite: @escaping () -> Void) {
        self._expanded = expanded
        self.onSave = onSave
        self.onFavorite = onFavorite
    }

    public var body: some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            glassActions
        } else {
            fallbackActions
        }
    }

    private func toggleExpanded() {
        withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 1)) {
            expanded.toggle()
        }
    }

    @available(iOS 26.0, macOS 26.0, *)
    @ViewBuilder
    private var glassActions: some View {
        // Container and layout gap intentionally match; tune after visual inspection.
        GlassEffectContainer(spacing: 16) {
            HStack(spacing: 16) {
                Button(action: toggleExpanded) {
                    Label(expanded ? "Fewer actions" : "More actions",
                          systemImage: expanded ? "minus" : "plus")
                        .padding(.horizontal, 16)
                        .frame(minHeight: 44)
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .capsule)
                .glassEffectID("expand", in: effects)

                if expanded {
                    Button(action: onFavorite) {
                        Label("Favorite", systemImage: "star")
                            .padding(.horizontal, 16)
                            .frame(minHeight: 44)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.interactive(), in: .capsule)
                    .glassEffectID("favorite", in: effects)
                }
            }
        }
        Button("Save", action: onSave)
            .buttonStyle(.glassProminent)
    }

    private var fallbackActions: some View {
        VStack(alignment: .leading) {
            Button(expanded ? "Fewer actions" : "More actions", action: toggleExpanded)
            if expanded { Button("Favorite", action: onFavorite) }
            Button("Save", action: onSave).buttonStyle(.borderedProminent)
        }
        .buttonStyle(.bordered)
    }
}
#endif
