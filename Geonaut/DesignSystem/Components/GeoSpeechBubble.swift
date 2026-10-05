import SwiftUI

/// Figma Design System / Bileşenler / Speech Bubble (node 105:370). Maskot yanındaki
/// konuşma balonu — sol-alt köşesi keskin (xs=4), diğer köşeler md=16 radius.
struct GeoSpeechBubble: View {
    let text: String

    var body: some View {
        Text(LocalizedStringKey(text))
            .font(GeoTypography.bodySemibold)
            .foregroundStyle(GeoColor.textPrimary)
            .padding(.horizontal, GeoSpacing.lg)
            .padding(.vertical, GeoSpacing.sm)
            .background {
                UnevenRoundedRectangle(
                    topLeadingRadius: GeoRadius.md,
                    bottomLeadingRadius: GeoSpacing.xs,
                    bottomTrailingRadius: GeoRadius.md,
                    topTrailingRadius: GeoRadius.md
                )
                .fill(GeoColor.bgSurface)
                .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 4)
            }
    }
}

#Preview {
    GeoSpeechBubble(text: "Hadi başlayalım!")
        .padding(GeoSpacing.xxxl)
        .background(GeoColor.bgCanvas)
}
