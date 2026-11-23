import UIKit

/// Dünya Yemekleri — bkz. GameRules.WorldFoodStructure. Diğer kategorilerden farklı
/// olarak kıta bazlı değil TÜR bazlı ilerler: "Yemekler"/"İçecekler"/"Tatlılar" bölümleri
/// hep o türden soru sorar, "Karışık" bölümünde tür de soru başına rastgele. Soru STİLİ
/// etaba göre sabit (bkz. WorldFoodStructure.style(forStage:)) — etap 7-8'de stil de
/// rastgele. Yalnızca kullanıcının Figma'da gerçek fotoğraf eklediği 30 ülkeden (bkz.
/// imageCoveredCodes) soru üretilir; hem doğru cevap hem de YANLIŞ şıklar bu 30'luk
/// havuzdan seçilir (kullanıcı kararı: "sadece Figma'da gönderdiğim o kısımdan").
struct FoodQuestion {
    /// Bkz. WorldFoodStructure etap notu:
    /// - foodImageToCountry: görsel + isim birlikte gösterilir → ülke adı şıkları (etap 1-4).
    /// - foodNameToCountryFlags: isim verilir → 4 ülke BAYRAĞI şık (etap 5).
    /// - foodNameToCountryText: isim verilir → düz metin ülke adı şıkları (etap 6).
    /// - countryToFood: ülke (bayrak/harita) verilir → yemek/tatlı/içecek adı şıkları
    ///   (yalnızca etap 7-8 "Karışık"ta karışıma dahil).
    enum Style: CaseIterable { case foodImageToCountry, foodNameToCountryFlags, foodNameToCountryText, countryToFood }
    enum CountryStimulus { case flag, map } // yalnızca .countryToFood için anlamlı

    let style: Style
    var countryStimulus: CountryStimulus = .flag
    let foodType: FoodType
    let countryCode: String
    let countryName: String
    let foodItem: String
    /// Yalnızca .foodImageToCountry için — bu stili üreten havuz zaten görseli olanlarla
    /// sınırlı olduğundan garanti dolu (bkz. WorldFoods.makeFoodImageToCountryQuestion).
    var foodImage: String? = nil
    var options: [String] = [] // foodImageToCountry/foodNameToCountryText: 4 ülke adı. countryToFood: 4 yemek/tatlı/içecek adı
    var flagOptions: [String] = [] // yalnızca foodNameToCountryFlags: 4 ülke kodu
    /// Yazılı soru ("Karışık" bölümü, yalnızca ülke soran stillerde): oyuncu ülke adını yazar (bkz. TypedAnswer).
    var typed = false

    var correctAnswer: String {
        switch style {
        case .foodImageToCountry, .foodNameToCountryText: countryName
        case .foodNameToCountryFlags: countryCode
        case .countryToFood: foodItem
        }
    }
}

enum WorldFoods {
    /// FoodData'da gerçek verisi olan ülkeler — bkz. LearnFoodsView. "Öğren" listesi
    /// bunun tamamını (66 ülke) metin olarak gösterir.
    static var learnableCountries: [Country] {
        Countries.all.filter { FoodData.facts[$0.code] != nil }
    }

    /// Kullanıcının Figma'da gerçek fotoğraf ekleyeceği 30 ülke — bkz. FoodFacts.dishImage
    /// notu. SORULAR (doğru cevap VE yanlış şıklar) yalnızca bu kümeden çıkıyor; diğer
    /// 36 ülke yalnızca Öğren'de kalıyor.
    static let imageCoveredCodes: Set<String> = [
        "TR", "IT", "FR", "DE", "ES", "GR",
        "JP", "CN", "IN", "TH", "KR", "VN",
        "EG", "MA", "ET", "NG", "ZA",
        "US", "MX", "CA", "CU", "JM",
        "BR", "AR", "PE", "CL", "CO",
        "AU", "NZ", "FJ"
    ]

