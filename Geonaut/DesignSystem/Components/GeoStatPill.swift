import SwiftUI

/// Figma Design System / Bileşenler / Stat Pill (node 105:365). Icon=Streak/Points/Hearts.
/// Oyun ekranlarının üst çubuğunda can/puan/seri göstergesi olarak kullanılır.
enum GeoStatPillIcon {
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
        case .streak: GeoColor.accentPrimary
        case .points: GeoColor.accentInfoStrong
        case .hearts: GeoColor.accentDanger
        }
    }
}

struct GeoStatPill: View {
    let icon: GeoStatPillIcon
    let value: String

    var body: some View {
        HStack(spacing: GeoSpacing.sm) {
            Image(systemName: icon.systemImage)
                .font(.system(size: 18))
                .foregroundStyle(icon.tint)
            Text(value)
                .font(GeoTypography.bodyBoldL)
                .foregroundStyle(GeoColor.textPrimary)
        }
        .padding(.leading, GeoSpacing.md)
        .padding(.trailing, GeoSpacing.lg)
        .padding(.vertical, GeoSpacing.sm)
        .background(GeoColor.bgSurface, in: Capsule())
        .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        switch icon {
        case .streak: return String(localized: "Seri: \(value) gün")
        case .points: return String(localized: "\(value) puan")
        case .hearts: return String(localized: "\(value) can")
        }
    }
}

#Preview {
    HStack(spacing: GeoSpacing.md) {
        GeoStatPill(icon: .streak, value: "12")
        GeoStatPill(icon: .points, value: "340")
        GeoStatPill(icon: .hearts, value: "3")
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
