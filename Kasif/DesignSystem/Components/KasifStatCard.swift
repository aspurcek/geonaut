import SwiftUI

/// Figma Design System / Bileşenler / StatCard (node 150:449). Type=Puan/Strike/OgrenilenUlke.
enum KasifStatType {
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
        case .points: KasifColor.accentInfoStrong
        case .streak: KasifColor.accentPrimary
        case .countriesLearned: KasifColor.accentInfoStrong
        }
    }
}

struct KasifStatCard: View {
    let type: KasifStatType
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: type.systemImage)
                .font(.system(size: 22))
                .foregroundStyle(type.tint)
            Text(value)
                .font(KasifTypography.title)
                .foregroundStyle(KasifColor.textPrimary)
            Text(LocalizedStringKey(type.label))
                .font(KasifTypography.caption)
                .foregroundStyle(KasifColor.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, KasifSpacing.sm)
        .padding(.vertical, KasifSpacing.lg)
        .frame(width: 108, height: 88)
        .background(KasifColor.bgSurface, in: RoundedRectangle(cornerRadius: KasifRadius.lg))
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 4)
    }
}

#Preview {
    HStack(spacing: KasifSpacing.md) {
        KasifStatCard(type: .points, value: "340")
        KasifStatCard(type: .streak, value: "4")
        KasifStatCard(type: .countriesLearned, value: "4")
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
