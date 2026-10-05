import SwiftUI

/// Figma Design System / Bileşenler / Progress Bar (node 105:357). 0-1 arası ilerleme.
struct GeoProgressBar: View {
    /// 0...1 aralığında ilerleme oranı.
    var progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(GeoColor.bgLocked)
                Capsule()
                    .fill(GeoColor.accentSuccess)
                    .frame(width: geometry.size.width * min(max(progress, 0), 1))
            }
        }
        .frame(height: 14)
        .animation(.easeOut(duration: 0.3), value: progress)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("İlerleme")
        .accessibilityValue(String(localized: "yüzde \(Int(min(max(progress, 0), 1) * 100))"))
    }
}

#Preview {
    VStack(spacing: GeoSpacing.lg) {
        GeoProgressBar(progress: 0.55)
        GeoProgressBar(progress: 0.1)
        GeoProgressBar(progress: 1.0)
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
