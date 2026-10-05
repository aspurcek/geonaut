import Foundation

/// Kodda Türkçe kaynak metinle tutulan veri değerlerini (kıta adı, bölüm adı vb.)
/// görüntülemeden önce String Catalog'dan çevirir. Katalogda karşılığı yoksa metin
/// olduğu gibi (Türkçe) döner — ilerleme anahtarları ve karşılaştırmalar HER ZAMAN
/// Türkçe ham değerle yapılır, yalnızca ekrana basılan metin çevrilir.
func L(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}

/// Ekrana basılan ülke ve dil adlarını uygulamanın dilinde döndürür. Veri Türkçe
/// kalır (şık karşılaştırmaları, ilerleme anahtarları); yalnızca GÖSTERİM çevrilir.
/// Ülke adları sistemin `Locale`'inden, dil adları ISO dil koduyla aynı yerden gelir;
/// Locale'de karşılığı yoksa String Catalog'a, o da yoksa Türkçe asıl metne düşer.
func D(_ turkishName: String) -> String {
    DisplayName.localized(turkishName)
}

enum DisplayName {
    static let locale = Locale(identifier: Bundle.main.preferredLocalizations.first ?? "tr")

    private static let countryCodeByName: [String: String] = {
        var map: [String: String] = [:]
        for c in Countries.all { map[c.turkishName] = c.code }
        for c in MapCountries.all { map[c.turkishName] = c.code }
        return map
    }()

    private static let languageCodeByName: [String: String] = [
        "İngilizce": "en", "Fransızca": "fr", "İspanyolca": "es", "Arapça": "ar", "Portekizce": "pt",
        "Hollandaca": "nl", "Çince": "zh", "Almanca": "de", "İtalyanca": "it", "Norveççe": "no",
        "Malayca": "ms", "İsveççe": "sv", "Samoaca": "sm", "Rumence": "ro", "Korece": "ko",
        "Kiswahili": "sw", "Arnavutça": "sq", "İzlandaca": "is", "İrlandaca": "ga", "İbranice": "he",
        "Özbekçe": "uz", "Çekçe": "cs", "Zuluca": "zu", "Yunanca": "el", "Vietnamca": "vi",
        "Urduca": "ur", "Ukraynaca": "uk", "Türkçe": "tr", "Türkmence": "tk", "Tuvaluca": "tvl",
        "Tongaca": "to", "Tigrinya": "ti", "Tetum": "tet", "Tayca": "th", "Tacikçe": "tg",
        "Sırpça": "sr", "Swazi Dili": "ss", "Somalice": "so", "Slovence": "sl", "Slovakça": "sk",
        "Sinhalaca": "si", "Sesotho": "st", "Rusça": "ru", "Rumca": "el", "Palauca": "pau",
        "Niueca": "niu", "Nepalce": "ne", "Nauruca": "na", "Moğolca": "mn", "Marshallce": "mh",
        "Maltaca": "mt", "Malgaşça": "mg", "Makedonca": "mk", "Macarca": "hu", "Lüksemburgca": "lb",
        "Litvanca": "lt", "Letonca": "lv", "Lehçe": "pl", "Laoca": "lo", "Kırgızca": "ky",
        "Komorca": "zdj", "Kirundi": "rn", "Kiribati Dili": "gil", "Kinyarwanda": "rw", "Khmerce": "km",
        "Kazakça": "kk", "Katalanca": "ca", "Karadağca": "sr", "Japonca": "ja", "Hırvatça": "hr",
        "Hintçe": "hi", "Gürcüce": "ka", "Grönlandca": "kl", "Flamanca": "nl", "Fince": "fi",
        "Filipince": "fil", "Farsça": "fa", "Faroece": "fo", "Estonca": "et", "Ermenice": "hy",
        "Endonezce": "id", "Dzongkha": "dz", "Divehi": "dv", "Deri": "prs", "Danca": "da",
        "Chichewa": "ny", "Bulgarca": "bg", "Boşnakça": "bs", "Bislama": "bi", "Birmanca": "my",
        "Bengalce": "bn", "Belarusça": "be", "Azerbaycan Türkçesi": "az", "Amharca": "am"
    ]

    static func localized(_ turkishName: String) -> String {
        let loc = locale
        if loc.language.languageCode?.identifier == "tr" { return turkishName }
        if let code = countryCodeByName[turkishName], let name = loc.localizedString(forRegionCode: code) {
            return name
        }
        if let code = languageCodeByName[turkishName], let name = loc.localizedString(forLanguageCode: code),
           name.lowercased() != code {
            return name.prefix(1).uppercased(with: loc) + name.dropFirst()
        }
        return L(turkishName)
    }
}

/// "Öğren" listeleri (Bayraklar/Diller/Lezzetler/Haritalar) Türkçe kaynak veride
/// zaten alfabetik sıralı — ama İngilizce/Almanca/İspanyolca'da gösterilen ad
/// (D(...)) farklı harfle başlayabiliyor (ör. "Almanya" → "Germany"). Kullanıcı
/// hangi dildeyse liste de O DİLİN alfabesine göre sıralı görünmeli.
extension Sequence {
    func sortedLocalized(by name: (Element) -> String) -> [Element] {
        sorted {
            name($0).compare(name($1), options: [.caseInsensitive, .diacriticInsensitive], range: nil, locale: DisplayName.locale) == .orderedAscending
        }
    }
}
