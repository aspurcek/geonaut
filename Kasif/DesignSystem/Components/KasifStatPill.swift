import SwiftUI

/// Figma Design System / Bileşenler / Stat Pill (node 105:365). Icon=Streak/Points/Hearts.
/// Oyun ekranlarının üst çubuğunda can/puan/seri göstergesi olarak kullanılır.
enum KasifStatPillIcon {
    case streak, points, hearts

    var systemImage: String {
        switch self {
        case .streak: "flame.fill"
        case .points: "diamond.fill"
        case .hearts: "heart.fill"
        }
    }

    var tint: Color {
        switch self {
        case .streak: KasifColor.accentPrimary
        case .points: KasifColor.accentInfoStrong
        case .hearts: KasifColor.accentDanger
        }
    }
}

struct KasifStatPill: View {
    let icon: KasifStatPillIcon
    let value: String

    var body: some View {
        HStack(spacing: KasifSpacing.sm) {
            Image(systemName: icon.systemImage)
                .font(.system(size: 18))
                .foregroundStyle(icon.tint)
            Text(value)
                .font(KasifTypography.bodyBoldL)
                .foregroundStyle(KasifColor.textPrimary)
        }
        .padding(.leading, KasifSpacing.md)
        .padding(.trailing, KasifSpacing.lg)
        .padding(.vertical, KasifSpacing.sm)
        .background(KasifColor.bgSurface, in: Capsule())
        .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 2)
    }
}

#Preview {
    HStack(spacing: KasifSpacing.md) {
        KasifStatPill(icon: .streak, value: "12")
        KasifStatPill(icon: .points, value: "340")
        KasifStatPill(icon: .hearts, value: "3")
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
