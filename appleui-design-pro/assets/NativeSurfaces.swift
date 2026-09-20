// API examples. Build with an iOS 26+ SDK; runtime availability is explicit.
#if os(iOS)
import UIKit
import SwiftUI
import WidgetKit

@MainActor
@available(iOS 26.0, *)
func makeProGlassSurface() -> UIVisualEffectView {
    let effect = UIGlassEffect(style: .regular)
    let surface = UIVisualEffectView(effect: effect)
    let label = UILabel()
    label.text = String(localized: "Quick actions")
    label.font = .preferredFont(forTextStyle: .headline)
    label.adjustsFontForContentSizeCategory = true
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    surface.contentView.addSubview(label)
    NSLayoutConstraint.activate([
        label.leadingAnchor.constraint(equalTo: surface.contentView.leadingAnchor, constant: 16),
        label.trailingAnchor.constraint(equalTo: surface.contentView.trailingAnchor, constant: -16),
        label.topAnchor.constraint(equalTo: surface.contentView.topAnchor, constant: 12),
        label.bottomAnchor.constraint(equalTo: surface.contentView.bottomAnchor, constant: -12)
    ])
    // The caller lays out this surface. Add UIControls for actual actions.
    return surface
}

@available(iOS 18.0, *)
struct ProWidgetContent: View {
    @Environment(\.widgetRenderingMode) private var renderingMode
    let title: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline).widgetAccentable()
            Image(systemName: "star.fill")
                .widgetAccentedRenderingMode(.accentedDesaturated)
                .accessibilityHidden(true)
            Text(renderingMode == .accented ? "Summary" : "Latest summary")
                .font(.caption)
        }
        .containerBackground(for: .widget) { Color.clear }
    }
}
#endif
