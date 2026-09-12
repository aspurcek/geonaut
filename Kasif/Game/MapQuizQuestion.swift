import Foundation

/// Harita Bilmece "Kıtalar" sorusu — bkz. Harita Bilmece Kural Kitabı böl. 04-05.
struct MapQuizQuestion {
    let kind: MapPuzzleStructure.QuestionType
    let country: MapCountry
    /// Bu soru örneğinde "doğru" sayılan tek kıta — kıtalar arası ülkelerde
    /// (Rusya, Türkiye) acceptedContinents'ten rastgele seçilir.
    let correctContinent: String
    /// Tip A/B için 4 kıta adı şıkkı (doğru + 3 dağıtıcı, karışık sırada).
    /// Tip C'de kullanılmaz (harita üzerinden dokunarak cevaplanır).
    let continentOptions: [String]

    /// Kıta adı → Assets.xcassets'teki "ContinentMap-<key>" anahtarı.
    static func mapAssetKey(for continent: String) -> String {
        switch continent {
        case "Avrupa": "avrupa"
        case "Asya": "asya"
        case "Afrika": "afrika"
        case "Kuzey Amerika": "kuzeyamerika"
        case "Güney Amerika": "guneyamerika"
        case "Okyanusya": "okyanusya"
        default: "antarktika"
        }
    }
}

enum MapQuizGenerator {
    static func makeQuestions(stageIndex: Int, count: Int = GameRules.questionsPerStage) -> [MapQuizQuestion] {
        // stageIndex 0 tabanlı (Etap 1 = 0); questionTypes(forStage:) Kural Kitabı'ndaki
        // 1 tabanlı etap numaralarını (Etap 1-2, 3, 4, 5, 6-8) bekliyor.
        let types = MapPuzzleStructure.questionTypes(forStage: stageIndex + 1)
        return (0..<count).map { _ in
            let kind = types.randomElement() ?? .highlightMapSelectName
            let country = MapCountries.all.randomElement()!
            let correctContinent = country.acceptedContinents.randomElement()!

            var options: [String] = []
            if kind != .flagTapMap {
                let distractors = FlagGuessStructure.continents
                    .filter { !country.acceptedContinents.contains($0) }
                    .shuffled()
                    .prefix(3)
                options = ([correctContinent] + distractors).shuffled()
            }
            return MapQuizQuestion(kind: kind, country: country, correctContinent: correctContinent, continentOptions: options)
        }
    }
}
