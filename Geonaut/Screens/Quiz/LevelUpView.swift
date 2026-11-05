import SwiftUI

/// Figma "Ünvan Yükseldi" (FLOW7- Tebrik Ekranları). Etap bitince puan, oyuncuyu bir üst
/// ünvana taşıdıysa (bkz. GeoLevel) rozet/kupa ekranlarından ÖNCE gösterilir.
struct LevelUpView: View {
    let from: GeoLevel
    let to: GeoLevel
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: GeoSpacing.lg) {
            Spacer()

            AchievementChip(text: "YENİ ÜNVAN", color: to.accentColor)

            Circle()
                .fill(to.accentColor)
                .frame(width: 128, height: 128)
                .overlay { Text(to.emoji).font(.system(size: 60)) }
                .kasifWinGlow(color: to.accentColor)

            Text("\(L(to.title)) oldun!")
                .font(.custom(GeoFontName.balooBold, size: 24))
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)

            Text(to == .efsanevi
                 ? LocalizedStringKey("En yüksek ünvana ulaştın. Dünya senin haritan!")
                 : LocalizedStringKey("\(L(from.title)) → \(L(to.title))\nKeşfetmeye devam et!"))
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(GeoColor.textSecondary)
                .multilineTextAlignment(.center)

            levelPath

            Button("Harika!", action: onContinue)
                .buttonStyle(.kasifPrimary)
                .frame(maxWidth: .infinity)
                .padding(.top, GeoSpacing.sm)

            Spacer()
        }
        .padding(.horizontal, GeoSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
        .achievementCelebration(confetti: true)
    }

    /// 6 ünvanlık yol: ulaşılanlar dolu, bulunulan ünvan biraz daha büyük.
    private var levelPath: some View {
        HStack(spacing: 8) {
            ForEach(Array(GeoLevel.allCases.enumerated()), id: \.offset) { index, _ in
                Circle()
                    .fill(index <= to.rank ? to.accentColor : GeoColor.bgLocked)
                    .frame(width: index == to.rank ? 16 : 12, height: index == to.rank ? 16 : 12)
            }
        }
        .accessibilityHidden(true)
    }
}

extension GeoLevel {
    /// Kademe sırası (0 = Çaylak ... 5 = Efsanevi) — ünvan yükselip yükselmediğini karşılaştırmak için.
    var rank: Int { Self.allCases.firstIndex(of: self) ?? 0 }

    var emoji: String {
        switch self {
        case .caylak: "🌱"
        case .gezgin: "🧭"
        case .maceraci: "🎒"
        case .yolUstasi: "🗺️"
        case .dunyaGezgini: "🌍"
        case .efsanevi: "👑"
        }
    }

    var accentColor: Color {
        switch self {
        case .caylak: GeoColor.accentPrimarySoft
        case .gezgin: GeoColor.accentSuccess
        case .maceraci: GeoColor.accentInfo
        case .yolUstasi: GeoColor.accentTertiary
        case .dunyaGezgini: GeoColor.accentPrimary
        case .efsanevi: GeoColor.accentHighlight
        }
    }
}

#Preview {
    LevelUpView(from: .caylak, to: .gezgin, onContinue: {})
}

#Preview("Efsanevi") {
    LevelUpView(from: .dunyaGezgini, to: .efsanevi, onContinue: {})
}
