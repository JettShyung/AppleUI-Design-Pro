// AppleUI Design Pro. Xcode 16+ SDK; iOS 17+/macOS 14+ example.
// Passive content card: native Button/Toggle semantics belong in actual controls.
import SwiftUI

public protocol ProCardStyle: DynamicProperty {
    associatedtype Body: View
    typealias Configuration = ProCardStyleConfiguration
    @ViewBuilder @MainActor func makeBody(configuration: Configuration) -> Body
}

public struct ProCardStyleConfiguration {
    public struct Content: View {
        private let value: AnyView
        @MainActor init<V: View>(_ value: V) { self.value = AnyView(value) }
        public var body: some View { value }
    }
    public let content: Content
    @MainActor init<V: View>(content: V) { self.content = Content(content) }
}

public struct AutomaticProCardStyle: ProCardStyle {
    public init() {}
    @MainActor public func makeBody(configuration: Configuration) -> some View {
        CardSurface(content: configuration.content, outlined: false)
    }
}

public struct OutlinedProCardStyle: ProCardStyle {
    public init() {}
    @MainActor public func makeBody(configuration: Configuration) -> some View {
        CardSurface(content: configuration.content, outlined: true)
    }
}

// Dynamic properties are hosted in a real View returned by the style.
private struct CardSurface: View {
    let content: ProCardStyleConfiguration.Content
    let outlined: Bool
    @Environment(\.colorSchemeContrast) private var contrast
    @ScaledMetric(relativeTo: .body) private var inset = 16.0

    var body: some View {
        content
            .padding(inset)
            .background(.background, in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        contrast == .increased ? Color.primary : Color.secondary,
                        lineWidth: outlined || contrast == .increased ? 1 : 0
                    )
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
    }
}

extension ProCardStyle where Self == AutomaticProCardStyle {
    public static var automatic: Self { .init() }
}
extension ProCardStyle where Self == OutlinedProCardStyle {
    public static var outlined: Self { .init() }
}
private struct ProCardStyleKey: EnvironmentKey {
    static var defaultValue: any ProCardStyle { AutomaticProCardStyle() }
}
extension EnvironmentValues {
    var proCardStyle: any ProCardStyle {
        get { self[ProCardStyleKey.self] }
        set { self[ProCardStyleKey.self] = newValue }
    }
}
extension View {
    public func proCardStyle(_ style: some ProCardStyle) -> some View {
        environment(\.proCardStyle, style)
    }
}

public struct ProCard<Content: View>: View {
    @Environment(\.proCardStyle) private var style
    private let content: Content

    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: some View { resolve(style) }

    private func resolve<S: ProCardStyle>(_ style: S) -> AnyView {
        AnyView(style.makeBody(configuration: .init(content: content)))
    }
}

// Usage: ProCard { Text("Summary") }.proCardStyle(.outlined)
