import SwiftUI

/// Figma "Rozetler" (node 355:13868) — bkz. BadgeCatalog (Figma'nın kendisiyle
/// 2026-09-10'da doğrulanan güncel rozet/kupa sayıları, PDF kural kitaplarındaki
/// çelişkili rakamlar değil). Rozet durumları artık gerçek GameProgress'ten okunuyor
/// (önceden sabit/örnek veriydi).
struct BadgesView: View {
    @Binding var selectedTab: KasifTab
    let progress: GameProgress
    /// Kullanıcı kararı: rozete dokununca nasıl kazanılacağını (ve kazanıldıysa
    /// kazanıldığını) anlatan bir bottom sheet açılsın — bkz. badgeInfoSheet.
    @State private var selectedBadge: BadgeCardInfo?

    private var flagBadges: [BadgeCatalog.BadgeInfo] { BadgeCatalog.bayrakTahminBadges(progress: progress) }
    private var mapBadges: [BadgeCatalog.BadgeInfo] { BadgeCatalog.haritaBilmeceBadges(progress: progress) }
    private var languageBadges: [BadgeCatalog.BadgeInfo] { BadgeCatalog.anaDillerBadges(progress: progress) }
    private var foodBadges: [BadgeCatalog.BadgeInfo] { BadgeCatalog.dunyaYemekleriBadges(progress: progress) }

    private var totalUnlocked: Int {
        (flagBadges + mapBadges + languageBadges + foodBadges).filter(\.unlocked).count
    }
    private var totalTrophiesUnlocked: Int {
        (flagBadges + mapBadges + languageBadges + foodBadges).filter { $0.unlocked && BadgeCatalog.categoryTrophyName.values.contains($0.title) }.count
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
                        title: "Bayraklar", subtitle: "9 rozet + kategori kupası",
                        badges: flagBadges, displayTitle: Self.shortContinentName
                    )

                    badgeSection(
                        title: "Haritalar", subtitle: "2 rozet + kategori kupası",
                        badges: mapBadges
                    )

                    badgeSection(
                        title: "Diller", subtitle: "9 rozet + kategori kupası",
                        badges: languageBadges, displayTitle: Self.shortContinentName
                    )

                    badgeSection(
                        title: "Lezzetler", subtitle: "5 rozet + kategori kupası",
                        badges: foodBadges, displayTitle: Self.shortContinentName
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
        .badgeInfoSheet(selected: $selectedBadge)
    }

    private func badgeSection(title: String, subtitle: String, badges: [BadgeCatalog.BadgeInfo], displayTitle: @escaping (String) -> String = { $0 }) -> some View {
        VStack(alignment: .leading, spacing: KasifSpacing.lg) {
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey(title))
                    .font(.custom(KasifFontName.balooBold, size: 20))
                    .foregroundStyle(KasifColor.textPrimary)
                Text(LocalizedStringKey(subtitle))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(KasifColor.textMuted)
            }

            KasifFlowLayout {
                ForEach(badges, id: \.title) { badge in
                    Button {
                        selectedBadge = BadgeCardInfo(
                            title: badge.title, icon: badge.icon, accentColor: badge.accentColor,
                            unlocked: badge.unlocked, description: badge.description
                        )
                    } label: {
                        KasifAchievementBadge(title: displayTitle(badge.title), icon: badge.icon, accentColor: badge.accentColor, state: badge.unlocked ? .unlocked : .locked)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    /// Figma'da "Kuzey Amerika"/"Güney Amerika" rozet ızgarasında yer tasarrufu için
    /// "K. Amerika"/"G. Amerika" olarak kısaltılmış (bkz. node 355:13868). Model
    /// tarafındaki tam isimler (FlagGuessStructure, ilerleme takibi) değişmiyor —
    /// bu yalnızca görüntü metni.
    nonisolated private static func shortContinentName(_ continent: String) -> String {
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
