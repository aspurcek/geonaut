import Foundation

/// Harita Bilmece "Ülkeler" sorusu — bkz. GameRules.CountryPuzzleStructure ve Figma
/// node 339:15087 (Tip A: "Bu ülke hangisi?") / 339:15386 (Tip B: "Bu bayrak hangi ülkeye ait?").
struct CountryQuizQuestion {
    let kind: CountryPuzzleStructure.QuestionType
    let country: MapCountry
    /// Tip A/B için 4 ülke şıkkı (doğru + 3 dağıtıcı, karışık sırada).
    let options: [MapCountry]
}

enum CountryQuizGenerator {
    static func makeQuestions(stageIndex: Int, count: Int = GameRules.questionsPerStage, tour: Int = 0) -> [CountryQuizQuestion] {
        // stageIndex 0 tabanlı (Etap 1 = 0); questionTypes(forStage:) 1 tabanlı bekliyor.
        let types = CountryPuzzleStructure.questionTypes(forStage: stageIndex + 1)
        // `.extended` (249 ülke) kullanılıyor, `.all` (17, Tip C'nin hassas dokunma
        // kutusuna ihtiyaç duyduğu havuz) değil — bkz. MapCountries.extended'daki not.
        guard !MapCountries.extended.isEmpty else { return [] }
        // Aynı ülke bir etapta tekrar etmesin diye havuzdan çekerek (without
        // replacement) seçiliyor — bkz. Countries.makeQuestions'daki aynı prensip.
        let preferred = TourStructure.preferredCodes(MapCountries.extended.map(\.code), tour: tour, stageIndex: stageIndex, size: count)
        var deck = TourStructure.deck(MapCountries.extended, code: \.code, preferred: preferred)
        return (0..<count).compactMap { _ -> CountryQuizQuestion? in
            let kind = types.randomElement() ?? .highlightMapSelectName
            if deck.isEmpty { deck = TourStructure.deck(MapCountries.extended, code: \.code, preferred: preferred) }
            let country = deck.removeFirst()
            let distractors = MapCountries.extended
                .filter { $0.code != country.code }
                .shuffled()
                .prefix(3)
            let options = ([country] + distractors).shuffled()
            return CountryQuizQuestion(kind: kind, country: country, options: options)
        }
    }
}
