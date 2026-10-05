import Foundation

/// Bir ülke hakkında Bayrak Tahmin ve Ana Diller'in ORTAK kullandığı ek gerçekler —
/// kıtası ve ana/resmi dili. `Countries.all`'daki 249 ülkenin tamamını kapsar (yalnızca
/// quiz'lerin kullandığı 7 kıta havuzu hâlâ küçük bir alt küme — bkz. Countries.swift'in
/// "geçici veri seti" notu). İki kullanım yeri: (1) Ana Diller'in soru havuzları (bkz. Languages.swift),
/// (2) "Bayrakları/Ana Dilleri Öğren" listelerindeki ülke bilgi kartı (bkz.
/// GeoCountryInfoCard) — kullanıcı kararı: satırlara dokunca ülke adı, bayrağı,
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

        // MARK: Okyanusya (ek — küçük ada/bölgeler)
        "AS": CountryFacts(continent: "Okyanusya", mainLanguage: "Samoaca", isTrickyLanguage: false),
        "CK": CountryFacts(continent: "Okyanusya", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "FM": CountryFacts(continent: "Okyanusya", mainLanguage: "İngilizce", isTrickyLanguage: false),
        // Chamorro da eş resmi dil.
        "GU": CountryFacts(continent: "Okyanusya", mainLanguage: "İngilizce", isTrickyLanguage: true),
        "MP": CountryFacts(continent: "Okyanusya", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "NC": CountryFacts(continent: "Okyanusya", mainLanguage: "Fransızca", isTrickyLanguage: false),
        "NF": CountryFacts(continent: "Okyanusya", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "NR": CountryFacts(continent: "Okyanusya", mainLanguage: "Nauruca", isTrickyLanguage: false),
        "NU": CountryFacts(continent: "Okyanusya", mainLanguage: "Niueca", isTrickyLanguage: false),
        "PF": CountryFacts(continent: "Okyanusya", mainLanguage: "Fransızca", isTrickyLanguage: false),
        "PN": CountryFacts(continent: "Okyanusya", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "WF": CountryFacts(continent: "Okyanusya", mainLanguage: "Fransızca", isTrickyLanguage: false),
        "CX": CountryFacts(continent: "Okyanusya", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "CC": CountryFacts(continent: "Okyanusya", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "TK": CountryFacts(continent: "Okyanusya", mainLanguage: "İngilizce", isTrickyLanguage: false),

        // MARK: Avrupa (ek — küçük ülkeler/bölgeler)
        // Fransa/İspanya arasında ama resmi dili Katalanca.
        "AD": CountryFacts(continent: "Avrupa", mainLanguage: "Katalanca", isTrickyLanguage: true),
        "AL": CountryFacts(continent: "Avrupa", mainLanguage: "Arnavutça", isTrickyLanguage: false),
        // Rusça da yaygın konuşulur/eş resmi statüde tartışmalı — Belarusça sürpriz.
        "BY": CountryFacts(continent: "Avrupa", mainLanguage: "Belarusça", isTrickyLanguage: true),
        // 3 halkın da dili eş resmi (Boşnakça/Sırpça/Hırvatça) — tek dil yok.
        "BA": CountryFacts(continent: "Avrupa", mainLanguage: "Boşnakça", isTrickyLanguage: true),
        "BG": CountryFacts(continent: "Avrupa", mainLanguage: "Bulgarca", isTrickyLanguage: false),
        "CZ": CountryFacts(continent: "Avrupa", mainLanguage: "Çekçe", isTrickyLanguage: false),
        "EE": CountryFacts(continent: "Avrupa", mainLanguage: "Estonca", isTrickyLanguage: false),
        // Danimarka'ya bağlı ama kendi Faroece dili var.
        "FO": CountryFacts(continent: "Avrupa", mainLanguage: "Faroece", isTrickyLanguage: true),
        // İspanya'ya bitişik ama İngiliz toprağı.
        "GI": CountryFacts(continent: "Avrupa", mainLanguage: "İngilizce", isTrickyLanguage: true),
        "GG": CountryFacts(continent: "Avrupa", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "HR": CountryFacts(continent: "Avrupa", mainLanguage: "Hırvatça", isTrickyLanguage: false),
        "HU": CountryFacts(continent: "Avrupa", mainLanguage: "Macarca", isTrickyLanguage: false),
        "IM": CountryFacts(continent: "Avrupa", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "IS": CountryFacts(continent: "Avrupa", mainLanguage: "İzlandaca", isTrickyLanguage: false),
        "JE": CountryFacts(continent: "Avrupa", mainLanguage: "İngilizce", isTrickyLanguage: false),
        // Nüfusun çoğu Arnavutça konuşur, Sırpça da eş resmi.
        "XK": CountryFacts(continent: "Avrupa", mainLanguage: "Arnavutça", isTrickyLanguage: true),
        "LV": CountryFacts(continent: "Avrupa", mainLanguage: "Letonca", isTrickyLanguage: false),
        "LI": CountryFacts(continent: "Avrupa", mainLanguage: "Almanca", isTrickyLanguage: false),
        "LT": CountryFacts(continent: "Avrupa", mainLanguage: "Litvanca", isTrickyLanguage: false),
        // Kendi dili var ama Fransızca/Almanca da eş resmi.
        "LU": CountryFacts(continent: "Avrupa", mainLanguage: "Lüksemburgca", isTrickyLanguage: true),
        // İngilizce de eş resmi dil — çoğu çocuk yalnızca İngilizce sanır.
        "MT": CountryFacts(continent: "Avrupa", mainLanguage: "Maltaca", isTrickyLanguage: true),
        // "Moldovaca" diye bilinen dil aslında Rumence.
        "MD": CountryFacts(continent: "Avrupa", mainLanguage: "Rumence", isTrickyLanguage: true),
        "MC": CountryFacts(continent: "Avrupa", mainLanguage: "Fransızca", isTrickyLanguage: false),
        // Sırpçaya çok yakın kendi standart dili.
        "ME": CountryFacts(continent: "Avrupa", mainLanguage: "Karadağca", isTrickyLanguage: true),
        "MK": CountryFacts(continent: "Avrupa", mainLanguage: "Makedonca", isTrickyLanguage: false),
        "RO": CountryFacts(continent: "Avrupa", mainLanguage: "Rumence", isTrickyLanguage: false),
        "RS": CountryFacts(continent: "Avrupa", mainLanguage: "Sırpça", isTrickyLanguage: false),
        "RU": CountryFacts(continent: "Avrupa", mainLanguage: "Rusça", isTrickyLanguage: false),
        "SM": CountryFacts(continent: "Avrupa", mainLanguage: "İtalyanca", isTrickyLanguage: false),
        "SK": CountryFacts(continent: "Avrupa", mainLanguage: "Slovakça", isTrickyLanguage: false),
        "SI": CountryFacts(continent: "Avrupa", mainLanguage: "Slovence", isTrickyLanguage: false),
        "SJ": CountryFacts(continent: "Avrupa", mainLanguage: "Norveççe", isTrickyLanguage: false),
        "UA": CountryFacts(continent: "Avrupa", mainLanguage: "Ukraynaca", isTrickyLanguage: false),
        // Resmi tören dili Latince, günlük idari dili İtalyanca — büyük sürpriz.
        "VA": CountryFacts(continent: "Avrupa", mainLanguage: "İtalyanca", isTrickyLanguage: true),
        // Finlandiya'ya bağlı ama nüfusun neredeyse tamamı İsveççe konuşur.
        "AX": CountryFacts(continent: "Avrupa", mainLanguage: "İsveççe", isTrickyLanguage: true),
        "AM": CountryFacts(continent: "Asya", mainLanguage: "Ermenice", isTrickyLanguage: false),
        "GE": CountryFacts(continent: "Asya", mainLanguage: "Gürcüce", isTrickyLanguage: false),
        // Rumca resmi dil, adanın kuzeyinde Türkçe de konuşulur.
        "CY": CountryFacts(continent: "Avrupa", mainLanguage: "Rumca", isTrickyLanguage: true),

        // MARK: Asya (ek — Orta Asya, Orta Doğu, Güney/Güneydoğu Asya)
        // Deri (Farsça) idari/ortak dil, Peştuca etnik çoğunluk dili — ikisi de resmi.
        "AF": CountryFacts(continent: "Asya", mainLanguage: "Deri", isTrickyLanguage: true),
        "AZ": CountryFacts(continent: "Asya", mainLanguage: "Azerbaycan Türkçesi", isTrickyLanguage: false),
        "BH": CountryFacts(continent: "Asya", mainLanguage: "Arapça", isTrickyLanguage: false),
        // Kendine özgü, dünyada başka yerde konuşulmayan bir dil.
        "BT": CountryFacts(continent: "Asya", mainLanguage: "Dzongkha", isTrickyLanguage: true),
        "BN": CountryFacts(continent: "Asya", mainLanguage: "Malayca", isTrickyLanguage: false),
        "KH": CountryFacts(continent: "Asya", mainLanguage: "Khmerce", isTrickyLanguage: false),
        // Kantonca günlük dil, İngilizce de eş resmi — "Çince" beklenmedik ayrıntı.
        "HK": CountryFacts(continent: "Asya", mainLanguage: "Çince", isTrickyLanguage: true),
        "KZ": CountryFacts(continent: "Asya", mainLanguage: "Kazakça", isTrickyLanguage: false),
        "KG": CountryFacts(continent: "Asya", mainLanguage: "Kırgızca", isTrickyLanguage: false),
        "KW": CountryFacts(continent: "Asya", mainLanguage: "Arapça", isTrickyLanguage: false),
        "KP": CountryFacts(continent: "Asya", mainLanguage: "Korece", isTrickyLanguage: false),
        "LA": CountryFacts(continent: "Asya", mainLanguage: "Laoca", isTrickyLanguage: false),
        "LB": CountryFacts(continent: "Asya", mainLanguage: "Arapça", isTrickyLanguage: false),
        // Sinhalaca çoğunluk dili, Tamilce de eş resmi.
        "LK": CountryFacts(continent: "Asya", mainLanguage: "Sinhalaca", isTrickyLanguage: true),
        // Portekizce de eş resmi dil — eski Portekiz sömürgesi.
        "MO": CountryFacts(continent: "Asya", mainLanguage: "Çince", isTrickyLanguage: true),
        // Kendine özgü, dünyada başka yerde konuşulmayan bir dil.
        "MV": CountryFacts(continent: "Asya", mainLanguage: "Divehi", isTrickyLanguage: true),
        "MM": CountryFacts(continent: "Asya", mainLanguage: "Birmanca", isTrickyLanguage: false),
        "NP": CountryFacts(continent: "Asya", mainLanguage: "Nepalce", isTrickyLanguage: false),
        "OM": CountryFacts(continent: "Asya", mainLanguage: "Arapça", isTrickyLanguage: false),
        "PS": CountryFacts(continent: "Asya", mainLanguage: "Arapça", isTrickyLanguage: false),
        "QA": CountryFacts(continent: "Asya", mainLanguage: "Arapça", isTrickyLanguage: false),
        "SY": CountryFacts(continent: "Asya", mainLanguage: "Arapça", isTrickyLanguage: false),
        "TW": CountryFacts(continent: "Asya", mainLanguage: "Çince", isTrickyLanguage: false),
        "TJ": CountryFacts(continent: "Asya", mainLanguage: "Tacikçe", isTrickyLanguage: false),
        // Portekizce de eş resmi dil — Güneydoğu Asya'da nadir bir kombinasyon.
        "TL": CountryFacts(continent: "Asya", mainLanguage: "Tetum", isTrickyLanguage: true),
        "TM": CountryFacts(continent: "Asya", mainLanguage: "Türkmence", isTrickyLanguage: false),
        "UZ": CountryFacts(continent: "Asya", mainLanguage: "Özbekçe", isTrickyLanguage: false),
        "JO": CountryFacts(continent: "Asya", mainLanguage: "Arapça", isTrickyLanguage: false),
        "YE": CountryFacts(continent: "Asya", mainLanguage: "Arapça", isTrickyLanguage: false),

        // MARK: Afrika (ek)
        "AO": CountryFacts(continent: "Afrika", mainLanguage: "Portekizce", isTrickyLanguage: false),
        "BJ": CountryFacts(continent: "Afrika", mainLanguage: "Fransızca", isTrickyLanguage: false),
        // Setswana ulusal dil, İngilizce resmi dil — ikilem sürpriz.
        "BW": CountryFacts(continent: "Afrika", mainLanguage: "İngilizce", isTrickyLanguage: true),
        "BF": CountryFacts(continent: "Afrika", mainLanguage: "Fransızca", isTrickyLanguage: false),
        // Fransızca resmi dil ama Kirundi ulusal/en çok konuşulan dil.
        "BI": CountryFacts(continent: "Afrika", mainLanguage: "Kirundi", isTrickyLanguage: true),
        // Fransızca ve Arapça birlikte resmi.
        "TD": CountryFacts(continent: "Afrika", mainLanguage: "Fransızca", isTrickyLanguage: true),
        // Fransızca ve Arapça birlikte resmi.
        "DJ": CountryFacts(continent: "Afrika", mainLanguage: "Fransızca", isTrickyLanguage: true),
        // Afrika'da İspanyolca konuşulan tek ülke.
        "GQ": CountryFacts(continent: "Afrika", mainLanguage: "İspanyolca", isTrickyLanguage: true),
        // Kendine özgü alfabesi olan, hiç sömürge olmamışa yakın bir dil.
        "ER": CountryFacts(continent: "Afrika", mainLanguage: "Tigrinya", isTrickyLanguage: true),
        // İngilizce de eş resmi dil.
        "SZ": CountryFacts(continent: "Afrika", mainLanguage: "Swazi Dili", isTrickyLanguage: true),
        "GA": CountryFacts(continent: "Afrika", mainLanguage: "Fransızca", isTrickyLanguage: false),
        "GM": CountryFacts(continent: "Afrika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "GN": CountryFacts(continent: "Afrika", mainLanguage: "Fransızca", isTrickyLanguage: false),
        // Batı Afrika'da Fransızca konuşan komşularının arasında nadir bir Portekizce örneği.
        "GW": CountryFacts(continent: "Afrika", mainLanguage: "Portekizce", isTrickyLanguage: true),
        // Arapça/Fransızca de resmi ama Komorca ulusal dil.
        "KM": CountryFacts(continent: "Afrika", mainLanguage: "Komorca", isTrickyLanguage: true),
        "CG": CountryFacts(continent: "Afrika", mainLanguage: "Fransızca", isTrickyLanguage: false),
        "CD": CountryFacts(continent: "Afrika", mainLanguage: "Fransızca", isTrickyLanguage: false),
        // İngilizce de eş resmi dil.
        "LS": CountryFacts(continent: "Afrika", mainLanguage: "Sesotho", isTrickyLanguage: true),
        "LR": CountryFacts(continent: "Afrika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        // İngilizce de eş resmi dil.
        "MW": CountryFacts(continent: "Afrika", mainLanguage: "Chichewa", isTrickyLanguage: true),
        "ML": CountryFacts(continent: "Afrika", mainLanguage: "Fransızca", isTrickyLanguage: false),
        "MR": CountryFacts(continent: "Afrika", mainLanguage: "Arapça", isTrickyLanguage: false),
        // Günlük hayatta Fransızca/Creole yaygın, resmi dillerden biri İngilizce.
        "MU": CountryFacts(continent: "Afrika", mainLanguage: "İngilizce", isTrickyLanguage: true),
        "YT": CountryFacts(continent: "Afrika", mainLanguage: "Fransızca", isTrickyLanguage: false),
        "MZ": CountryFacts(continent: "Afrika", mainLanguage: "Portekizce", isTrickyLanguage: false),
        "NA": CountryFacts(continent: "Afrika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "NE": CountryFacts(continent: "Afrika", mainLanguage: "Fransızca", isTrickyLanguage: false),
        // Sango da eş resmi dil.
        "CF": CountryFacts(continent: "Afrika", mainLanguage: "Fransızca", isTrickyLanguage: true),
        // Fransızca/İngilizce de eş resmi ama Kinyarwanda ulusal dil.
        "RW": CountryFacts(continent: "Afrika", mainLanguage: "Kinyarwanda", isTrickyLanguage: true),
        "RE": CountryFacts(continent: "Afrika", mainLanguage: "Fransızca", isTrickyLanguage: false),
        "SH": CountryFacts(continent: "Afrika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        // İngilizce/Fransızca de eş resmi ama Seselwa Creole ulusal dil.
        "SC": CountryFacts(continent: "Afrika", mainLanguage: "Fransızca", isTrickyLanguage: true),
        "SL": CountryFacts(continent: "Afrika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        // Arapça da eş resmi dil.
        "SO": CountryFacts(continent: "Afrika", mainLanguage: "Somalice", isTrickyLanguage: true),
        "SS": CountryFacts(continent: "Afrika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "SD": CountryFacts(continent: "Afrika", mainLanguage: "Arapça", isTrickyLanguage: false),
        "TG": CountryFacts(continent: "Afrika", mainLanguage: "Fransızca", isTrickyLanguage: false),
        // Afrika kıyısında nadir bir Portekizce örneği.
        "CV": CountryFacts(continent: "Afrika", mainLanguage: "Portekizce", isTrickyLanguage: true),
        "EH": CountryFacts(continent: "Afrika", mainLanguage: "Arapça", isTrickyLanguage: false),
        // Afrika'da bir başka nadir Portekizce örneği.
        "ST": CountryFacts(continent: "Afrika", mainLanguage: "Portekizce", isTrickyLanguage: true),

        // MARK: Kuzey Amerika / Karayipler (ek)
        "AI": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "AG": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        // Papiamento günlük dil, resmi dillerden biri Hollandaca.
        "AW": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "Hollandaca", isTrickyLanguage: true),
        "BB": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "BM": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "VG": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "KY": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        // Papiamento günlük dil, resmi dillerden biri Hollandaca.
        "CW": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "Hollandaca", isTrickyLanguage: true),
        "DM": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "GD": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        // Danimarka'ya bağlı ama kendi Grönlandca dili var.
        "GL": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "Grönlandca", isTrickyLanguage: true),
        "GP": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "Fransızca", isTrickyLanguage: false),
        "IO": CountryFacts(continent: "Asya", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "KN": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "LC": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "MQ": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "Fransızca", isTrickyLanguage: false),
        "MS": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "BQ": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "Hollandaca", isTrickyLanguage: false),
        "BL": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "Fransızca", isTrickyLanguage: false),
        "MF": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "Fransızca", isTrickyLanguage: false),
        "SX": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "Hollandaca", isTrickyLanguage: false),
        "PM": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "Fransızca", isTrickyLanguage: false),
        // İngilizce de eş resmi dil — çoğu çocuk yalnızca İngilizce sanır.
        "PR": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İspanyolca", isTrickyLanguage: true),
        "VC": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "TT": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "TC": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "VI": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "SV": CountryFacts(continent: "Kuzey Amerika", mainLanguage: "İspanyolca", isTrickyLanguage: false),

        // MARK: Güney Amerika (ek)
        "GF": CountryFacts(continent: "Güney Amerika", mainLanguage: "Fransızca", isTrickyLanguage: false),
        "FK": CountryFacts(continent: "Güney Amerika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "GS": CountryFacts(continent: "Güney Amerika", mainLanguage: "İngilizce", isTrickyLanguage: false),

        // MARK: Antarktika / kutup bölgeleri (kalıcı nüfus yok — idari/araştırma dili)
        "AQ": CountryFacts(continent: "Antarktika", mainLanguage: "Yok", isTrickyLanguage: false),
        "BV": CountryFacts(continent: "Antarktika", mainLanguage: "Norveççe", isTrickyLanguage: false),
        "HM": CountryFacts(continent: "Antarktika", mainLanguage: "İngilizce", isTrickyLanguage: false),
        "TF": CountryFacts(continent: "Antarktika", mainLanguage: "Fransızca", isTrickyLanguage: false),
    ]

    static func facts(for code: String) -> CountryFacts? { facts[code] }
}
