import Foundation

/// Bir ülke hakkında Bayrak Tahmin ve Ana Diller'in ORTAK kullandığı ek gerçekler —
/// kıtası ve ana/resmi dili. `Countries.swift`'teki 7 kıta havuzuyla aynı ~92 ülkeyi
/// kapsar (bkz. o dosyanın "geçici veri seti" notu — bu da aynı ölçekte bir ara veri).
/// İki kullanım yeri: (1) Ana Diller'in soru havuzları (bkz. Languages.swift),
/// (2) "Bayrakları/Ana Dilleri Öğren" listelerindeki ülke bilgi kartı (bkz.
/// KasifCountryInfoCard) — kullanıcı kararı: satırlara dokunca ülke adı, bayrağı,
/// dili ve kıtası gösterilsin.
struct CountryFacts {
    let continent: String
    let mainLanguage: String
    /// "Zor ana dil" — çocuğun stereotipik tahmininden farklı, öğretici bir sürpriz
    /// (ör. Brezilya→Portekizce, Avusturya→Almanca, Cezayir→Arapça). Ana Diller'in
    /// 5-6. etapları bu alt kümeden soru üretir (bkz. MainLanguageStructure).
    let isTrickyLanguage: Bool
}

enum CountryData {
    static let facts: [String: CountryFacts] = [
        // MARK: Avrupa
        "DE": CountryFacts(continent: "Avrupa", mainLanguage: "Almanca", isTrickyLanguage: false),
        "FR": CountryFacts(continent: "Avrupa", mainLanguage: "Fransızca", isTrickyLanguage: false),
        "ES": CountryFacts(continent: "Avrupa", mainLanguage: "İspanyolca", isTrickyLanguage: false),
        "IT": CountryFacts(continent: "Avrupa", mainLanguage: "İtalyanca", isTrickyLanguage: false),
        "GB": CountryFacts(continent: "Avrupa", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "NL": CountryFacts(continent: "Avrupa", mainLanguage: "Hollandaca", isTrickyLanguage: false),
        // Belçika'nın 3 resmi dili var (Flamanca/Fransızca/Almanca) — en yaygını
        // Flamanca seçildi, bu yüzden zor/sürpriz kabul edildi.
        "BE": CountryFacts(continent: "Avrupa", mainLanguage: "Flamanca", isTrickyLanguage: true),
        // Klasik tuzak: ülke adı "Avusturya" ama dili "Avusturyaca" değil, Almanca.
        "AT": CountryFacts(continent: "Avrupa", mainLanguage: "Almanca", isTrickyLanguage: true),
        "SE": CountryFacts(continent: "Avrupa", mainLanguage: "İsveççe", isTrickyLanguage: false),
        "NO": CountryFacts(continent: "Avrupa", mainLanguage: "Norveççe", isTrickyLanguage: false),
        "DK": CountryFacts(continent: "Avrupa", mainLanguage: "Danca", isTrickyLanguage: false),
        "FI": CountryFacts(continent: "Avrupa", mainLanguage: "Fince", isTrickyLanguage: false),
        // Klasik tuzak: Türkçede "Lehçe" denir, "Polonyaca" değil.
        "PL": CountryFacts(continent: "Avrupa", mainLanguage: "Lehçe", isTrickyLanguage: true),
        "GR": CountryFacts(continent: "Avrupa", mainLanguage: "Yunanca", isTrickyLanguage: false),
        "PT": CountryFacts(continent: "Avrupa", mainLanguage: "Portekizce", isTrickyLanguage: false),
        // 4 resmi dili var (Almanca/Fransızca/İtalyanca/Romence) — en çok konuşulanı
        // Almanca, ama tek bir "İsviçrece" olmaması başlı başına sürpriz.
        "CH": CountryFacts(continent: "Avrupa", mainLanguage: "Almanca", isTrickyLanguage: true),
        // Resmi dili İrlandaca (Gaelce) — günlük hayatta İngilizce baskın olsa da
        // resmi/anayasal ilk dil İrlandaca, bu yüzden çocuklar için sürpriz.
        "IE": CountryFacts(continent: "Avrupa", mainLanguage: "İrlandaca", isTrickyLanguage: true),
        "TR": CountryFacts(continent: "Avrupa", mainLanguage: "Türkçe", isTrickyLanguage: false),

        // MARK: Asya
        "CN": CountryFacts(continent: "Asya", mainLanguage: "Çince", isTrickyLanguage: false),
        "JP": CountryFacts(continent: "Asya", mainLanguage: "Japonca", isTrickyLanguage: false),
        // 22 resmi dilden biri Hintçe — İngilizce de eş resmi, çok dillilik sürpriz.
        "IN": CountryFacts(continent: "Asya", mainLanguage: "Hintçe", isTrickyLanguage: true),
        "KR": CountryFacts(continent: "Asya", mainLanguage: "Korece", isTrickyLanguage: false),
        "TH": CountryFacts(continent: "Asya", mainLanguage: "Tayca", isTrickyLanguage: false),
        "VN": CountryFacts(continent: "Asya", mainLanguage: "Vietnamca", isTrickyLanguage: false),
        "ID": CountryFacts(continent: "Asya", mainLanguage: "Endonezce", isTrickyLanguage: false),
        "MY": CountryFacts(continent: "Asya", mainLanguage: "Malayca", isTrickyLanguage: false),
        // Malayca anayasal ulusal dil ama günlük işlerde İngilizce baskın — sürpriz.
        "SG": CountryFacts(continent: "Asya", mainLanguage: "Malayca", isTrickyLanguage: true),
        // Filipince resmi dil, ama İngilizce de çok yaygın — çocuklar İngilizce sanabilir.
        "PH": CountryFacts(continent: "Asya", mainLanguage: "Filipince", isTrickyLanguage: true),
        "SA": CountryFacts(continent: "Asya", mainLanguage: "Arapça", isTrickyLanguage: false),
        "AE": CountryFacts(continent: "Asya", mainLanguage: "Arapça", isTrickyLanguage: false),
        "IL": CountryFacts(continent: "Asya", mainLanguage: "İbranice", isTrickyLanguage: false),
        // Sıkça Hintçe/Arapça ile karıştırılır — resmi dili Urduca.
        "PK": CountryFacts(continent: "Asya", mainLanguage: "Urduca", isTrickyLanguage: true),
        "BD": CountryFacts(continent: "Asya", mainLanguage: "Bengalce", isTrickyLanguage: false),
        // Klasik tuzak: Orta Doğu'da olduğu için Arapça sanılır, ama İran'ın dili Farsça.
        "IR": CountryFacts(continent: "Asya", mainLanguage: "Farsça", isTrickyLanguage: true),
        "IQ": CountryFacts(continent: "Asya", mainLanguage: "Arapça", isTrickyLanguage: false),
        "MN": CountryFacts(continent: "Asya", mainLanguage: "Moğolca", isTrickyLanguage: false),

        // MARK: Afrika
        "EG": CountryFacts(continent: "Afrika", mainLanguage: "Arapça", isTrickyLanguage: false),
        // 11 resmi dili var — en çok ana dili olarak konuşulan Zuluca seçildi, çoğu
        // çocuk İngilizce ya da Afrikaanca tahmin eder.
        "ZA": CountryFacts(continent: "Afrika", mainLanguage: "Zuluca", isTrickyLanguage: true),
        "NG": CountryFacts(continent: "Afrika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "KE": CountryFacts(continent: "Afrika", mainLanguage: "Kiswahili", isTrickyLanguage: false),
        "MA": CountryFacts(continent: "Afrika", mainLanguage: "Arapça", isTrickyLanguage: false),
        // Hiç sömürge olmamış tek Afrika ülkelerinden — kendi alfabesi/dili Amharca.
        "ET": CountryFacts(continent: "Afrika", mainLanguage: "Amharca", isTrickyLanguage: true),
        "GH": CountryFacts(continent: "Afrika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "TZ": CountryFacts(continent: "Afrika", mainLanguage: "Kiswahili", isTrickyLanguage: false),
        // Fransız sömürge geçmişi yüzünden Fransızca sanılır, resmi dili Arapça.
        "DZ": CountryFacts(continent: "Afrika", mainLanguage: "Arapça", isTrickyLanguage: true),
        "TN": CountryFacts(continent: "Afrika", mainLanguage: "Arapça", isTrickyLanguage: false),
        "SN": CountryFacts(continent: "Afrika", mainLanguage: "Fransızca", isTrickyLanguage: false),
        "CI": CountryFacts(continent: "Afrika", mainLanguage: "Fransızca", isTrickyLanguage: false),
        "UG": CountryFacts(continent: "Afrika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        // Nadir bir ikili resmi dil kombinasyonu: Fransızca + İngilizce.
        "CM": CountryFacts(continent: "Afrika", mainLanguage: "Fransızca", isTrickyLanguage: true),
        "ZM": CountryFacts(continent: "Afrika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "ZW": CountryFacts(continent: "Afrika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "LY": CountryFacts(continent: "Afrika", mainLanguage: "Arapça", isTrickyLanguage: false),
        // Malayo-Polinezya kökenli, Afrika'nın geri kalanından tamamen farklı bir dil ailesi.
        "MG": CountryFacts(continent: "Afrika", mainLanguage: "Malgaşça", isTrickyLanguage: true),

        // MARK: Kuzey Amerika
        "US": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        // Resmen iki dilli — Fransızca da eş resmi dil, çoğu çocuk bilmez.
        "CA": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İngilizce", isTrickyLanguage: true),
        "MX": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İspanyolca", isTrickyLanguage: false),
        "CU": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İspanyolca", isTrickyLanguage: false),
        "JM": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "PA": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İspanyolca", isTrickyLanguage: false),
        "CR": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İspanyolca", isTrickyLanguage: false),
        "GT": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İspanyolca", isTrickyLanguage: false),
        "HN": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İspanyolca", isTrickyLanguage: false),
        "NI": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İspanyolca", isTrickyLanguage: false),
        "DO": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İspanyolca", isTrickyLanguage: false),
        // Günlük hayatta Kreyol (Haiti Creole) daha yaygın konuşulur, resmi dillerden
        // biri Fransızca — ikisi de resmi ama Fransızca burada seçildi.
        "HT": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "Fransızca", isTrickyLanguage: true),
        "BS": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        // Orta Amerika'da tek İspanyolca konuşmayan ülke — resmi dili İngilizce.
        "BZ": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İngilizce", isTrickyLanguage: true),

        // MARK: Güney Amerika
        // EN KLASİK tuzak: Güney Amerika'da olduğu için İspanyolca sanılır, ama
        // Brezilya'nın dili Portekizce.
        "BR": CountryFacts(continent: "Güney Amerika", mainLanguage: "Portekizce", isTrickyLanguage: true),
        "AR": CountryFacts(continent: "Güney Amerika", mainLanguage: "İspanyolca", isTrickyLanguage: false),
        "CL": CountryFacts(continent: "Güney Amerika", mainLanguage: "İspanyolca", isTrickyLanguage: false),
        "CO": CountryFacts(continent: "Güney Amerika", mainLanguage: "İspanyolca", isTrickyLanguage: false),
        "PE": CountryFacts(continent: "Güney Amerika", mainLanguage: "İspanyolca", isTrickyLanguage: false),
        "VE": CountryFacts(continent: "Güney Amerika", mainLanguage: "İspanyolca", isTrickyLanguage: false),
        "EC": CountryFacts(continent: "Güney Amerika", mainLanguage: "İspanyolca", isTrickyLanguage: false),
        "BO": CountryFacts(continent: "Güney Amerika", mainLanguage: "İspanyolca", isTrickyLanguage: false),
        // Guaraní de eş resmi dil ve halkın çoğu konuşuyor — İspanyolca/Guaraní ikilemi sürpriz.
        "PY": CountryFacts(continent: "Güney Amerika", mainLanguage: "İspanyolca", isTrickyLanguage: true),
        "UY": CountryFacts(continent: "Güney Amerika", mainLanguage: "İspanyolca", isTrickyLanguage: false),
        // Güney Amerika'da İngilizce konuşan tek ülke.
        "GY": CountryFacts(continent: "Güney Amerika", mainLanguage: "İngilizce", isTrickyLanguage: true),
        // Güney Amerika'da Hollandaca konuşulması büyük bir sürpriz.
        "SR": CountryFacts(continent: "Güney Amerika", mainLanguage: "Hollandaca", isTrickyLanguage: true),

        // MARK: Okyanusya
        "AU": CountryFacts(continent: "Okyanusya", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "NZ": CountryFacts(continent: "Okyanusya", mainLanguage: "İngilizce", isTrickyLanguage: false),
        // 3 resmi dili var (İngilizce/Fijice/Fiji Hintçesi).
        "FJ": CountryFacts(continent: "Okyanusya", mainLanguage: "İngilizce", isTrickyLanguage: true),
        // Dünyanın en dilsel çeşitliliğe sahip ülkesi — 800'den fazla dil konuşuluyor.
        "PG": CountryFacts(continent: "Okyanusya", mainLanguage: "İngilizce", isTrickyLanguage: true),
        "WS": CountryFacts(continent: "Okyanusya", mainLanguage: "Samoaca", isTrickyLanguage: false),
        "TO": CountryFacts(continent: "Okyanusya", mainLanguage: "Tongaca", isTrickyLanguage: false),
        // 3 resmi dili var (Bislama/İngilizce/Fransızca) — Bislama ulusal dil.
        "VU": CountryFacts(continent: "Okyanusya", mainLanguage: "Bislama", isTrickyLanguage: true),
        "SB": CountryFacts(continent: "Okyanusya", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "KI": CountryFacts(continent: "Okyanusya", mainLanguage: "Kiribati Dili", isTrickyLanguage: false),
        "PW": CountryFacts(continent: "Okyanusya", mainLanguage: "Palauca", isTrickyLanguage: false),
        "MH": CountryFacts(continent: "Okyanusya", mainLanguage: "Marshallce", isTrickyLanguage: false),
        "TV": CountryFacts(continent: "Okyanusya", mainLanguage: "Tuvaluca", isTrickyLanguage: false),
    ]

    static func facts(for code: String) -> CountryFacts? { facts[code] }
}
