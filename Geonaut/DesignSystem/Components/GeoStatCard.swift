import SwiftUI

/// Figma Design System / Bileşenler / StatCard (node 150:449). Type=Puan/Strike/OgrenilenUlke.
enum GeoStatType {
    case points, streak, countriesLearned

    var label: String {
        switch self {
        case .points: "Puan"
        case .streak: "Günlük Seri"
        case .countriesLearned: "Öğrenilen Ülke"
        }
    }

    var systemImage: String {
        switch self {
        case .points: "diamond.fill"
        case .streak: "flame.fill"
        case .countriesLearned: "globe.europe.africa.fill"
        }
    }

    var tint: Color {
        switch self {
        case .points: GeoColor.accentInfoStrong
        case .streak: GeoColor.accentPrimary
        case .countriesLearned: GeoColor.accentInfoStrong
        }
    }
}

struct GeoStatCard: View {
    let type: GeoStatType
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: type.systemImage)
                .font(.system(size: 22))
                .foregroundStyle(type.tint)
            Text(value)
                .font(GeoTypography.title)
                .foregroundStyle(GeoColor.textPrimary)
            Text(LocalizedStringKey(type.label))
                .font(GeoTypography.caption)
                .foregroundStyle(GeoColor.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, GeoSpacing.sm)
        .padding(.vertical, GeoSpacing.lg)
        .frame(width: 108, height: 88)
        .background(GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: GeoRadius.lg))
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 4)
    }
}

#Preview {
    HStack(spacing: GeoSpacing.md) {
        GeoStatCard(type: .points, value: "340")
        GeoStatCard(type: .streak, value: "4")
        GeoStatCard(type: .countriesLearned, value: "4")
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
