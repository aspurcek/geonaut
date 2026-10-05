import SwiftUI

/// Figma Design System / Bileşenler / Flag Card (node 123:372). "Bayrakları Öğren"
/// ızgarasındaki kart — büyük bayrak + sağ üstte küçük bir "görüldü" rozeti.
struct GeoFlagCard: View {
    let countryCode: String
    var showSeenBadge: Bool = true

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: GeoRadius.lg)
                .fill(GeoColor.bgSurface)
                .frame(width: 148, height: 108)
                .shadow(color: GeoColor.accentPrimary.opacity(0.35), radius: 9, x: 0, y: 8)
                .overlay {
                    Text(GeoFlagAnswerOption.flagEmoji(for: countryCode))
                        .font(.system(size: 56))
                        .frame(width: 120, height: 80)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: GeoRadius.md))
                }

            if showSeenBadge {
                Circle()
                    .fill(GeoColor.accentSuccess)
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
    HStack(spacing: GeoSpacing.xl) {
        GeoFlagCard(countryCode: "IT")
        GeoFlagCard(countryCode: "TR", showSeenBadge: false)
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
