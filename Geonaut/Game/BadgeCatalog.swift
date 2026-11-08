import SwiftUI

/// Rozetler & Kupalar ekranı (Figma node 355:13868, kullanıcı tarafından 2026-09-10'da
/// tasarım üzerinden doğrulandı — bu dosyadaki sayılar PDF kural kitaplarındaki
/// çelişkili rakamları değil, Figma'nın kendisini esas alır).
///
/// Ekranda iki ayrı sayaç var: "rozet" (tüm kazanımlar) ve "kupa" (yalnız kategori
/// kupaları — rozetlerin bir alt kümesi/özel olarak öne çıkarılan hali).
enum BadgeCatalog {
    /// Kupalar HARİÇ rozet sayısı (7 kıta + Karışık ×2 kategori, Kıtalar/Ülkeler, 3 yemek türü + Karışık)
    /// — elle yazılmış sabit yerine gerçek listeden hesaplanır ki içerik değişince sayı kaymasın.
    static var totalRozet: Int { allBadges(progress: GameProgress()).filter { !isTrophy($0) }.count }
    static let totalKupa = 5

    static func isTrophy(_ badge: BadgeInfo) -> Bool {
        categoryTrophyName.values.contains(badge.title)
    }

    enum Category {
        /// "9 rozet + kategori kupası": 7 kıta + Karışık + Bayrak Bilmece Kupası.
        case bayrakTahmin
        /// "2 rozet + kategori kupası": Kıtalar Rozeti, Ülkeler Rozeti + Harita Bilmece Kupası.
        case haritaBilmece
        /// "9 rozet + kategori kupası": bayrakTahmin ile birebir aynı yapı (7 kıta +
        /// Karışık + Ana Diller Kupası) — bkz. MainLanguageStructure.
        case anaDiller
        /// "5 rozet + kategori kupası": kullanıcı kararıyla kıta yerine TÜR bazlı —
        /// Yemekler + İçecekler + Tatlılar + Karışık + Dünya Yemekleri Kupası —
        /// bkz. WorldFoodStructure.sections.
        case dunyaYemekleri
        /// "8 rozet + kategori kupası": anaDiller ile aynı yapı — bkz. CapitalStructure.
        case baskentler
    }

    /// Kupalar HARİÇ rozet sayısı (kupa her kategoride ayrıca +1) — gerçek listelerle aynı.
    static let rozetCount: [Category: Int] = [
        .bayrakTahmin: 8,
        .haritaBilmece: 2,
        .anaDiller: 8,
        .dunyaYemekleri: 4,
        .baskentler: 8
    ]

    static let categoryTrophyName: [Category: String] = [
        .bayrakTahmin: "Bayrak Ustası",
        .haritaBilmece: "Harita Ustası",
        .anaDiller: "Dil Ustası",
        .dunyaYemekleri: "Lezzet Ustası",
        .baskentler: "Başkent Ustası"
    ]

    /// Rozet simgesi (emoji) ve kilit açıkken gösterilen daire rengi — Figma'nın
    /// "Design System / Bileşenler / Achievement Badge" bölümündeki "Rozet Simgeleri"
    /// referans paneliyle birebir (bkz. node 536:12128). Kilitliyken aynı emoji
    /// GeoAchievementBadge tarafından gri tonlanıp soluklaştırılır (silhouette preview).
    struct BadgeInfo {
        let title: String
        let icon: String
        let accentColor: Color
        let unlocked: Bool
        /// Rozete dokununca açılan bilgi sayfasında gösterilir — bkz. BadgesView'in
        /// bottom sheet'i (kullanıcı kararı: "nasıl kazanılacağını anlatsın").
        let description: String
    }

    /// Rozet zemin renkleri: emoji ile zemin arasında yeterli kontrast olsun diye seçildi
    /// (örn. kırmızı kule turuncu zeminde, altın kupa altın zeminde, kahverengi kanguru
    /// koyu kırmızıda kayboluyordu). Kilitliyken zemin GeoColor.bgLocked olduğundan,
    /// açık rozetlerin zemini bundan ayırt edilebilir kalmalı.
    enum BadgeTint {
        static let peach = Color(hex: 0xFFD3C5)
        static let butter = Color(hex: 0xFBEBA8)
        static let rose = Color(hex: 0xF8CCD8)
        static let apricot = Color(hex: 0xFFE0B8)
        static let ink = Color(hex: 0x2A3045)
    }

