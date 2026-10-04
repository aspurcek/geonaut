import SwiftUI

/// Figma Design System / Bileşenler / Progress Bar (node 105:357). 0-1 arası ilerleme.
struct KasifProgressBar: View {
    /// 0...1 aralığında ilerleme oranı.
    var progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(KasifColor.bgLocked)
                Capsule()
                    .fill(KasifColor.accentSuccess)
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
    VStack(spacing: KasifSpacing.lg) {
        KasifProgressBar(progress: 0.55)
        KasifProgressBar(progress: 0.1)
        KasifProgressBar(progress: 1.0)
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
