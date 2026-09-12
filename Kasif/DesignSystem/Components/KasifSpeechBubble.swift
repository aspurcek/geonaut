import SwiftUI

/// Figma Design System / Bileşenler / Speech Bubble (node 105:370). Maskot yanındaki
/// konuşma balonu — sol-alt köşesi keskin (xs=4), diğer köşeler md=16 radius.
struct KasifSpeechBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(KasifTypography.bodySemibold)
            .foregroundStyle(KasifColor.textPrimary)
            .padding(.horizontal, KasifSpacing.lg)
            .padding(.vertical, KasifSpacing.sm)
            .background {
                UnevenRoundedRectangle(
                    topLeadingRadius: KasifRadius.md,
                    bottomLeadingRadius: KasifSpacing.xs,
                    bottomTrailingRadius: KasifRadius.md,
                    topTrailingRadius: KasifRadius.md
                )
                .fill(KasifColor.bgSurface)
                .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 4)
            }
    }
}

#Preview {
    KasifSpeechBubble(text: "Hadi başlayalım!")
        .padding(KasifSpacing.xxxl)
        .background(KasifColor.bgCanvas)
}
