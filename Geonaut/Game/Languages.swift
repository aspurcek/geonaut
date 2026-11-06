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
    /// verisi sayesinde HERHANGİ bir ülke GeoLiveCountryMap ile canlı gösterilebiliyor
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
    static func makeQuestions(forContinent continent: String, stageIndex: Int, tour: Int = 0) -> [LanguageQuestion] {
        let style = MainLanguageStructure.style(forStage: stageIndex)
        let fullPool = Countries.pool(forContinent: continent)
        let sourcePool = style == .tricky ? trickyPool(forContinent: continent) : fullPool
        let mapPool = fullPool.filter { mapEligibleCodes.contains($0.code) }
        let distractorSource = fullPool + Countries.mixed
        let preferred = TourStructure.preferredCodes(fullPool.map(\.code), tour: tour, stageIndex: stageIndex)
        let everyCountry = Countries.uniqueByCode(Countries.all)

        // Aynı ülke bir etapta tekrar etmesin diye önce henüz sorulmamışlardan
        // seçiliyor — havuz küçükse (ör. "zor" havuzu) ve tükenirse tekrara
        // düşülüyor (bkz. Countries.makeQuestions/WorldFoods'taki aynı prensip).
        var usedCodes: Set<String> = []
        var result: [LanguageQuestion] = []
        for _ in 0..<GameRules.questionsPerStage {
            let useMap = style == .mixed && !mapPool.isEmpty && Bool.random()
            let effectivePool = useMap ? mapPool : sourcePool
            // Aynı ülke bir etapta tekrar etmesin: önce havuzdan, tükenirse kıtanın tamamından,
            // o da tükenirse (küçük havuz) tüm ülkelerden seçilir — harita sorusunda yalnızca
            // haritası gösterilebilen ülkeler.
            var chosen: Country?
            for candidatePool in [effectivePool, fullPool, everyCountry] {
                let eligible = candidatePool.filter { !usedCodes.contains($0.code) && (!useMap || mapEligibleCodes.contains($0.code)) }
                if let pick = TourStructure.pick(eligible, code: \.code, preferred: preferred) { chosen = pick; break }
            }
            guard let correct = chosen ?? effectivePool.randomElement() else { continue }
            usedCodes.insert(correct.code)
            let correctLanguage = language(for: correct.code)

            // Şıklar GÖSTERİLEN (yerelleştirilmiş) ada göre tekilleştirilir: Türkçe'de farklı olan
            // Flamanca/Hollandaca, Rumca/Yunanca, Sırpça/Karadağca İngilizce/Almanca/İspanyolca'da
            // aynı kelimeye dönüşüyor — iki aynı şıktan biri "yanlış" sayılırdı.
            var seenLanguages: Set<String> = [D(correctLanguage)]
            var distractors: [String] = []
            for candidate in distractorSource.shuffled() {
                let lang = language(for: candidate.code)
                if seenLanguages.insert(D(lang)).inserted {
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
