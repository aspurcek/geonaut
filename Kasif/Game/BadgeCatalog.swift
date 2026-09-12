import Foundation

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

    struct BadgeInfo {
        let title: String
        let systemImage: String
        let unlocked: Bool
    }

    /// Gerçek GameProgress'ten okunan, Kupalar ekranı ve Profil'in rozet önizlemesi
    /// tarafından paylaşılan tek kaynak — ikisi ayrı ayrı sahte/örnek veri tutmasın diye.
    static func bayrakTahminBadges(progress: GameProgress) -> [BadgeInfo] {
        FlagGuessStructure.continents.map { continent in
            BadgeInfo(
                title: continent, systemImage: "globe.europe.africa.fill",
                unlocked: progress.isContinentCompleted(continent, stageCount: FlagGuessStructure.stagesPerSection)
            )
        } + [
            BadgeInfo(
                title: "Karışık", systemImage: "shuffle",
                unlocked: progress.isContinentCompleted("Karışık", stageCount: FlagGuessStructure.stagesPerSection)
            ),
            BadgeInfo(title: "Bayrak Bilmece Kupası", systemImage: "trophy.fill", unlocked: progress.isFlagGuessCategoryCompleted())
        ]
    }

    static func haritaBilmeceBadges(progress: GameProgress) -> [BadgeInfo] {
        [
            BadgeInfo(title: "Kıtalar Rozeti", systemImage: "globe.europe.africa.fill", unlocked: progress.isMapPuzzleContinentsCompleted()),
            BadgeInfo(title: "Ülkeler Rozeti", systemImage: "map.fill", unlocked: progress.isMapPuzzleCountriesCompleted()),
            BadgeInfo(title: "Harita Bilmece Kupası", systemImage: "trophy.fill", unlocked: progress.isMapPuzzleCategoryCompleted())
        ]
    }

    static func allBadges(progress: GameProgress) -> [BadgeInfo] {
        bayrakTahminBadges(progress: progress) + haritaBilmeceBadges(progress: progress)
    }
}
