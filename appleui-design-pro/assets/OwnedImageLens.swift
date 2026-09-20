import SwiftUI

// Add AppleUILens.metal to the same app target. This filters the supplied image;
// it cannot capture unrelated SwiftUI siblings. Overlay real controls separately.
@available(iOS 17.0, macOS 14.0, *)
struct OwnedImageLens: View {
    let source: Image

    var body: some View {
        GeometryReader { geometry in
            let extent = min(geometry.size.width, geometry.size.height)
            let radius = extent * 0.18
            let maximumOffset = extent * 0.025
            source
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .distortionEffect(
                    ShaderLibrary.appleUILens(
                        .boundingRect, .float(0.18), .float(0.18), .float(0.025)
                    ),
                    maxSampleOffset: CGSize(width: maximumOffset, height: maximumOffset)
                )
                .clipShape(RoundedRectangle(cornerRadius: radius, style: .circular))
        }
    }
}
