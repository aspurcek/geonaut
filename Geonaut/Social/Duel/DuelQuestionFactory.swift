import Foundation

/// Düello sorularını üretir: iki oyuncunun da Tur 1'ini bitirdiği kategorilerden, türleri
/// karışık 10 soru. Hiç ortak kategori yoksa herkesin açık olan temel havuz (Bayraklar · Avrupa).
/// Sorular bir kez (davet edilen oyuncunun cihazında) üretilip maç verisine yazılır; iki taraf da
/// aynı soruları aynı sırayla görür.
enum DuelQuestionFactory {
    static func makeQuestions(sharedCategories: [String], seed: UInt64 = UInt64.random(in: 0...UInt64.max)) -> [DuelQuestion] {
        var rng = SeededRandom(seed: seed)
        let categories = sharedCategories.compactMap(TourCategory.init(duelKey:))
        guard !categories.isEmpty else { return fallback(&rng) }

        var questions: [DuelQuestion] = []
        var usedCodes: Set<String> = []
        var attempts = 0
        while questions.count < DuelRules.questionCount && attempts < 200 {
            attempts += 1
            let category = categories[questions.count % categories.count]
            if let q = makeQuestion(for: category, excluding: usedCodes, rng: &rng) {
                questions.append(q)
                usedCodes.insert(q.code)
            }
        }
        if questions.count < DuelRules.questionCount {
            questions += fallback(&rng).filter { !usedCodes.contains($0.code) }.prefix(DuelRules.questionCount - questions.count)
        }
        return questions.shuffled(using: &rng)
    }

    /// Başlangıç havuzu: Bayraklar · Avrupa.
    static func fallback(_ rng: inout SeededRandom) -> [DuelQuestion] {
        let pool = Countries.uniqueByCode(Countries.pool(forContinent: "Avrupa"))
        var result: [DuelQuestion] = []
        for country in pool.shuffled(using: &rng).prefix(DuelRules.questionCount) {
            if let q = flagQuestion(country, pool: pool, rng: &rng) { result.append(q) }
        }
        return result
    }

    // MARK: Türler

    private static func makeQuestion(for category: TourCategory, excluding used: Set<String>, rng: inout SeededRandom) -> DuelQuestion? {
        switch category {
        case .flags:
            let pool = Countries.uniqueByCode(Countries.all).filter { CountryData.facts(for: $0.code) != nil }
            guard let c = pool.filter({ !used.contains($0.code) }).randomElement(using: &rng) else { return nil }
            return flagQuestion(c, pool: pool, rng: &rng)
        case .capitals:
            let pool = Capitals.learnableCountries
            guard let c = pool.filter({ !used.contains($0.code) }).randomElement(using: &rng) else { return nil }
            let others = pool.filter { $0.code != c.code && Capitals.name(for: $0.code) != Capitals.name(for: c.code) }
            return question(.capital, code: c.code, answer: c.code, distractors: sameContinentFirst(others.map(\.code), near: c.code, rng: &rng))
        case .languages:
            let pool = Languages.learnableCountries
            guard let c = pool.filter({ !used.contains($0.code) }).randomElement(using: &rng) else { return nil }
            let answer = Languages.language(for: c.code)
            let others = Array(Set(pool.map { Languages.language(for: $0.code) }).subtracting([answer, "Bilinmiyor"])).sorted()
            return question(.language, code: c.code, answer: answer, distractors: Array(others.shuffled(using: &rng).prefix(3)))
        case .foods:
            let pool = WorldFoods.learnableCountries.filter { WorldFoods.item(for: $0.code, type: .yemek) != nil }
            guard let c = pool.filter({ !used.contains($0.code) }).randomElement(using: &rng) else { return nil }
            let dish = WorldFoods.item(for: c.code, type: .yemek)
            let others = pool.filter { $0.code != c.code && WorldFoods.item(for: $0.code, type: .yemek) != dish }
            return question(.food, code: c.code, answer: c.code, distractors: sameContinentFirst(others.map(\.code), near: c.code, rng: &rng))
        case .maps:
            let pool = Countries.uniqueByCode(Countries.all).filter {
                guard let continent = CountryData.facts(for: $0.code)?.continent else { return false }
                return continent != "Antarktika"
            }
            guard let c = pool.filter({ !used.contains($0.code) }).randomElement(using: &rng),
                  let answer = CountryData.facts(for: c.code)?.continent else { return nil }
            let continents = ["Avrupa", "Asya", "Afrika", "Kuzey Amerika", "Güney Amerika", "Okyanusya"].filter { $0 != answer }
            return question(.continent, code: c.code, answer: answer, distractors: Array(continents.shuffled(using: &rng).prefix(3)))
        }
    }

    private static func flagQuestion(_ c: Country, pool: [Country], rng: inout SeededRandom) -> DuelQuestion? {
        let others = pool.filter { $0.code != c.code }.map(\.code)
        return question(.flag, code: c.code, answer: c.code, distractors: sameContinentFirst(others, near: c.code, rng: &rng))
    }

    private static func question(_ kind: DuelQuestion.Kind, code: String, answer: String, distractors: [String]) -> DuelQuestion? {
        let picked = Array(distractors.prefix(3))
        guard picked.count == 3 else { return nil }
        var options = picked + [answer]
        options.sort() // sıralı tut; ekranda karıştırma kodun deterministik olması için aşağıda
        return DuelQuestion(kind: kind, code: code, options: rotate(options, by: code), answer: answer)
    }

    /// Seçenek sırasını ülke koduna göre sabit biçimde kaydır (iki cihaz aynı sırayı görür).
    private static func rotate(_ options: [String], by code: String) -> [String] {
        let shift = code.unicodeScalars.reduce(0) { $0 + Int($1.value) } % options.count
        return Array(options[shift...] + options[..<shift])
    }

    /// Önce aynı kıtadan çeldirici (daha anlamlı), yetmezse diğerlerinden.
    private static func sameContinentFirst(_ codes: [String], near code: String, rng: inout SeededRandom) -> [String] {
        let continent = CountryData.facts(for: code)?.continent
        let same = codes.filter { CountryData.facts(for: $0)?.continent == continent }.shuffled(using: &rng)
        let rest = codes.filter { CountryData.facts(for: $0)?.continent != continent }.shuffled(using: &rng)
        return Array((same.prefix(3) + rest).prefix(3))
    }
}

/// Basit, tohumlu rastgele sayı üreteci (SplitMix64).
struct SeededRandom: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

// MARK: - Ekranda gösterim

extension DuelQuestion {
    var prompt: String {
        switch kind {
        case .flag: "Bu bayrak hangi ülkenin?"
        case .capital: "Bu ülkenin başkenti neresi?"
        case .language: "Bu ülkede hangi dil konuşulur?"
        case .food: "Bu yemek hangi ülkenin?"
        case .continent: "Bu ülke hangi kıtada?"
        }
    }

    /// Bir seçeneğin ekranda görünen adı (cihazın diline göre).
    func label(for option: String) -> String {
        switch kind {
        case .flag, .food: Countries.all.first { $0.code == option }?.name ?? option
        case .capital: D(Capitals.name(for: option))
        case .language, .continent: D(option)
        }
    }

    var countryName: String { Countries.all.first { $0.code == code }?.name ?? code }
}
