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

    static func check(_ input: String, code: String) -> Verdict {
        let typed = normalize(input)
        guard typed.count >= 2 else { return .wrong }
        let index = namesByCode

        // Tam eşleşme: hedef ülkenin adlarından biri (aynı ad iki ülkede varsa, ör. "Kongo", ikisi de doğru).
        if index[code]?.contains(typed) == true { return .exact }

        // Tam olarak başka bir ülkenin adı yazıldıysa yanlış.
        if index.contains(where: { $0.key != code && $0.value.contains(typed) }) { return .wrong }

        // Yazım hatası toleransı: hedefe en yakın uzaklık eşik içinde ve başka hiçbir ülke
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
