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
    static func makeQuestions(stageIndex: Int, count: Int = GameRules.questionsPerStage, tour: Int = 0) -> [MapQuizQuestion] {
        // stageIndex 0 tabanlı (Etap 1 = 0); questionTypes(forStage:) Kural Kitabı'ndaki
        // 1 tabanlı etap numaralarını (Etap 1-2, 3, 4, 5, 6-8) bekliyor.
        let types = MapPuzzleStructure.questionTypes(forStage: stageIndex + 1)
        // `MapCountries.all` sabit bir literal ve bugün asla boş değil, ama
        // `Languages.makeQuestions`'daki "havuz boşsa sessizce daha az soru üret"
        // kuralıyla tutarlı olsun diye burada da çökme yerine erken çıkış tercih edildi.
        guard !MapCountries.all.isEmpty else { return [] }
        // Aynı ülke bir etapta tekrar etmesin diye havuzdan çekerek (without
        // replacement) seçiliyor — bkz. Countries.makeQuestions'daki aynı prensip.
        let preferred = TourStructure.preferredCodes(MapCountries.all.map(\.code), tour: tour, stageIndex: stageIndex, size: count)
        var deck = TourStructure.deck(MapCountries.all, code: \.code, preferred: preferred)
        return (0..<count).compactMap { _ -> MapQuizQuestion? in
            let kind = types.randomElement() ?? .highlightMapSelectName
            if deck.isEmpty { deck = TourStructure.deck(MapCountries.all, code: \.code, preferred: preferred) }
            let country = deck.removeFirst()
            guard let correctContinent = country.acceptedContinents.randomElement() else { return nil }

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
