import SwiftUI

/// Figma "Rozetler" (node 355:13868) — bkz. BadgeCatalog (Figma'nın kendisiyle
/// 2026-09-10'da doğrulanan güncel rozet/kupa sayıları, PDF kural kitaplarındaki
/// çelişkili rakamlar değil). Rozet durumları artık gerçek GameProgress'ten okunuyor
/// (önceden sabit/örnek veriydi).
struct BadgesView: View {
    @Binding var selectedTab: GeoTab
    let progress: GameProgress
    /// Profil'deki "Tümünü Gör" ile gelindiyse geri dönüş (başlıkta geri oku gösterilir); sekmeden gelindiyse nil.
    var onBack: (() -> Void)? = nil
    /// Kullanıcı kararı: rozete dokununca nasıl kazanılacağını (ve kazanıldıysa
    /// kazanıldığını) anlatan bir bottom sheet açılsın — bkz. badgeInfoSheet.
    @State private var selectedBadge: BadgeCardInfo?

    private var flagBadges: [BadgeCatalog.BadgeInfo] { BadgeCatalog.bayrakTahminBadges(progress: progress) }
    private var mapBadges: [BadgeCatalog.BadgeInfo] { BadgeCatalog.haritaBilmeceBadges(progress: progress) }
    private var languageBadges: [BadgeCatalog.BadgeInfo] { BadgeCatalog.anaDillerBadges(progress: progress) }
    private var foodBadges: [BadgeCatalog.BadgeInfo] { BadgeCatalog.dunyaYemekleriBadges(progress: progress) }
    private var capitalBadges: [BadgeCatalog.BadgeInfo] { BadgeCatalog.baskentlerBadges(progress: progress) }

    private var totalUnlocked: Int {
        (flagBadges + mapBadges + languageBadges + foodBadges + capitalBadges).filter { $0.unlocked && !BadgeCatalog.isTrophy($0) }.count
    }
    private var totalTrophiesUnlocked: Int {
        (flagBadges + mapBadges + languageBadges + foodBadges + capitalBadges).filter { $0.unlocked && BadgeCatalog.isTrophy($0) }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: GeoSpacing.xxl) {
                    GeoScreenHeader(title: "Rozetler & Kupalar", subtitle: "\(totalUnlocked) / \(BadgeCatalog.totalRozet) rozet, \(totalTrophiesUnlocked)/\(BadgeCatalog.totalKupa) kupa kazanıldı.", onBack: onBack)

                    badgeSection(
                        title: "Bayraklar", subtitle: "8 rozet + kategori kupası",
                        badges: flagBadges, displayTitle: Self.shortContinentName
                    )

                    badgeSection(
                        title: "Haritalar", subtitle: "2 rozet + kategori kupası",
                        badges: mapBadges
                    )

                    badgeSection(
                        title: "Diller", subtitle: "8 rozet + kategori kupası",
                        badges: languageBadges, displayTitle: Self.shortContinentName
                    )

                    badgeSection(
                        title: "Lezzetler", subtitle: "4 rozet + kategori kupası",
                        badges: foodBadges, displayTitle: Self.shortContinentName
                    )

                    badgeSection(
                        title: "Başkentler", subtitle: "8 rozet + kategori kupası",
                        badges: capitalBadges, displayTitle: Self.shortContinentName
                    )
                }
                .padding(.horizontal, GeoSpacing.xl)
                .padding(.top, GeoSpacing.md)
                .padding(.bottom, GeoSpacing.xxxl)
            }
            GeoNavBar(selection: $selectedTab)
        }
        .background(GeoColor.bgCanvas)
        .ignoresSafeArea(edges: .bottom)
        .badgeInfoSheet(selected: $selectedBadge)
    }

    private func badgeSection(title: String, subtitle: String, badges: [BadgeCatalog.BadgeInfo], displayTitle: @escaping (String) -> String = { $0 }) -> some View {
        VStack(alignment: .leading, spacing: GeoSpacing.lg) {
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey(title))
                    .font(.custom(GeoFontName.balooBold, size: 20))
                    .foregroundStyle(GeoColor.textPrimary)
                Text(LocalizedStringKey(subtitle))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(GeoColor.textMuted)
            }

            GeoFlowLayout {
                ForEach(badges, id: \.title) { badge in
                    Button {
                        selectedBadge = BadgeCardInfo(
                            title: badge.title, icon: badge.icon, accentColor: badge.accentColor,
                            unlocked: badge.unlocked, description: badge.description
                        )
                    } label: {
                        GeoAchievementBadge(title: displayTitle(badge.title), icon: badge.icon, accentColor: badge.accentColor, state: badge.unlocked ? .unlocked : .locked)
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
