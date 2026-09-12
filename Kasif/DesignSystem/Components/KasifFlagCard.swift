import SwiftUI

/// Figma Design System / Bileşenler / Flag Card (node 123:372). "Bayrakları Öğren"
/// ızgarasındaki kart — büyük bayrak + sağ üstte küçük bir "görüldü" rozeti.
struct KasifFlagCard: View {
    let countryCode: String
    var showSeenBadge: Bool = true

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: KasifRadius.lg)
                .fill(KasifColor.bgSurface)
                .frame(width: 148, height: 108)
                .shadow(color: KasifColor.accentPrimary.opacity(0.35), radius: 9, x: 0, y: 8)
                .overlay {
                    Text(KasifFlagAnswerOption.flagEmoji(for: countryCode))
                        .font(.system(size: 56))
                        .frame(width: 120, height: 80)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: KasifRadius.md))
                }

            if showSeenBadge {
                Circle()
                    .fill(KasifColor.accentSuccess)
                    .frame(width: 30, height: 30)
                    .overlay {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .offset(x: -4, y: -9)
            }
        }
        .frame(width: 148, height: 108, alignment: .topLeading)
    }
}

#Preview {
    HStack(spacing: KasifSpacing.xl) {
        KasifFlagCard(countryCode: "IT")
        KasifFlagCard(countryCode: "TR", showSeenBadge: false)
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
