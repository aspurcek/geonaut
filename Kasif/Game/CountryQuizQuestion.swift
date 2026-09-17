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
    static func makeQuestions(stageIndex: Int, count: Int = GameRules.questionsPerStage) -> [CountryQuizQuestion] {
        // stageIndex 0 tabanlı (Etap 1 = 0); questionTypes(forStage:) 1 tabanlı bekliyor.
        let types = CountryPuzzleStructure.questionTypes(forStage: stageIndex + 1)
        guard !MapCountries.all.isEmpty else { return [] }
        return (0..<count).compactMap { _ -> CountryQuizQuestion? in
            let kind = types.randomElement() ?? .highlightMapSelectName
            guard let country = MapCountries.all.randomElement() else { return nil }
            let distractors = MapCountries.all
                .filter { $0.code != country.code }
                .shuffled()
                .prefix(3)
            let options = ([country] + distractors).shuffled()
            return CountryQuizQuestion(kind: kind, country: country, options: options)
        }
    }
}