    /// FlagGuessStructure.continents ile aynı sırada (Avrupa...Antarktika) — bkz.
    /// Rozet Simgeleri referans paneli için seçilen renk/emoji eşleşmesi.
    private static let continentIcons: [(icon: String, color: Color)] = [
        ("🗼", BadgeTint.peach),
        ("🐼", GeoColor.accentSuccess),
        ("🦁", BadgeTint.butter),
        ("🦅", GeoColor.accentTertiary),
        ("🦙", GeoColor.accentPrimary),
        ("🦘", BadgeTint.rose),
        ("🐧", GeoColor.accentInfo)
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
                unlocked: progress.isContinentCompleted(continent, stageCount: FlagGuessStructure.stagesPerSection),
                description: String(localized: "Bayraklar'da \(L(continent)) bölümünün 8 seviyesini tamamladığında bu rozeti kazanırsın.")
            )
        } + [
            BadgeInfo(
                title: "Karışık", icon: "🔀", accentColor: BadgeTint.apricot,
                unlocked: progress.isContinentCompleted("Karışık", stageCount: FlagGuessStructure.stagesPerSection),
                description: String(localized: "Diğer 7 kıtayı bitirince açılan Karışık bölümünün 8 seviyesini tamamladığında bu rozeti kazanırsın.")
            ),
            BadgeInfo(
                title: "Bayrak Ustası", icon: "🏆", accentColor: BadgeTint.ink,
                unlocked: progress.isCategoryTrophyEarned(.flags),
                description: String(localized: "Bayraklar kategorisinin 3 turunu da (Tur 1, Tur 2, Tur 3) tamamladığında bu kupayı kazanırsın.")
            )
        ]
    }

    static func haritaBilmeceBadges(progress: GameProgress) -> [BadgeInfo] {
        [
            BadgeInfo(
                title: "Kıtalar Rozeti", icon: "🌍", accentColor: GeoColor.accentInfo,
                unlocked: progress.isMapPuzzleContinentsCompleted(),
                description: String(localized: "Haritalar'da Kıtalar bölümünün 8 seviyesini tamamladığında bu rozeti kazanırsın.")
            ),
            BadgeInfo(
                title: "Ülkeler Rozeti", icon: "📍", accentColor: GeoColor.accentSuccess,
                unlocked: progress.isMapPuzzleCountriesCompleted(),
                description: String(localized: "Haritalar'da Ülkeler bölümünün 8 seviyesini tamamladığında bu rozeti kazanırsın.")
            ),
            BadgeInfo(
                title: "Harita Ustası", icon: "🏆", accentColor: BadgeTint.ink,
                unlocked: progress.isCategoryTrophyEarned(.maps),
                description: String(localized: "Haritalar kategorisinin 3 turunu da (Tur 1, Tur 2, Tur 3) tamamladığında bu kupayı kazanırsın.")
            )
        ]
    }

    /// bayrakTahminBadges ile aynı desen — kıta ikon/renkleri paylaşılır (bkz.
    /// continentIcon), yalnızca ilerleme MainLanguageStructure'ın ad-alanlı
    /// anahtarlarından okunur.
    static func anaDillerBadges(progress: GameProgress) -> [BadgeInfo] {
        zip(MainLanguageStructure.continents, continentIcons).map { continent, iconInfo in
            BadgeInfo(
                title: continent, icon: iconInfo.icon, accentColor: iconInfo.color,
                unlocked: progress.isContinentCompleted(MainLanguageStructure.progressKey(for: continent), stageCount: MainLanguageStructure.stagesPerSection),
                description: String(localized: "Diller'de \(L(continent)) bölümünün 8 seviyesini tamamladığında bu rozeti kazanırsın.")
            )
        } + [
            BadgeInfo(
                title: "Karışık", icon: "🔀", accentColor: BadgeTint.apricot,
                unlocked: progress.isContinentCompleted(MainLanguageStructure.progressKey(for: "Karışık"), stageCount: MainLanguageStructure.stagesPerSection),
                description: String(localized: "Diğer 7 kıtayı bitirince açılan Karışık bölümünün 8 seviyesini tamamladığında bu rozeti kazanırsın.")
            ),
            BadgeInfo(
                title: "Dil Ustası", icon: "🏆", accentColor: BadgeTint.ink,
                unlocked: progress.isCategoryTrophyEarned(.languages),
                description: String(localized: "Diller kategorisinin 3 turunu da (Tur 1, Tur 2, Tur 3) tamamladığında bu kupayı kazanırsın.")
            )
        ]
    }

    /// Diğer kategorilerdeki kıta ikonlarının yerine — Dünya Yemekleri TÜR bazlı
    /// ilerlediği için (bkz. WorldFoodStructure.sections) kendi 3 simgesini kullanır.
    private static let foodTypeIcons: [(icon: String, color: Color)] = [
        ("🍽️", GeoColor.accentPrimary),
        ("🥤", GeoColor.accentInfo),
        ("🍰", GeoColor.accentHighlight)
    ]

    /// anaDillerBadges ile aynı desen, ancak kıta yerine yemek TÜRÜ (Yemekler/İçecekler/
    /// Tatlılar) üzerinden — bkz. foodTypeIcons ve WorldFoodStructure.sections.
    static func dunyaYemekleriBadges(progress: GameProgress) -> [BadgeInfo] {
        let foodSections = WorldFoodStructure.sections.filter { $0 != "Karışık" }
        return zip(foodSections, foodTypeIcons).map { section, iconInfo in
            BadgeInfo(
                title: section, icon: iconInfo.icon, accentColor: iconInfo.color,
                unlocked: progress.isContinentCompleted(WorldFoodStructure.progressKey(for: section), stageCount: WorldFoodStructure.stagesPerSection),
                description: String(localized: "Lezzetler'de \(L(section)) bölümünün 8 seviyesini tamamladığında bu rozeti kazanırsın.")
            )
        } + [
            BadgeInfo(
                title: "Karışık", icon: "🔀", accentColor: BadgeTint.apricot,
                unlocked: progress.isContinentCompleted(WorldFoodStructure.progressKey(for: "Karışık"), stageCount: WorldFoodStructure.stagesPerSection),
                description: String(localized: "Diğer 3 bölümü bitirince açılan Karışık bölümünün 8 seviyesini tamamladığında bu rozeti kazanırsın.")
            ),
            BadgeInfo(
                title: "Lezzet Ustası", icon: "🏆", accentColor: BadgeTint.ink,
                unlocked: progress.isCategoryTrophyEarned(.foods),
                description: String(localized: "Lezzetler kategorisinin 3 turunu da (Tur 1, Tur 2, Tur 3) tamamladığında bu kupayı kazanırsın.")
            )
        ]
    }

    /// anaDillerBadges ile aynı desen — CapitalStructure'ın ad-alanlı anahtarlarından okur.
    static func baskentlerBadges(progress: GameProgress) -> [BadgeInfo] {
        zip(CapitalStructure.continents, continentIcons).map { continent, iconInfo in
            BadgeInfo(
                title: continent, icon: iconInfo.icon, accentColor: iconInfo.color,
                unlocked: progress.isContinentCompleted(CapitalStructure.progressKey(for: continent), stageCount: CapitalStructure.stagesPerSection),
                description: String(localized: "Başkentler'de \(L(continent)) bölümünün 8 seviyesini tamamladığında bu rozeti kazanırsın.")
            )
        } + [
            BadgeInfo(
                title: "Karışık", icon: "🔀", accentColor: BadgeTint.apricot,
                unlocked: progress.isContinentCompleted(CapitalStructure.progressKey(for: "Karışık"), stageCount: CapitalStructure.stagesPerSection),
                description: String(localized: "Diğer 7 kıtayı bitirince açılan Karışık bölümünün 8 seviyesini tamamladığında bu rozeti kazanırsın.")
            ),
            BadgeInfo(
                title: "Başkent Ustası", icon: "🏆", accentColor: BadgeTint.ink,
                unlocked: progress.isCategoryTrophyEarned(.capitals),
                description: String(localized: "Başkentler kategorisinin 3 turunu da (Tur 1, Tur 2, Tur 3) tamamladığında bu kupayı kazanırsın.")
            )
        ]
    }

    static func allBadges(progress: GameProgress) -> [BadgeInfo] {
        bayrakTahminBadges(progress: progress) + haritaBilmeceBadges(progress: progress) + anaDillerBadges(progress: progress) + dunyaYemekleriBadges(progress: progress) + baskentlerBadges(progress: progress)
    }
}
