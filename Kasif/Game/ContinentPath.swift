import Foundation

/// Bayrak Tahmin kategorisinin Ana Sayfa'daki kıta yolu — bkz. Bayrak Tahmin Kural
/// Kitabı böl. 02: "8 durak zikzak halinde sıralanır: Avrupa → Asya → Afrika → Kuzey
/// Amerika → Güney Amerika → Okyanusya → Antarktika → Karışık."
struct ContinentPathNode: Identifiable {
    let id = UUID()
    let name: String
    let systemImage: String
    var state: KasifContinentNode.State

    static let order: [(name: String, systemImage: String)] = [
        ("Avrupa", "globe.europe.africa.fill"),
        ("Asya", "globe.asia.australia.fill"),
        ("Afrika", "globe.europe.africa.fill"),
        ("Kuzey Amerika", "globe.americas.fill"),
        ("Güney Amerika", "globe.americas.fill"),
        ("Okyanusya", "globe.asia.australia.fill"),
        ("Antarktika", "snowflake"),
        ("Karışık", "shuffle")
    ]

    /// İlerlemeye göre kilit/tamamlanma durumu hesaplanmış kıta yolu — bkz.
    /// GameProgress ve "bir etap ancak öncekinin bitirilmesiyle açılır" kuralı.
    static func flagGuessPath(progress: GameProgress, tour: Int = 0) -> [ContinentPathNode] {
        var activeAssigned = false
        return order.map { entry in
            let isCompleted = progress.isContinentCompleted(TourStructure.progressKey(entry.name, tour: tour), stageCount: FlagGuessStructure.stagesPerSection)
            let state: KasifContinentNode.State
            if isCompleted {
                state = .completed
            } else if !activeAssigned {
                state = .active
                activeAssigned = true
            } else {
                state = .locked
            }
            return ContinentPathNode(name: entry.name, systemImage: entry.systemImage, state: state)
        }
    }

    static func icon(for continentName: String) -> String {
        order.first { $0.name == continentName }?.systemImage ?? "globe"
    }

    /// Ana Diller'in kıta yolu — flagGuessPath ile birebir aynı mantık, yalnızca
    /// ilerleme MainLanguageStructure'ın ad-alanlı anahtarlarından okunuyor (bkz.
    /// MainLanguageStructure.progressKey — "Avrupa" gibi düz kıta adları Bayrak
    /// Tahmin'in kendi ilerlemesiyle çakışır).
    static func mainLanguagePath(progress: GameProgress, tour: Int = 0) -> [ContinentPathNode] {
        var activeAssigned = false
        return order.map { entry in
            let isCompleted = progress.isContinentCompleted(
                TourStructure.progressKey(MainLanguageStructure.progressKey(for: entry.name), tour: tour),
                stageCount: MainLanguageStructure.stagesPerSection
            )
            let state: KasifContinentNode.State
            if isCompleted {
                state = .completed
            } else if !activeAssigned {
                state = .active
                activeAssigned = true
            } else {
                state = .locked
            }
            return ContinentPathNode(name: entry.name, systemImage: entry.systemImage, state: state)
        }
    }

    /// Dünya Yemekleri'nin bölüm adları/simgeleri — kullanıcı kararıyla kıta yerine
    /// yemek TÜRÜ bazlı: "Yemekler"/"İçecekler"/"Tatlılar" + "Karışık" (bkz.
    /// WorldFoodStructure.sections).
    static let worldFoodsOrder: [(name: String, systemImage: String)] = [
        ("Yemekler", "fork.knife"),
        ("İçecekler", "cup.and.saucer.fill"),
        ("Tatlılar", "birthday.cake.fill"),
        ("Karışık", "shuffle")
    ]

    /// Dünya Yemekleri'nin Ana Sayfa yolu — flagGuessPath/mainLanguagePath ile aynı
    /// sıralı-kilit mantığı, ama 8 kıta yerine worldFoodsOrder'ın 4 türe göre bölümü
    /// üzerinde çalışır; ilerleme WorldFoodStructure'ın ad-alanlı anahtarlarından okunur.
    static func worldFoodsSectionsPath(progress: GameProgress, tour: Int = 0) -> [ContinentPathNode] {
        var activeAssigned = false
        return worldFoodsOrder.map { entry in
            let isCompleted = progress.isContinentCompleted(
                TourStructure.progressKey(WorldFoodStructure.progressKey(for: entry.name), tour: tour),
                stageCount: WorldFoodStructure.stagesPerSection
            )
            let state: KasifContinentNode.State
            if isCompleted {
                state = .completed
            } else if !activeAssigned {
                state = .active
                activeAssigned = true
            } else {
                state = .locked
            }
            return ContinentPathNode(name: entry.name, systemImage: entry.systemImage, state: state)
        }
    }

    /// Harita Bilmece'nin Ana Sayfa yolu — Figma "Anasayfa-Harita Bilmece" (node
    /// 344:55284) referans alındığında diğer 3 kategori gibi 8 kıtalık bir yol DEĞİL,
    /// yalnızca 2 durak: "Kıtalar" ve "Ülkeler" (MapPuzzleStructure/CountryPuzzleStructure'ın
    /// kendi ayrı 8 etaplık havuzları). Kullanıcı kararı: Ülkeler, Kıtalar bitmeden kilitli
    /// — "bir sonraki ancak bir öncekiyle açılır" kuralı burada 8 kıta yerine bu 2 durağa uygulanıyor.
    static func mapPuzzleTracksPath(progress: GameProgress, tour: Int = 0) -> [ContinentPathNode] {
        let kıtalarDone = progress.isContinentCompleted(TourStructure.progressKey(MapPuzzleStructure.progressKey, tour: tour), stageCount: MapPuzzleStructure.stageCount)
        let ülkelerDone = progress.isContinentCompleted(TourStructure.progressKey(CountryPuzzleStructure.progressKey, tour: tour), stageCount: CountryPuzzleStructure.stageCount)
        return [
            ContinentPathNode(name: "Kıtalar", systemImage: "globe", state: kıtalarDone ? .completed : .active),
            ContinentPathNode(name: "Ülkeler", systemImage: "globe", state: ülkelerDone ? .completed : (kıtalarDone ? .active : .locked))
        ]
    }
}
