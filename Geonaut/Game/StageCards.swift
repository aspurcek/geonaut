import Foundation

/// Etap başında gösterilen bilgi kartı — bir ülkenin (bayrak / başkent / dil / yemek) kısa tanıtımı.
/// Amaç: oyuncu bir etaba hazırlıksız girip üst üste hata yapıp vazgeçmesin; o etapta sorulacak
/// ülkeleri önce görsün (bkz. StageCardsView).
struct InfoCard: Identifiable, Equatable {
    enum Content: Equatable {
        case flag(caption: String?)
        case capital(String)
        case language(String)
        case food(item: String, image: String?)
    }

    var id: String { code }
    let code: String
    let countryName: String
    let content: Content
}

/// Hangi ülkeler için kart gösterileceğini hesaplar.
///
/// - Bir etapta sorulacak ülkeler önceden bellidir: her kategori soruları `TourStructure.preferredCodes`
///   penceresinden çeker (pencere = etap başına 10 ülke). Kartlar bu pencereden üretilir.
/// - "İlk kez göreceği" ülkeler = pencere − (aynı kategoride TAMAMLANMIŞ etapların pencereleri). Bu
///   bilgi zaten kayıtlı ilerlemeden (completedStages) türetilir; yeni bir bulut alanı gerekmez ve
///   cihazlar arasında tutarlıdır. Etap tamamlanmadıysa (canlar bitti, tekrar deneniyor) kartlar yine çıkar.
enum StageCards {
    enum Kind { case flags, capitals, languages, foods }

    /// Bu kategorideki tüm bölümler (ilerleme anahtarı için).
    private static func sections(for kind: Kind) -> [String] {
        switch kind {
        case .flags, .languages, .capitals: FlagGuessStructure.continents + ["Karışık"]
        case .foods: WorldFoodStructure.sections
        }
    }

    private static func baseProgressKey(_ kind: Kind, section: String) -> String {
        switch kind {
        case .flags: section
        case .languages: MainLanguageStructure.progressKey(for: section)
        case .capitals: CapitalStructure.progressKey(for: section)
        case .foods: WorldFoodStructure.progressKey(for: section)
        }
    }

    /// Etapta sorulacak ülke kodları (sorulan havuzla birebir aynı pencere).
    static func windowCodes(_ kind: Kind, section: String, tour: Int, stageIndex: Int) -> [String] {
        let codes: [String]
        switch kind {
        case .flags, .languages:
            codes = Countries.uniqueByCode(Countries.pool(forContinent: section)).map(\.code)
        case .capitals:
            codes = Capitals.pool(forContinent: section).map(\.code)
        case .foods:
            codes = WorldFoods.imageCoveredCountries.map(\.code)
        }
        return Array(TourStructure.preferredCodes(codes, tour: tour, stageIndex: stageIndex)).sorted()
    }

    /// Bu kategoride şimdiye kadar tamamlanan etaplarda geçen tüm ülkeler.
    static func seenCodes(_ kind: Kind, progress: GameProgress) -> Set<String> {
        var seen: Set<String> = []
        for section in sections(for: kind) {
            for tour in 0..<TourStructure.count {
                let key = TourStructure.progressKey(baseProgressKey(kind, section: section), tour: tour)
                guard let done = progress.completedStages[key], !done.isEmpty else { continue }
                for stage in done {
                    seen.formUnion(windowCodes(kind, section: section, tour: tour, stageIndex: stage))
                }
            }
        }
        return seen
    }

    /// Etap başında gösterilecek kartlar. Boşsa kart ekranı atlanır, oyun doğrudan başlar.
    static func cards(_ kind: Kind, section: String, stageIndex: Int, tour: Int, progress: GameProgress) -> [InfoCard] {
        var seen = seenCodes(kind, progress: progress)
        #if DEBUG
        // Yalnızca geliştirme: demo hesapta her etap tamamlanmış sayıldığından kartlar çıkmaz; `-debugForceCards 1`.
        if UserDefaults.standard.bool(forKey: "debugForceCards") { seen = [] }
        #endif
        let unseen = windowCodes(kind, section: section, tour: tour, stageIndex: stageIndex).filter { !seen.contains($0) }
        let nameByCode = Dictionary(Countries.all.map { ($0.code, $0.name) }, uniquingKeysWith: { first, _ in first })
        let cards: [InfoCard] = unseen.compactMap { code in
            guard let countryName = nameByCode[code] else { return nil }
            switch kind {
            case .flags:
                return InfoCard(code: code, countryName: countryName, content: .flag(caption: section == "Karışık" ? nil : L(section)))
            case .capitals:
                guard Capitals.has(code) else { return nil }
                return InfoCard(code: code, countryName: countryName, content: .capital(Capitals.name(for: code)))
            case .languages:
                let language = Languages.language(for: code)
                guard !language.isEmpty else { return nil }
                return InfoCard(code: code, countryName: countryName, content: .language(language))
            case .foods:
                let type = WorldFoodStructure.foodType(for: section) ?? .yemek
                guard let item = WorldFoods.item(for: code, type: type) else { return nil }
                return InfoCard(code: code, countryName: countryName, content: .food(item: D(item), image: WorldFoods.image(for: code, type: type)))
            }
        }
        return cards.sorted { $0.countryName.localizedCompare($1.countryName) == .orderedAscending }
    }
}

#if DEBUG
extension StageCards {
    /// Yalnızca geliştirme: kart seçim kurallarını bellek içi ilerleme ile doğrular (`-debugCardsCheck 1`, çıktı konsola).
    static func debugSelfCheck() {
        var fails = 0
        func check(_ ok: Bool, _ message: String) { print(ok ? "CARDCHECK ok:" : "CARDCHECK FAIL:", message); if !ok { fails += 1 } }
        for (kind, base) in [(Kind.flags, "Avrupa"), (Kind.capitals, CapitalStructure.progressKey(for: "Avrupa"))] {
            let p = GameProgress()
            let w0 = Set(windowCodes(kind, section: "Avrupa", tour: 0, stageIndex: 0))
            let w1 = Set(windowCodes(kind, section: "Avrupa", tour: 0, stageIndex: 1))
            let c0 = cards(kind, section: "Avrupa", stageIndex: 0, tour: 0, progress: p)
            check(Set(c0.map(\.code)).isSubset(of: w0) && c0.count > 0, "\(kind): etap 1, hiç ilerleme yok -> kartlar (\(c0.count))")
            let retry = cards(kind, section: "Avrupa", stageIndex: 0, tour: 0, progress: p)
            check(retry == c0, "\(kind): tamamlanmadan tekrar -> aynı kartlar")
            p.markStageCompleted(continent: base, stageIndex: 0)
            check(cards(kind, section: "Avrupa", stageIndex: 0, tour: 0, progress: p).isEmpty, "\(kind): etap 1 tamamlandı -> tekrar oynayınca kart yok")
            let c1 = cards(kind, section: "Avrupa", stageIndex: 1, tour: 0, progress: p)
            check(Set(c1.map(\.code)).isDisjoint(with: w0) && Set(c1.map(\.code)).isSubset(of: w1), "\(kind): etap 2 -> yalnızca yeni ülkeler (\(c1.count))")
            let tour2 = cards(kind, section: "Avrupa", stageIndex: 0, tour: 1, progress: p)
            check(Set(tour2.map(\.code)).isDisjoint(with: w0), "\(kind): Tur 2 -> Tur 1'de görülenler elenir (\(tour2.count))")
        }
        print("CARDCHECK done fails=\(fails)")
    }
}
#endif
