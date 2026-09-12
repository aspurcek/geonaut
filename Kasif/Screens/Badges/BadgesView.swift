import SwiftUI

/// Figma "Rozetler" (node 355:13868) — bkz. BadgeCatalog (Figma'nın kendisiyle
/// 2026-09-10'da doğrulanan güncel rozet/kupa sayıları, PDF kural kitaplarındaki
/// çelişkili rakamlar değil). Rozet durumları artık gerçek GameProgress'ten okunuyor
/// (önceden sabit/örnek veriydi).
struct BadgesView: View {
    @Binding var selectedTab: KasifTab
    let progress: GameProgress

    private var flagBadges: [BadgeCatalog.BadgeInfo] { BadgeCatalog.bayrakTahminBadges(progress: progress) }
    private var mapBadges: [BadgeCatalog.BadgeInfo] { BadgeCatalog.haritaBilmeceBadges(progress: progress) }

    private var totalUnlocked: Int {
        (flagBadges + mapBadges).filter(\.unlocked).count
    }
    private var totalTrophiesUnlocked: Int {
        (flagBadges + mapBadges).filter { $0.unlocked && $0.title.hasSuffix("Kupası") }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: KasifSpacing.xxl) {
                    VStack(alignment: .leading, spacing: KasifSpacing.xs) {
                        Text("Rozetler & Kupalar")
                            .font(.custom(KasifFontName.balooExtraBold, size: 24))
                            .foregroundStyle(KasifColor.textPrimary)
                        Text("\(totalUnlocked) / \(BadgeCatalog.totalRozet) rozet, \(totalTrophiesUnlocked)/\(BadgeCatalog.totalKupa) kupa kazanıldı.")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(KasifColor.textSecondary)
                    }

                    badgeSection(
                        title: "Bayrak Tahmin", subtitle: "9 rozet + kategori kupası",
                        badges: flagBadges.map { (title: Self.shortContinentName($0.title), image: $0.systemImage, unlocked: $0.unlocked) }
                    )

                    badgeSection(
                        title: "Harita Bilmece", subtitle: "2 rozet + kategori kupası",
                        badges: mapBadges.map { (title: $0.title, image: $0.systemImage, unlocked: $0.unlocked) }
                    )

                    badgeSection(
                        title: "Ana Diller",
                        subtitle: "yakında",
                        badges: [(title: "Yakında", image: "lock.fill", unlocked: false)]
                    )
                }
                .padding(.horizontal, KasifSpacing.xl)
                .padding(.top, KasifSpacing.md)
                .padding(.bottom, KasifSpacing.xxxl)
            }
            KasifNavBar(selection: $selectedTab)
        }
        .background(KasifColor.bgCanvas)
        .ignoresSafeArea(edges: .bottom)
    }

    private func badgeSection(title: String, subtitle: String, badges: [(title: String, image: String, unlocked: Bool)]) -> some View {
        VStack(alignment: .leading, spacing: KasifSpacing.lg) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom(KasifFontName.balooBold, size: 20))
                    .foregroundStyle(KasifColor.textPrimary)
                Text(subtitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(KasifColor.textMuted)
            }

            KasifFlowLayout {
                ForEach(badges, id: \.title) { badge in
                    KasifAchievementBadge(title: badge.title, systemImage: badge.image, state: badge.unlocked ? .unlocked : .locked)
                }
            }
        }
    }

    /// Figma'da "Kuzey Amerika"/"Güney Amerika" rozet ızgarasında yer tasarrufu için
    /// "K. Amerika"/"G. Amerika" olarak kısaltılmış (bkz. node 355:13868). Model
    /// tarafındaki tam isimler (FlagGuessStructure, ilerleme takibi) değişmiyor —
    /// bu yalnızca görüntü metni.
    private static func shortContinentName(_ continent: String) -> String {
        switch continent {
        case "Kuzey Amerika": return "K. Amerika"
        case "Güney Amerika": return "G. Amerika"
        default: return continent
        }
    }
}

#Preview {
    BadgesView(selectedTab: .constant(.cups), progress: GameProgress())
}
