import Foundation

/// Yazarak cevaplanan sorular (ilk olarak Bayrak "Karışık" bölümü) için cevap kontrolü.
///
/// Kabul edilen adlar: ülkenin Türkçe adı, uygulamanın desteklediği dört dildeki
/// (tr, en, de, es) sistem adı ve yaygın kısaltma/eski adlar (ABD, UK, Holland, Burma...).
/// Büyük/küçük harf, Türkçe karakterler (ı, ş, ğ...), aksanlar, boşluk ve noktalama önemsiz.
///
/// Küçük yazım hataları kabul edilir (4-6 harfte 1, 7+ harfte 2 harf farkı) — ama yazılan
/// metin BAŞKA bir ülkenin adına daha yakınsa ya da tam onunsa yanlış sayılır
/// (ör. Avustralya sorusunda "Avusturya" yazmak yanlıştır).
enum TypedAnswer {
    enum Verdict: Equatable {
        /// Tam doğru.
        case exact
        /// Küçük yazım hatasıyla doğru — doğru yazılışı gösterilir.
        case closeEnough
        case wrong
    }

    /// Ne yazılıyor: ülke adı (Bayrak, Lezzetler), başkent adı (Başkentler) ya da dil adı (Diller).
    enum Kind { case country, capital, language }

    /// Ülke adı kontrolü (Bayrak/Lezzetler) — `code` doğru ülkenin kodu.
    static func check(_ input: String, code: String) -> Verdict {
        check(input, key: code, index: namesByCode)
    }

    /// `key`: ülke/başkent için ülke kodu, dil için Türkçe dil adı (bkz. languageKey).
    static func check(_ input: String, key: String, kind: Kind) -> Verdict {
        switch kind {
        case .country: check(input, key: key, index: namesByCode)
        case .capital: check(input, key: key, index: capitalsByCode)
        case .language: check(input, key: languageKey(key), index: languagesByKey)
        }
    }

    private static func check(_ input: String, key: String, index: [String: Set<String>]) -> Verdict {
        let typed = normalize(input)
        guard typed.count >= 2 else { return .wrong }
        let code = key

        // Tam eşleşme: hedefin adlarından biri (aynı ad iki hedefte varsa, ör. "Kongo", ikisi de doğru).
        if index[code]?.contains(typed) == true { return .exact }

        // Tam olarak başka bir hedefin adı yazıldıysa yanlış.
        if index.contains(where: { $0.key != code && $0.value.contains(typed) }) { return .wrong }

        // Yazım hatası toleransı: hedefe en yakın uzaklık eşik içinde ve başka hiçbir hedef
        // o kadar (ya da daha) yakın değil.
        let tolerance = typed.count <= 3 ? 0 : (typed.count <= 6 ? 1 : 2)
        guard tolerance > 0 else { return .wrong }
        let targetDistance = index[code]?.map { distance(typed, $0, limit: tolerance) }.min() ?? .max
        guard targetDistance <= tolerance else { return .wrong }
        for (other, names) in index where other != code {
            if names.contains(where: { distance(typed, $0, limit: targetDistance) <= targetDistance }) {
                return .wrong
            }
        }
        return .closeEnough
    }

    /// Bir seviyenin sorularından yazılıya çevrilecekleri seçer: ilk soru hiçbir zaman yazılı değildir,
    /// yalnızca `eligible` olanlardan en fazla `typedCount` tanesi rastgele seçilir.
    static func pickIndices(questionCount: Int, typedCount: Int, eligible: (Int) -> Bool) -> [Int] {
        guard typedCount > 0, questionCount > 1 else { return [] }
        return Array((1..<questionCount).filter(eligible).shuffled().prefix(typedCount))
    }

    /// "Karışık" bölümünde seviye başına yazılı soru sayısı: ilk 4 seviyede 2, sonra 3. Diğer bölümlerde 0.
    static func questionCount(section: String, stageIndex: Int) -> Int {
        guard section == "Karışık" else { return 0 }
        return stageIndex < 4 ? 2 : 3
    }

    /// Yazılı soruya uygun (kısa, yazması makul) mu.
    static func isTypeable(_ text: String) -> Bool {
        let n = normalize(text)
        return !n.isEmpty && n.count <= 12
    }

