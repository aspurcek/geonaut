import Foundation

/// Ana Diller — bkz. GameRules.MainLanguageStructure böl. 01: "Bu ülkenin ana dili
/// nedir?" 4 şıklı soru üretimi. Bayrak Tahmin'in aynı 7 kıta havuzlarını (Countries)
/// ve CountryFacts'teki kıta/dil/zorluk verisini paylaşır — ayrı bir ülke listesi
/// tutulmuyor, tek kaynak Countries + CountryFacts.
struct LanguageQuestion {
    enum Stimulus { case flag, map }
    let stimulus: Stimulus
    let countryCode: String
    let countryName: String
    let correctLanguage: String
    let options: [String] // 4 dil adı, karışık sırada
}

enum Languages {
    /// "Bir kıta havuzunda hiç 'zor' işaretli ülke yoksa standart havuza düş" —
    /// Antarktika'nın 8 ülkesi (hepsi başka kıtalarda zaten standart) bu duruma örnek.
    static func trickyPool(forContinent continent: String) -> [Country] {
        let base = Countries.pool(forContinent: continent)
        let tricky = base.filter { CountryData.facts[$0.code]?.isTrickyLanguage == true }
        return tricky.isEmpty ? base : tricky
    }

    /// Harita uyarımlı sorularda gösterilen ülke — artık `CountryMap-<kod>` PNG'si
    /// olan 17 ülkeyle sınırlı değil: CountryCoordinates'teki gerçek enlem/boylam
    /// verisi sayesinde HERHANGİ bir ülke KasifLiveCountryMap ile canlı gösterilebiliyor
    /// (bkz. LanguageQuestionView.mapCard'daki öncelik sırası: önce PNG varsa o, yoksa
    /// canlı harita).
    private static let mapEligibleCodes: Set<String> = Set(CountryCoordinates.coordinates.keys)

    static func language(for code: String) -> String {
        CountryData.facts[code]?.mainLanguage ?? "Bilinmiyor"
    }

    /// "Ana Dilleri Öğren" için — bkz. LearnLanguagesView. Countries.all'daki doğru
    /// Türkçe isimlerle, yalnızca CountryFacts'te dili bilinen ülkeler.
    static var learnableCountries: [Country] {
        Countries.all.filter { CountryData.facts[$0.code] != nil }
    }

    /// Bir etap için 10 soru üretir — bkz. MainLanguageStructure.style(forStage:):
    /// .standard/.tricky → her zaman bayrak uyarımı; .mixed (etap 7-8) → soru başına
    /// rastgele bayrak ya da harita uyarımı (harita yalnızca görseli olan ülkelerden).
    static func makeQuestions(forContinent continent: String, stageIndex: Int) -> [LanguageQuestion] {
        let style = MainLanguageStructure.style(forStage: stageIndex)
        let fullPool = Countries.pool(forContinent: continent)
        let sourcePool = style == .tricky ? trickyPool(forContinent: continent) : fullPool
        let mapPool = fullPool.filter { mapEligibleCodes.contains($0.code) }
        let distractorSource = fullPool + Countries.mixed

        var result: [LanguageQuestion] = []
        for _ in 0..<GameRules.questionsPerStage {
            let useMap = style == .mixed && !mapPool.isEmpty && Bool.random()
            let effectivePool = useMap ? mapPool : sourcePool
            guard let correct = effectivePool.randomElement() else { continue }
            let correctLanguage = language(for: correct.code)

            var seenLanguages: Set<String> = [correctLanguage]
            var distractors: [String] = []
            for candidate in distractorSource.shuffled() {
                let lang = language(for: candidate.code)
                if seenLanguages.insert(lang).inserted {
                    distractors.append(lang)
                }
                if distractors.count == 3 { break }
            }

            let options = ([correctLanguage] + distractors).shuffled()
            result.append(LanguageQuestion(
                stimulus: useMap ? .map : .flag,
                countryCode: correct.code,
                countryName: correct.name,
                correctLanguage: correctLanguage,
                options: options
            ))
        }
        return result
    }
}