    static var imageCoveredCountries: [Country] {
        learnableCountries.filter { imageCoveredCodes.contains($0.code) }
    }

    static func item(for code: String, type: FoodType) -> String? {
        FoodData.facts[code]?.item(for: type)
    }

    /// Görsel uyarım için — bkz. FoodQuestionView. Yemek/tatlı/içecek türüne göre doğru
    /// fotoğrafı döner (bkz. FoodFacts.image(for:)) — ama yalnızca Assets.xcassets'te
    /// GERÇEKTEN bir dosya varsa (bkz. LanguageQuestionView.mapCard'daki aynı
    /// UIImage(named:) deseni). FoodData'daki isim alanları kullanıcının Figma'da
    /// doldurmayı PLANLADIĞI 30 ülke × 3 tür için önceden yazılmış — ama Figma'daki
    /// kutu boş olduğu sürece Xcode'daki karşılık gelen imageset de boş bir yer
    /// tutucu (bkz. Assets.xcassets), isim dolu görünse de. Bunu kontrol etmeden
    /// Image(name) çağırmak boş/kırık bir görsel render ederdi (bkz. kullanıcı
    /// geri bildirimi "hala boş").
    static func image(for code: String, type: FoodType) -> String? {
        guard let name = FoodData.facts[code]?.image(for: type), UIImage(named: name) != nil else { return nil }
        return name
    }

    /// Bir etap için 10 soru üretir — bkz. WorldFoodStructure.foodType(for:) (bölüme göre
    /// sabit tür, "Karışık" için nil = soru başına rastgele) ve style(forStage:) (etaba
    /// göre sabit stil, etap 7-8 için nil = soru başına rastgele).
    static func makeQuestions(forSection section: String, stageIndex: Int, tour: Int = 0, typedCount: Int = 0) -> [FoodQuestion] {
        let pool = imageCoveredCountries
        guard !pool.isEmpty else { return [] }
        let mapPool = pool.filter { CountryCoordinates.coordinate(for: $0.code) != nil }
        let preferred = TourStructure.preferredCodes(pool.map(\.code), tour: tour, stageIndex: stageIndex)
        let fixedType = WorldFoodStructure.foodType(for: section)
        let fixedStyle = WorldFoodStructure.style(forStage: stageIndex)
        // Şu an Figma'da yalnızca TR'nin gerçek görseli var (bkz. image(for:type:)) —
        // bu küme olmadan görsel-tabanlı HER soru aynı ülkeyi (Kebap) seçip 10 soru
        // boyunca tekrar ederdi (bkz. kullanıcı geri bildirimi "sadece kebap sorusu
        // çıkıyor"). Bir ülkenin görseli bir etapta BİR KEZ kullanılınca dışlanır;
        // başka aday kalmayınca aynı ülkeyi tekrar göstermek yerine etap 6'nın
        // "isim → düz metin" stiline düşülür.
        var usedCodes: Set<String> = []

        var result: [FoodQuestion] = []
        for _ in 0..<GameRules.questionsPerStage {
            let type = fixedType ?? FoodType.allCases.randomElement() ?? .yemek
            let style = fixedStyle ?? FoodQuestion.Style.allCases.randomElement() ?? .foodImageToCountry

            let question: FoodQuestion?
            switch style {
            case .foodImageToCountry:
                if let imageQuestion = makeFoodImageToCountryQuestion(type: type, pool: pool, excluding: usedCodes, preferred: preferred) {
                    question = imageQuestion
                } else {
                    // Bu TÜRDE (henüz) kullanılmamış hiç görsel yok — boş bir soru
                    // dizisi (ve FoodQuizSession'da çökme) ya da tekrar eden aynı
                    // ülke yerine metin sorusuna düşülür.
                    question = makeFoodNameToCountryTextQuestion(type: type, pool: pool, excluding: usedCodes, preferred: preferred)
                }
            case .foodNameToCountryFlags: question = makeFoodNameToCountryFlagsQuestion(type: type, pool: pool, excluding: usedCodes, preferred: preferred)
            case .foodNameToCountryText: question = makeFoodNameToCountryTextQuestion(type: type, pool: pool, excluding: usedCodes, preferred: preferred)
            case .countryToFood: question = makeCountryToFoodQuestion(type: type, pool: pool, mapPool: mapPool, excluding: usedCodes, preferred: preferred)
            }
            if let question {
                result.append(question)
                // Kullanıcı kuralı: aynı ülke bir testte (hangi soru stilinde olursa olsun) tekrar etmesin.
                usedCodes.insert(question.countryCode)
            }
        }
        // Yazılı sorular: yalnızca ülkeyi ad olarak soran stillerde (görsel + ad ya da yalnızca ad → ülke).
        let typeable = Set(Countries.uniqueByCode(Countries.all).filter(TypedAnswer.isTypeable).map(\.code))
        for i in TypedAnswer.pickIndices(questionCount: result.count, typedCount: typedCount, eligible: {
            [.foodImageToCountry, .foodNameToCountryText, .foodNameToCountryFlags].contains(result[$0].style) && typeable.contains(result[$0].countryCode)
        }) {
            result[i].typed = true
        }
        return result
    }