    /// Küçük harf, Türkçe harfler ASCII'ye, aksanlar atılır, yalnızca harf ve rakam kalır.
    static func normalize(_ s: String) -> String {
        let turkishFolded = s
            .replacingOccurrences(of: "İ", with: "i")
            .replacingOccurrences(of: "I", with: "ı")
            .lowercased(with: Locale(identifier: "tr"))
            .replacingOccurrences(of: "ı", with: "i")
            .replacingOccurrences(of: "ß", with: "ss")
        let folded = turkishFolded.folding(options: [.diacriticInsensitive, .caseInsensitive, .widthInsensitive], locale: Locale(identifier: "en"))
        return String(folded.unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) }.map(Character.init))
    }

    /// Kısa (yazması makul) ad mı — yazılı soru için ülke seçerken kullanılır, böylece
    /// "Saint Vincent ve Grenadinler" gibi uzun adlar yazdırılmaz.
    static func isTypeable(_ country: Country) -> Bool {
        normalize(country.name).count <= 12 && normalize(country.turkishName).count <= 14
    }

    /// Başkenti yazdırmaya uygun mu (ör. "Bandar Seri Begawan" değil).
    static func isCapitalTypeable(_ code: String) -> Bool {
        guard let n = Capitals.names[code] else { return false }
        return isTypeable(n.tr) && isTypeable(Capitals.name(for: code))
    }

    /// Dili yazdırmaya uygun mu ("Yok" ve uzun adlar hariç).
    static func isLanguageTypeable(_ turkishLanguage: String) -> Bool {
        turkishLanguage != "Yok" && turkishLanguage != "Bilinmiyor" && isTypeable(turkishLanguage) && isTypeable(D(turkishLanguage))
    }

    // MARK: - Ad dizini

    private static let languages = ["tr", "en", "de", "es"]

    /// Yaygın kısaltma ve eski adlar (normalize edilmiş biçimde eşleşir).
    private static let aliases: [String: [String]] = [
        "US": ["ABD", "Amerika", "USA", "US", "America", "United States", "EEUU", "Estados Unidos", "Vereinigte Staaten"],
        "GB": ["Birleşik Krallık", "UK", "England", "Britain", "Great Britain", "United Kingdom", "Büyük Britanya", "Inglaterra", "Gran Bretaña", "Großbritannien", "Reino Unido"],
        "AE": ["BAE", "UAE", "Emirates", "Emirlikler"],
        "KR": ["Kore", "Korea", "South Korea", "Corea"],
        "KP": ["North Korea"],
        "CZ": ["Çek Cumhuriyeti", "Czech Republic", "Czech", "Tschechien", "Chequia"],
        "NL": ["Holland", "Netherlands", "Nederland", "Holanda"],
        "CI": ["Ivory Coast", "Côte d'Ivoire", "Cote d'Ivoire", "Elfenbeinküste", "Costa de Marfil"],
        "CD": ["Kongo", "Congo", "Kongo DC", "DR Congo", "DRC", "Zaire"],
        "CG": ["Kongo", "Congo", "Kongo Brazzaville", "Congo Brazzaville"],
        "BA": ["Bosna", "Bosnia"],
        "VA": ["Vatikan", "Vatican"],
        "MK": ["Makedonya", "Macedonia", "Mazedonien"],
        "TR": ["Turkey", "Türkiye", "Turkiye", "Türkei", "Turquía"],
        "SZ": ["Svaziland", "Swaziland", "Eswatini"],
        "TL": ["Timor-Leste", "East Timor", "Timor"],
        "CV": ["Cape Verde", "Cabo Verde", "Kap Verde"],
        "MM": ["Burma", "Birmanya", "Birmania"],
        "BY": ["Beyaz Rusya", "Belarus", "Weißrussland", "Bielorrusia"],
        "ST": ["São Tomé", "Sao Tome"],
        "VC": ["Saint Vincent", "St Vincent"],
        "KN": ["Saint Kitts", "St Kitts"],
        "RU": ["Rusya Federasyonu", "Russia"],
        "BO": ["Bolivia"],
        "VE": ["Venezuela"],
        "IR": ["Iran", "İran"],
        "SY": ["Syria", "Suriye"],
        "LA": ["Laos"],
        "VN": ["Vietnam", "Viet Nam"],
        "TZ": ["Tanzania", "Tanzanya"],
        "MD": ["Moldova", "Moldavya"],
        "FM": ["Micronesia", "Mikronezya"],
        "PS": ["Palestine", "Filistin"],
        "GM": ["Gambia", "Gambiya"],
        "BS": ["Bahamas", "Bahamalar"]
    ]

    /// [ülke kodu: normalize edilmiş kabul edilen adlar]
    private static let namesByCode: [String: Set<String>] = {
        let locales = languages.map { Locale(identifier: $0) }
        var map: [String: Set<String>] = [:]
        for country in Countries.uniqueByCode(Countries.all) {
            var names: Set<String> = [normalize(country.turkishName), normalize(country.name)]
            for loc in locales {
                if let n = loc.localizedString(forRegionCode: country.code) { names.insert(normalize(n)) }
            }
            for alias in aliases[country.code] ?? [] { names.insert(normalize(alias)) }
            names.remove("")
            map[country.code] = names
        }
        return map
    }()

    /// Başkent adlarında yaygın kısa/eski yazılışlar.
    private static let capitalAliases: [String: [String]] = [
        "US": ["Washington", "Washington DC"],
        "IN": ["Delhi", "Yeni Delhi", "New Delhi"],
        "CN": ["Beijing", "Pekin"],
        "KR": ["Seoul", "Seul"],
        "BR": ["Brasilia"],
        "VN": ["Hanoi"],
        "MX": ["Mexico", "Mexico City", "Meksiko"],
        "GT": ["Guatemala"],
        "PA": ["Panama"],
        "KW": ["Kuwait", "Kuveyt"],
        "DJ": ["Djibouti", "Cibuti"]
    ]

    /// [ülke kodu: normalize edilmiş başkent adları (tr, en, de, es + kısa yazılışlar)]
    private static let capitalsByCode: [String: Set<String>] = {
        var map: [String: Set<String>] = [:]
        for (code, n) in Capitals.names {
            var names: Set<String> = [normalize(n.tr), normalize(n.en), normalize(n.de), normalize(n.es)]
            for alias in capitalAliases[code] ?? [] { names.insert(normalize(alias)) }
            names.remove("")
            map[code] = names
        }
        return map
    }()

    /// Aynı dilin farklı Türkçe adları tek anahtarda toplanır (Flamanca = Hollandaca, Rumca = Yunanca,
    /// Karadağca = Sırpça) — Belçika sorusunda "Hollandaca" da doğru sayılır.
    private static let sameLanguage: [String: String] = ["Flamanca": "Hollandaca", "Rumca": "Yunanca", "Karadağca": "Sırpça"]
    static func languageKey(_ turkishLanguage: String) -> String { sameLanguage[turkishLanguage] ?? turkishLanguage }

    private static let languageAliases: [String: [String]] = [
        "Azerbaycan Türkçesi": ["Azerice", "Azerbaycanca", "Azeri", "Azerbaijani"],
        "Kiswahili": ["Svahili", "Swahili", "Suahili"],
        "Filipince": ["Tagalog", "Filipino"],
        "Farsça": ["Persian", "Farsi", "Persisch", "Persa"],
        "Çince": ["Mandarin", "Mandarin Çincesi"],
        "Deri": ["Dari"],
        "Hollandaca": ["Felemenkçe", "Flamanca", "Flemish", "Flämisch", "Flamenco"],
        "Yunanca": ["Rumca"],
        "Sırpça": ["Karadağca", "Montenegrin"],
        "Swazi Dili": ["Svazi", "Swazi", "Siswati"],
        "Kiribati Dili": ["Kiribati", "Gilbertese"],
        "İrlandaca": ["Gaelic", "Irish"],
        "Malgaşça": ["Malagasy"],
        "Divehi": ["Dhivehi", "Maldivce"]
    ]

    /// [dil anahtarı: normalize edilmiş dil adları (Türkçe + dört uygulama dilinde sistem adı + kısa yazılışlar)]
    private static let languagesByKey: [String: Set<String>] = {
        let locales = languages.map { Locale(identifier: $0) }
        var map: [String: Set<String>] = [:]
        let all = Set(CountryData.facts.values.map(\.mainLanguage)).subtracting(["Yok", "Bilinmiyor"])
        for lang in all {
            let key = languageKey(lang)
            var names = map[key] ?? []
            names.insert(normalize(lang))
            names.insert(normalize(D(lang)))
            if let iso = DisplayName.languageCode(for: lang) {
                for loc in locales {
                    if let n = loc.localizedString(forLanguageCode: iso), n.lowercased() != iso { names.insert(normalize(n)) }
                }
            }
            for alias in languageAliases[lang] ?? [] { names.insert(normalize(alias)) }
            names.remove("")
            map[key] = names
        }
        return map
    }()

    /// Levenshtein uzaklığı; `limit` aşılınca erken çıkar (dönen değer limit+1 olur).
    static func distance(_ a: String, _ b: String, limit: Int) -> Int {
        let a = Array(a), b = Array(b)
        if abs(a.count - b.count) > limit { return limit + 1 }
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }
        var prev = Array(0...b.count)
        var cur = [Int](repeating: 0, count: b.count + 1)
        for i in 1...a.count {
            cur[0] = i
            var rowMin = cur[0]
            for j in 1...b.count {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                cur[j] = min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost)
                rowMin = min(rowMin, cur[j])
            }
            if rowMin > limit { return limit + 1 }
            swap(&prev, &cur)
        }
        return prev[b.count]
    }
}
