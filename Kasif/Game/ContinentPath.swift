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
    static func flagGuessPath(progress: GameProgress) -> [ContinentPathNode] {
        var activeAssigned = false
        return order.map { entry in
            let isCompleted = progress.isContinentCompleted(entry.name, stageCount: FlagGuessStructure.stagesPerSection)
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
    static func mainLanguagePath(progress: GameProgress) -> [ContinentPathNode] {
        var activeAssigned = false
        return order.map { entry in
            let isCompleted = progress.isContinentCompleted(
                MainLanguageStructure.progressKey(for: entry.name),
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
}