    /// Bu testte henüz sorulmamış ülkelerden (varsa turun penceresindekilerden) seçer; hepsi
    /// tükenmişse (olmamalı: havuz 30 ülke, test 10 soru) tüm adaylara düşer.
    private static func pickFresh(_ candidates: [Country], excluding used: Set<String>, preferred: Set<String>) -> Country? {
        let fresh = candidates.filter { !used.contains($0.code) }
        return TourStructure.pick(fresh.isEmpty ? candidates : fresh, code: \.code, preferred: preferred)
    }

    /// Yanlış şık olarak, doğru ülkeyle AYNI yemek/içecek/tatlı adına sahip bir ülke seçilmez
    /// (ör. "Kahve" Kanada, Brezilya ve Avustralya için ortak — aksi hâlde "Kahve hangi ülkeye
    /// ait?" sorusunda birden çok doğru şık çıkardı).
    private static func sharesItem(_ candidate: Country, with item: String, type: FoodType) -> Bool {
        WorldFoods.item(for: candidate.code, type: type) == item
    }

    private static func distractorCountryNames(excluding correct: Country, pool: [Country], count: Int, type: FoodType, correctItem: String) -> [String]? {
        var seenNames: Set<String> = [correct.name]
        var distractors: [String] = []
        for candidate in pool.shuffled() {
            guard candidate.code != correct.code, !sharesItem(candidate, with: correctItem, type: type),
                  seenNames.insert(candidate.name).inserted else { continue }
            distractors.append(candidate.name)
            if distractors.count == count { break }
        }
        return distractors.count == count ? distractors : nil
    }

    private static func distractorCountryCodes(excluding correct: Country, pool: [Country], count: Int, type: FoodType, correctItem: String) -> [String]? {
        var seenCodes: Set<String> = [correct.code]
        var distractors: [String] = []
        for candidate in pool.shuffled() {
            guard !sharesItem(candidate, with: correctItem, type: type),
                  seenCodes.insert(candidate.code).inserted else { continue }
            distractors.append(candidate.code)
            if distractors.count == count { break }
        }
        return distractors.count == count ? distractors : nil
    }

    private static func distractorFoodItems(type: FoodType, excludingItem correctItem: String, excludingCode correctCode: String, pool: [Country], count: Int) -> [String]? {
        var seenItems: Set<String> = [correctItem]
        var distractors: [String] = []
        for candidate in pool.shuffled() {
            guard candidate.code != correctCode, let candidateItem = item(for: candidate.code, type: type) else { continue }
            if seenItems.insert(candidateItem).inserted { distractors.append(candidateItem) }
            if distractors.count == count { break }
        }
        return distractors.count == count ? distractors : nil
    }

