import SwiftUI

/// Rozetler & Kupalar ekranı (Figma node 355:13868, kullanıcı tarafından 2026-09-10'da
/// tasarım üzerinden doğrulandı — bu dosyadaki sayılar PDF kural kitaplarındaki
/// çelişkili rakamları değil, Figma'nın kendisini esas alır).
///
/// Ekranda iki ayrı sayaç var: "rozet" (tüm kazanımlar) ve "kupa" (yalnız kategori
/// kupaları — rozetlerin bir alt kümesi/özel olarak öne çıkarılan hali).
enum BadgeCatalog {
    static let totalRozet = 11
    static let totalKupa = 2

    enum Category {
        /// "9 rozet + kategori kupası": 7 kıta + Karışık + Bayrak Bilmece Kupası.
        case bayrakTahmin
        /// "2 rozet + kategori kupası": Kıtalar Rozeti, Ülkeler Rozeti + Harita Bilmece Kupası.
        case haritaBilmece
        /// Tek "yakında" placeholder — MVP1 kapsamı dışında, rozet/kupa sayaçlarına dahil değil.
        case anaDiller
    }

    static let rozetCount: [Category: Int] = [
        .bayrakTahmin: 9,
        .haritaBilmece: 2
    ]

    static let categoryTrophyName: [Category: String] = [
        .bayrakTahmin: "Bayrak Bilmece Kupası",
        .haritaBilmece: "Harita Bilmece Kupası"
    ]

    /// Rozet simgesi (emoji) ve kilit açıkken gösterilen daire rengi — Figma'nın
    /// "Design System / Bileşenler / Achievement Badge" bölümündeki "Rozet Simgeleri"
    /// referans paneliyle birebir (bkz. node 536:12128). Kilitliyken aynı emoji
    /// KasifAchievementBadge tarafından gri tonlanıp soluklaştırılır (silhouette preview).
    struct BadgeInfo {
        let title: String
        let icon: String
        let accentColor: Color
        let unlocked: Bool
    }

    /// FlagGuessStructure.continents ile aynı sırada (Avrupa...Antarktika) — bkz.
    /// Rozet Simgeleri referans paneli için seçilen renk/emoji eşleşmesi.
    private static let continentIcons: [(icon: String, color: Color)] = [
        ("🗼", KasifColor.accentPrimary),
        ("🐼", KasifColor.accentSuccess),
        ("🦁", KasifColor.accentHighlight),
        ("🦅", KasifColor.accentTertiary),
        ("🦙", KasifColor.accentPrimarySoft),
        ("🦘", KasifColor.accentDanger),
        ("🐧", KasifColor.accentInfo)
    ]

    /// ContinentCompleteView gibi rozet listesine ihtiyaç duymadan tek bir kıtanın
    /// simgesini/rengini bilmesi gereken yerler için — aynı kaynağı (continentIcons)
    /// kullanır, ayrı bir eşleme tutulmaz.
    static func continentIcon(for continent: String) -> (icon: String, color: Color)? {
        guard let index = FlagGuessStructure.continents.firstIndex(of: continent) else { return nil }
        return continentIcons[index]
    }

    /// Gerçek GameProgress'ten okunan, Kupalar ekranı ve Profil'in rozet önizlemesi
    /// tarafından paylaşılan tek kaynak — ikisi ayrı ayrı sahte/örnek veri tutmasın diye.
    static func bayrakTahminBadges(progress: GameProgress) -> [BadgeInfo] {
        zip(FlagGuessStructure.continents, continentIcons).map { continent, iconInfo in
            BadgeInfo(
                title: continent, icon: iconInfo.icon, accentColor: iconInfo.color,
                unlocked: progress.isContinentCompleted(continent, stageCount: FlagGuessStructure.stagesPerSection)
            )
        } + [
            BadgeInfo(
                title: "Karışık", icon: "🔀", accentColor: KasifColor.textSecondary,
                unlocked: progress.isContinentCompleted("Karışık", stageCount: FlagGuessStructure.stagesPerSection)
            ),
            BadgeInfo(title: "Bayrak Bilmece Kupası", icon: "🏆", accentColor: KasifColor.accentHighlightStrong, unlocked: progress.isFlagGuessCategoryCompleted())
        ]
    }

    static func haritaBilmeceBadges(progress: GameProgress) -> [BadgeInfo] {
        [
            BadgeInfo(title: "Kıtalar Rozeti", icon: "🌍", accentColor: KasifColor.accentInfo, unlocked: progress.isMapPuzzleContinentsCompleted()),
            BadgeInfo(title: "Ülkeler Rozeti", icon: "📍", accentColor: KasifColor.accentInfoStrong, unlocked: progress.isMapPuzzleCountriesCompleted()),
            BadgeInfo(title: "Harita Bilmece Kupası", icon: "🏆", accentColor: KasifColor.accentHighlightStrong, unlocked: progress.isMapPuzzleCategoryCompleted())
        ]
    }

    static func allBadges(progress: GameProgress) -> [BadgeInfo] {
        bayrakTahminBadges(progress: progress) + haritaBilmeceBadges(progress: progress)
    }
}