    /// Etap 1-4: görsel + isim birlikte gösterilir — bu yüzden havuz o TÜRDE görseli
    /// olanlarla (ve bu etapta henüz kullanılmamışlarla) sınırlanır (30'un hepsinde
    /// her 3 tür de dolu olmayabilir, bkz. makeQuestions'daki usedCodes notu).
    private static func makeFoodImageToCountryQuestion(type: FoodType, pool: [Country], excluding usedCodes: Set<String>, preferred: Set<String>) -> FoodQuestion? {
        let imagePool = pool.filter { !usedCodes.contains($0.code) && image(for: $0.code, type: type) != nil }
        guard let correct = TourStructure.pick(imagePool, code: \.code, preferred: preferred),
              let correctItem = item(for: correct.code, type: type),
              let correctImage = image(for: correct.code, type: type),
              let distractors = distractorCountryNames(excluding: correct, pool: pool, count: 3, type: type, correctItem: correctItem) else { return nil }
        let options = ([correct.name] + distractors).shuffled()
        return FoodQuestion(
            style: .foodImageToCountry, foodType: type,
            countryCode: correct.code, countryName: correct.name, foodItem: correctItem,
            foodImage: correctImage, options: options
        )
    }

    /// Etap 5: isim verilir, şıklar 4 ülke bayrağı.
    private static func makeFoodNameToCountryFlagsQuestion(type: FoodType, pool: [Country], excluding used: Set<String>, preferred: Set<String>) -> FoodQuestion? {
        guard let correct = pickFresh(pool, excluding: used, preferred: preferred),
              let correctItem = item(for: correct.code, type: type),
              let distractorCodes = distractorCountryCodes(excluding: correct, pool: pool, count: 3, type: type, correctItem: correctItem) else { return nil }
        let flagOptions = ([correct.code] + distractorCodes).shuffled()
        return FoodQuestion(
            style: .foodNameToCountryFlags, foodType: type,
            countryCode: correct.code, countryName: correct.name, foodItem: correctItem,
            flagOptions: flagOptions
        )
    }

    /// Etap 6: isim verilir, şıklar düz metin ülke adı.
    private static func makeFoodNameToCountryTextQuestion(type: FoodType, pool: [Country], excluding used: Set<String>, preferred: Set<String>) -> FoodQuestion? {
        guard let correct = pickFresh(pool, excluding: used, preferred: preferred),
              let correctItem = item(for: correct.code, type: type),
              let distractors = distractorCountryNames(excluding: correct, pool: pool, count: 3, type: type, correctItem: correctItem) else { return nil }
        let options = ([correct.name] + distractors).shuffled()
        return FoodQuestion(
            style: .foodNameToCountryText, foodType: type,
            countryCode: correct.code, countryName: correct.name, foodItem: correctItem,
            options: options
        )
    }

    /// Yalnızca etap 7-8 "Karışık"ın karışımına dahil — ülke (bayrak/harita) verilir,
    /// yemek/tatlı/içecek adı sorulur.
    private static func makeCountryToFoodQuestion(type: FoodType, pool: [Country], mapPool: [Country], excluding used: Set<String>, preferred: Set<String>) -> FoodQuestion? {
        let useMap = !mapPool.isEmpty && Bool.random()
        let effectivePool = useMap ? mapPool : pool
        guard let correct = pickFresh(effectivePool, excluding: used, preferred: preferred),
              let correctItem = item(for: correct.code, type: type),
              let distractors = distractorFoodItems(type: type, excludingItem: correctItem, excludingCode: correct.code, pool: pool, count: 3) else { return nil }
        let options = ([correctItem] + distractors).shuffled()
        return FoodQuestion(
            style: .countryToFood, countryStimulus: useMap ? .map : .flag, foodType: type,
            countryCode: correct.code, countryName: correct.name, foodItem: correctItem,
            options: options
        )
    }
}
