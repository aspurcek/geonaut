import Foundation

/// Bir ülkenin başkentinin dört uygulama dilindeki yazılışı. Soru/şık karşılaştırmaları ÜLKE KODUYLA
/// yapılır; ekrana yalnızca `Capitals.name(for:)` ile o anki dilde yazılmış hâli basılır.
struct CapitalName {
    let tr: String
    let en: String
    let de: String
    let es: String
}

/// Başkentler kategorisinin verisi — 180 ülke.
///
/// Kapsam kararı (kullanıcı: "belirsizleri şimdilik hariç tut"): yalnızca başkenti tartışmasız olan
/// bağımsız devletler. Dışarıda bırakılanlar: başkenti birden fazla ya da tartışmalı olanlar
/// (Bolivya, Güney Afrika, Sri Lanka, Esvatini, Benin, Burundi, Yemen, İsrail, Filistin, Nauru),
/// tanınma sorunu olanlar (Tayvan, Kosova), ülke adıyla aynı olan şehir devletleri (Singapur, Monako,
/// Lüksemburg, San Marino, Vatikan) ve bağımsız olmayan bölgeler/Antarktika.
enum Capitals {
    static let names: [String: CapitalName] = [
        "AD": CapitalName(tr: "Andorra la Vella", en: "Andorra la Vella", de: "Andorra la Vella", es: "Andorra la Vella"),
        "AE": CapitalName(tr: "Abu Dabi", en: "Abu Dhabi", de: "Abu Dhabi", es: "Abu Dabi"),
        "AF": CapitalName(tr: "Kabil", en: "Kabul", de: "Kabul", es: "Kabul"),
        "AG": CapitalName(tr: "Saint John's", en: "Saint John's", de: "Saint John's", es: "Saint John's"),
        "AL": CapitalName(tr: "Tiran", en: "Tirana", de: "Tirana", es: "Tirana"),
        "AM": CapitalName(tr: "Erivan", en: "Yerevan", de: "Jerewan", es: "Ereván"),
        "AO": CapitalName(tr: "Luanda", en: "Luanda", de: "Luanda", es: "Luanda"),
        "AR": CapitalName(tr: "Buenos Aires", en: "Buenos Aires", de: "Buenos Aires", es: "Buenos Aires"),
        "AT": CapitalName(tr: "Viyana", en: "Vienna", de: "Wien", es: "Viena"),
        "AU": CapitalName(tr: "Canberra", en: "Canberra", de: "Canberra", es: "Canberra"),
        "AZ": CapitalName(tr: "Bakü", en: "Baku", de: "Baku", es: "Bakú"),
        "BA": CapitalName(tr: "Saraybosna", en: "Sarajevo", de: "Sarajevo", es: "Sarajevo"),
        "BB": CapitalName(tr: "Bridgetown", en: "Bridgetown", de: "Bridgetown", es: "Bridgetown"),
        "BD": CapitalName(tr: "Dakka", en: "Dhaka", de: "Dhaka", es: "Daca"),
        "BE": CapitalName(tr: "Brüksel", en: "Brussels", de: "Brüssel", es: "Bruselas"),
        "BF": CapitalName(tr: "Vagadugu", en: "Ouagadougou", de: "Ouagadougou", es: "Uagadugú"),
        "BG": CapitalName(tr: "Sofya", en: "Sofia", de: "Sofia", es: "Sofía"),
        "BH": CapitalName(tr: "Manama", en: "Manama", de: "Manama", es: "Manama"),
        "BN": CapitalName(tr: "Bandar Seri Begawan", en: "Bandar Seri Begawan", de: "Bandar Seri Begawan", es: "Bandar Seri Begawan"),
        "BR": CapitalName(tr: "Brasília", en: "Brasília", de: "Brasília", es: "Brasilia"),
        "BS": CapitalName(tr: "Nassau", en: "Nassau", de: "Nassau", es: "Nassau"),
        "BT": CapitalName(tr: "Thimphu", en: "Thimphu", de: "Thimphu", es: "Timbu"),
        "BW": CapitalName(tr: "Gaborone", en: "Gaborone", de: "Gaborone", es: "Gaborone"),
        "BY": CapitalName(tr: "Minsk", en: "Minsk", de: "Minsk", es: "Minsk"),
        "BZ": CapitalName(tr: "Belmopan", en: "Belmopan", de: "Belmopan", es: "Belmopan"),
        "CA": CapitalName(tr: "Ottawa", en: "Ottawa", de: "Ottawa", es: "Ottawa"),
        "CD": CapitalName(tr: "Kinşasa", en: "Kinshasa", de: "Kinshasa", es: "Kinsasa"),
        "CF": CapitalName(tr: "Bangui", en: "Bangui", de: "Bangui", es: "Bangui"),
        "CG": CapitalName(tr: "Brazavil", en: "Brazzaville", de: "Brazzaville", es: "Brazzaville"),
        "CH": CapitalName(tr: "Bern", en: "Bern", de: "Bern", es: "Berna"),
        "CI": CapitalName(tr: "Yamusukro", en: "Yamoussoukro", de: "Yamoussoukro", es: "Yamusukro"),
        "CL": CapitalName(tr: "Santiago", en: "Santiago", de: "Santiago", es: "Santiago"),
        "CM": CapitalName(tr: "Yaunde", en: "Yaoundé", de: "Yaoundé", es: "Yaundé"),
        "CN": CapitalName(tr: "Pekin", en: "Beijing", de: "Peking", es: "Pekín"),
        "CO": CapitalName(tr: "Bogota", en: "Bogotá", de: "Bogotá", es: "Bogotá"),
        "CR": CapitalName(tr: "San José", en: "San José", de: "San José", es: "San José"),
        "CU": CapitalName(tr: "Havana", en: "Havana", de: "Havanna", es: "La Habana"),
        "CV": CapitalName(tr: "Praia", en: "Praia", de: "Praia", es: "Praia"),
        "CY": CapitalName(tr: "Lefkoşa", en: "Nicosia", de: "Nikosia", es: "Nicosia"),
        "CZ": CapitalName(tr: "Prag", en: "Prague", de: "Prag", es: "Praga"),
        "DE": CapitalName(tr: "Berlin", en: "Berlin", de: "Berlin", es: "Berlín"),
        "DJ": CapitalName(tr: "Cibuti", en: "Djibouti", de: "Djibouti", es: "Yibuti"),
        "DK": CapitalName(tr: "Kopenhag", en: "Copenhagen", de: "Kopenhagen", es: "Copenhague"),
        "DM": CapitalName(tr: "Roseau", en: "Roseau", de: "Roseau", es: "Roseau"),
        "DO": CapitalName(tr: "Santo Domingo", en: "Santo Domingo", de: "Santo Domingo", es: "Santo Domingo"),
        "DZ": CapitalName(tr: "Cezayir", en: "Algiers", de: "Algier", es: "Argel"),
        "EC": CapitalName(tr: "Quito", en: "Quito", de: "Quito", es: "Quito"),
        "EE": CapitalName(tr: "Tallinn", en: "Tallinn", de: "Tallinn", es: "Tallinn"),
        "EG": CapitalName(tr: "Kahire", en: "Cairo", de: "Kairo", es: "El Cairo"),
        "ER": CapitalName(tr: "Asmara", en: "Asmara", de: "Asmara", es: "Asmara"),
        "ES": CapitalName(tr: "Madrid", en: "Madrid", de: "Madrid", es: "Madrid"),
        "ET": CapitalName(tr: "Addis Ababa", en: "Addis Ababa", de: "Addis Ababa", es: "Adís Abeba"),
        "FI": CapitalName(tr: "Helsinki", en: "Helsinki", de: "Helsinki", es: "Helsinki"),
        "FJ": CapitalName(tr: "Suva", en: "Suva", de: "Suva", es: "Suva"),
        "FM": CapitalName(tr: "Palikir", en: "Palikir", de: "Palikir", es: "Palikir"),
        "FR": CapitalName(tr: "Paris", en: "Paris", de: "Paris", es: "Paris"),
        "GA": CapitalName(tr: "Libreville", en: "Libreville", de: "Libreville", es: "Libreville"),
        "GB": CapitalName(tr: "Londra", en: "London", de: "London", es: "Londres"),
        "GD": CapitalName(tr: "Saint George's", en: "Saint George's", de: "Saint George's", es: "Saint George's"),
        "GE": CapitalName(tr: "Tiflis", en: "Tbilisi", de: "Tbilisi", es: "Tiflis"),
        "GH": CapitalName(tr: "Accra", en: "Accra", de: "Accra", es: "Accra"),
        "GM": CapitalName(tr: "Banjul", en: "Banjul", de: "Banjul", es: "Banjul"),
        "GN": CapitalName(tr: "Konakri", en: "Conakry", de: "Conakry", es: "Conakri"),
        "GQ": CapitalName(tr: "Malabo", en: "Malabo", de: "Malabo", es: "Malabo"),
        "GR": CapitalName(tr: "Atina", en: "Athens", de: "Athen", es: "Atenas"),
        "GT": CapitalName(tr: "Guatemala", en: "Guatemala City", de: "Guatemala-Stadt", es: "Ciudad de Guatemala"),
        "GW": CapitalName(tr: "Bissau", en: "Bissau", de: "Bissau", es: "Bisáu"),
        "GY": CapitalName(tr: "Georgetown", en: "Georgetown", de: "Georgetown", es: "Georgetown"),
        "HN": CapitalName(tr: "Tegucigalpa", en: "Tegucigalpa", de: "Tegucigalpa", es: "Tegucigalpa"),
        "HR": CapitalName(tr: "Zagreb", en: "Zagreb", de: "Zagreb", es: "Zagreb"),
        "HT": CapitalName(tr: "Port-o-Prens", en: "Port-au-Prince", de: "Port-au-Prince", es: "Puerto Príncipe"),
        "HU": CapitalName(tr: "Budapeşte", en: "Budapest", de: "Budapest", es: "Budapest"),
        "ID": CapitalName(tr: "Cakarta", en: "Jakarta", de: "Jakarta", es: "Yakarta"),
        "IE": CapitalName(tr: "Dublin", en: "Dublin", de: "Dublin", es: "Dublin"),
        "IN": CapitalName(tr: "Yeni Delhi", en: "New Delhi", de: "Neu-Delhi", es: "Nueva Delhi"),
        "IQ": CapitalName(tr: "Bağdat", en: "Baghdad", de: "Bagdad", es: "Bagdad"),
        "IR": CapitalName(tr: "Tahran", en: "Tehran", de: "Teheran", es: "Teherán"),
        "IS": CapitalName(tr: "Reykjavik", en: "Reykjavík", de: "Reykjavik", es: "Reikiavik"),
        "IT": CapitalName(tr: "Roma", en: "Rome", de: "Rom", es: "Roma"),
        "JM": CapitalName(tr: "Kingston", en: "Kingston", de: "Kingston", es: "Kingston"),
        "JO": CapitalName(tr: "Amman", en: "Amman", de: "Amman", es: "Amán"),
        "JP": CapitalName(tr: "Tokyo", en: "Tokyo", de: "Tokio", es: "Tokio"),
        "KE": CapitalName(tr: "Nairobi", en: "Nairobi", de: "Nairobi", es: "Nairobi"),
        "KG": CapitalName(tr: "Bişkek", en: "Bishkek", de: "Bischkek", es: "Biskek"),
        "KH": CapitalName(tr: "Pnom Pen", en: "Phnom Penh", de: "Phnom Penh", es: "Nom Pen"),
        "KI": CapitalName(tr: "Tarawa", en: "Tarawa", de: "Tarawa", es: "Tarawa"),
        "KM": CapitalName(tr: "Moroni", en: "Moroni", de: "Moroni", es: "Moroni"),
        "KN": CapitalName(tr: "Basseterre", en: "Basseterre", de: "Basseterre", es: "Basseterre"),
        "KP": CapitalName(tr: "Pyongyang", en: "Pyongyang", de: "Pyongyang", es: "Pyongyang"),
        "KR": CapitalName(tr: "Seul", en: "Seoul", de: "Seoul", es: "Seúl"),
        "KW": CapitalName(tr: "Kuveyt", en: "Kuwait City", de: "Kuwait-Stadt", es: "Ciudad de Kuwait"),
        "KZ": CapitalName(tr: "Astana", en: "Astana", de: "Astana", es: "Astaná"),
        "LA": CapitalName(tr: "Vientiyan", en: "Vientiane", de: "Vientiane", es: "Vientián"),
        "LB": CapitalName(tr: "Beyrut", en: "Beirut", de: "Beirut", es: "Beirut"),
        "LC": CapitalName(tr: "Castries", en: "Castries", de: "Castries", es: "Castries"),
        "LI": CapitalName(tr: "Vaduz", en: "Vaduz", de: "Vaduz", es: "Vaduz"),
        "LR": CapitalName(tr: "Monrovia", en: "Monrovia", de: "Monrovia", es: "Monrovia"),
        "LS": CapitalName(tr: "Maseru", en: "Maseru", de: "Maseru", es: "Maseru"),
        "LT": CapitalName(tr: "Vilnius", en: "Vilnius", de: "Vilnius", es: "Vilnius"),
        "LV": CapitalName(tr: "Riga", en: "Riga", de: "Riga", es: "Riga"),
        "LY": CapitalName(tr: "Trablus", en: "Tripoli", de: "Tripolis", es: "Trípoli"),
        "MA": CapitalName(tr: "Rabat", en: "Rabat", de: "Rabat", es: "Rabat"),
        "MD": CapitalName(tr: "Kişinev", en: "Chișinău", de: "Chișinău", es: "Chisináu"),
        "ME": CapitalName(tr: "Podgorica", en: "Podgorica", de: "Podgorica", es: "Podgorica"),
        "MG": CapitalName(tr: "Antananarivo", en: "Antananarivo", de: "Antananarivo", es: "Antananarivo"),
        "MH": CapitalName(tr: "Majuro", en: "Majuro", de: "Majuro", es: "Majuro"),
        "MK": CapitalName(tr: "Üsküp", en: "Skopje", de: "Skopje", es: "Skopje"),
        "ML": CapitalName(tr: "Bamako", en: "Bamako", de: "Bamako", es: "Bamako"),
        "MM": CapitalName(tr: "Naypyidaw", en: "Naypyidaw", de: "Naypyidaw", es: "Naipyidó"),
        "MN": CapitalName(tr: "Ulan Batur", en: "Ulaanbaatar", de: "Ulaanbaatar", es: "Ulán Bator"),
        "MR": CapitalName(tr: "Nuakşot", en: "Nouakchott", de: "Nouakchott", es: "Nuakchot"),
        "MT": CapitalName(tr: "Valletta", en: "Valletta", de: "Valletta", es: "La Valeta"),
        "MU": CapitalName(tr: "Port Louis", en: "Port Louis", de: "Port Louis", es: "Port Louis"),
        "MV": CapitalName(tr: "Male", en: "Malé", de: "Malé", es: "Malé"),
        "MW": CapitalName(tr: "Lilongwe", en: "Lilongwe", de: "Lilongwe", es: "Lilongüe"),
        "MX": CapitalName(tr: "Meksiko", en: "Mexico City", de: "Mexiko-Stadt", es: "Ciudad de México"),
        "MY": CapitalName(tr: "Kuala Lumpur", en: "Kuala Lumpur", de: "Kuala Lumpur", es: "Kuala Lumpur"),
        "MZ": CapitalName(tr: "Maputo", en: "Maputo", de: "Maputo", es: "Maputo"),
        "NA": CapitalName(tr: "Vindhuk", en: "Windhoek", de: "Windhoek", es: "Windhoek"),
        "NE": CapitalName(tr: "Niyame", en: "Niamey", de: "Niamey", es: "Niamey"),
        "NG": CapitalName(tr: "Abuja", en: "Abuja", de: "Abuja", es: "Abuya"),
        "NI": CapitalName(tr: "Managua", en: "Managua", de: "Managua", es: "Managua"),
        "NL": CapitalName(tr: "Amsterdam", en: "Amsterdam", de: "Amsterdam", es: "Amsterdam"),
        "NO": CapitalName(tr: "Oslo", en: "Oslo", de: "Oslo", es: "Oslo"),
        "NP": CapitalName(tr: "Katmandu", en: "Kathmandu", de: "Kathmandu", es: "Katmandú"),
        "NZ": CapitalName(tr: "Wellington", en: "Wellington", de: "Wellington", es: "Wellington"),
        "OM": CapitalName(tr: "Maskat", en: "Muscat", de: "Maskat", es: "Mascate"),
        "PA": CapitalName(tr: "Panama", en: "Panama City", de: "Panama-Stadt", es: "Ciudad de Panamá"),
        "PE": CapitalName(tr: "Lima", en: "Lima", de: "Lima", es: "Lima"),
        "PG": CapitalName(tr: "Port Moresby", en: "Port Moresby", de: "Port Moresby", es: "Port Moresby"),
        "PH": CapitalName(tr: "Manila", en: "Manila", de: "Manila", es: "Manila"),
        "PK": CapitalName(tr: "İslamabad", en: "Islamabad", de: "Islamabad", es: "Islamabad"),
        "PL": CapitalName(tr: "Varşova", en: "Warsaw", de: "Warschau", es: "Varsovia"),
        "PT": CapitalName(tr: "Lizbon", en: "Lisbon", de: "Lissabon", es: "Lisboa"),
        "PW": CapitalName(tr: "Ngerulmud", en: "Ngerulmud", de: "Ngerulmud", es: "Ngerulmud"),
        "PY": CapitalName(tr: "Asunción", en: "Asunción", de: "Asunción", es: "Asunción"),
        "QA": CapitalName(tr: "Doha", en: "Doha", de: "Doha", es: "Doha"),
        "RO": CapitalName(tr: "Bükreş", en: "Bucharest", de: "Bukarest", es: "Bucarest"),
        "RS": CapitalName(tr: "Belgrad", en: "Belgrade", de: "Belgrad", es: "Belgrado"),
        "RU": CapitalName(tr: "Moskova", en: "Moscow", de: "Moskau", es: "Moscú"),
        "RW": CapitalName(tr: "Kigali", en: "Kigali", de: "Kigali", es: "Kigali"),
        "SA": CapitalName(tr: "Riyad", en: "Riyadh", de: "Riad", es: "Riad"),
        "SB": CapitalName(tr: "Honiara", en: "Honiara", de: "Honiara", es: "Honiara"),
        "SC": CapitalName(tr: "Victoria", en: "Victoria", de: "Victoria", es: "Victoria"),
        "SD": CapitalName(tr: "Hartum", en: "Khartoum", de: "Khartum", es: "Jartum"),
        "SE": CapitalName(tr: "Stokholm", en: "Stockholm", de: "Stockholm", es: "Estocolmo"),
        "SI": CapitalName(tr: "Ljubljana", en: "Ljubljana", de: "Ljubljana", es: "Liubliana"),
        "SK": CapitalName(tr: "Bratislava", en: "Bratislava", de: "Bratislava", es: "Bratislava"),
        "SL": CapitalName(tr: "Freetown", en: "Freetown", de: "Freetown", es: "Freetown"),
        "SN": CapitalName(tr: "Dakar", en: "Dakar", de: "Dakar", es: "Dakar"),
        "SO": CapitalName(tr: "Mogadişu", en: "Mogadishu", de: "Mogadishu", es: "Mogadiscio"),
        "SR": CapitalName(tr: "Paramaribo", en: "Paramaribo", de: "Paramaribo", es: "Paramaribo"),
        "SS": CapitalName(tr: "Juba", en: "Juba", de: "Juba", es: "Yuba"),
        "ST": CapitalName(tr: "São Tomé", en: "São Tomé", de: "São Tomé", es: "Santo Tomé"),
        "SV": CapitalName(tr: "San Salvador", en: "San Salvador", de: "San Salvador", es: "San Salvador"),
        "SY": CapitalName(tr: "Şam", en: "Damascus", de: "Damaskus", es: "Damasco"),
        "TD": CapitalName(tr: "Ncamena", en: "N'Djamena", de: "N'Djamena", es: "Yamena"),
        "TG": CapitalName(tr: "Lomé", en: "Lomé", de: "Lomé", es: "Lomé"),
        "TH": CapitalName(tr: "Bangkok", en: "Bangkok", de: "Bangkok", es: "Bangkok"),
        "TJ": CapitalName(tr: "Duşanbe", en: "Dushanbe", de: "Duschanbe", es: "Dusambé"),
        "TL": CapitalName(tr: "Dili", en: "Dili", de: "Dili", es: "Dili"),
        "TM": CapitalName(tr: "Aşkabat", en: "Ashgabat", de: "Aschgabat", es: "Asjabad"),
        "TN": CapitalName(tr: "Tunus", en: "Tunis", de: "Tunis", es: "Túnez"),
        "TO": CapitalName(tr: "Nukuʻalofa", en: "Nukuʻalofa", de: "Nukuʻalofa", es: "Nukuʻalofa"),
        "TR": CapitalName(tr: "Ankara", en: "Ankara", de: "Ankara", es: "Ankara"),
        "TT": CapitalName(tr: "Port of Spain", en: "Port of Spain", de: "Port of Spain", es: "Port of Spain"),
        "TV": CapitalName(tr: "Funafuti", en: "Funafuti", de: "Funafuti", es: "Funafuti"),
        "TZ": CapitalName(tr: "Dodoma", en: "Dodoma", de: "Dodoma", es: "Dodoma"),
        "UA": CapitalName(tr: "Kiev", en: "Kyiv", de: "Kiew", es: "Kiev"),
        "UG": CapitalName(tr: "Kampala", en: "Kampala", de: "Kampala", es: "Kampala"),
        "US": CapitalName(tr: "Washington, D.C.", en: "Washington, D.C.", de: "Washington, D.C.", es: "Washington, D.C."),
        "UY": CapitalName(tr: "Montevideo", en: "Montevideo", de: "Montevideo", es: "Montevideo"),
        "UZ": CapitalName(tr: "Taşkent", en: "Tashkent", de: "Taschkent", es: "Taskent"),
        "VC": CapitalName(tr: "Kingstown", en: "Kingstown", de: "Kingstown", es: "Kingstown"),
        "VE": CapitalName(tr: "Karakas", en: "Caracas", de: "Caracas", es: "Caracas"),
        "VN": CapitalName(tr: "Hanoi", en: "Hanoi", de: "Hanoi", es: "Hanói"),
        "VU": CapitalName(tr: "Port Vila", en: "Port Vila", de: "Port Vila", es: "Port Vila"),
        "WS": CapitalName(tr: "Apia", en: "Apia", de: "Apia", es: "Apia"),
        "ZM": CapitalName(tr: "Lusaka", en: "Lusaka", de: "Lusaka", es: "Lusaka"),
        "ZW": CapitalName(tr: "Harare", en: "Harare", de: "Harare", es: "Harare"),
    ]

    /// Başkenti olan ülke kodları (alfabetik).
    static var codes: [String] { names.keys.sorted() }

    static func has(_ code: String) -> Bool { names[code] != nil }

    /// Uygulamanın o anki dilinde başkent adı (TR/EN/DE/ES dışındaki dillerde İngilizce).
    static func name(for code: String) -> String {
        guard let n = names[code] else { return "" }
        switch Bundle.main.preferredLocalizations.first ?? "tr" {
        case "tr": return n.tr
        case "de": return n.de
        case "es": return n.es
        default: return n.en
        }
    }
}

// MARK: - Soru üretimi

extension Capitals {
    /// "Başkentleri Öğren" listesi: başkenti olan ülkeler (Türkçe ada göre alfabetik, bkz. Countries.all).
    static var learnableCountries: [Country] {
        Countries.uniqueByCode(Countries.all).filter { has($0.code) }
    }

    /// Bir kıta/bölüm havuzu: o kıtanın başkenti olan ülkeleri. Havuz boşsa (olası değil ama güvenli) tüm dünyaya düşer.
    static func pool(forContinent continent: String) -> [Country] {
        let base = Countries.uniqueByCode(Countries.pool(forContinent: continent)).filter { has($0.code) }
        return base.isEmpty ? learnableCountries : base
    }

    /// Bir seviyede (0 tabanlı) hangi soru biçimleri çıkar — kullanıcı kararı:
    /// 1-2 bayrak + ülke adı → başkent; 3 başkent adı → ülke adı ya da bayrak; 4 yalnızca bayrak → başkent;
    /// 5-8 hepsinin karışımı (harita sorusu dahil).
    static func formats(forStage stageIndex: Int) -> [CapitalQuestion.Format] {
        switch stageIndex {
        case 0, 1: return [.flagWithNameToCapital]
        case 2: return [.capitalToCountry, .capitalToFlag]
        case 3: return [.flagToCapital]
        default: return [.flagWithNameToCapital, .flagToCapital, .capitalToCountry, .capitalToFlag, .mapToCapital]
        }
    }

    /// Bir etap için 10 soru üretir. Şıklar GÖSTERİLEN yazılışa göre tekilleştirilir (farklı ülkelerin başkenti
    /// bir dilde aynı yazılabilir).
    static func makeQuestions(forContinent continent: String, stageIndex: Int, tour: Int = 0) -> [CapitalQuestion] {
        let formats = formats(forStage: stageIndex)
        let fullPool = pool(forContinent: continent)
        let mapPool = fullPool.filter { CountryCoordinates.coordinate(for: $0.code) != nil }
        let world = learnableCountries
        let preferred = TourStructure.preferredCodes(fullPool.map(\.code), tour: tour, stageIndex: stageIndex)

        var usedCodes: Set<String> = []
        var result: [CapitalQuestion] = []
        for _ in 0..<GameRules.questionsPerStage {
            let format = formats.randomElement() ?? .flagToCapital
            let needsMap = format == .mapToCapital && !mapPool.isEmpty
            let effectiveFormat: CapitalQuestion.Format = (format == .mapToCapital && !needsMap) ? .flagToCapital : format

            var chosen: Country?
            for candidatePool in [needsMap ? mapPool : fullPool, fullPool, world] {
                let eligible = candidatePool.filter { !usedCodes.contains($0.code) && (!needsMap || CountryCoordinates.coordinate(for: $0.code) != nil) }
                if let pick = TourStructure.pick(eligible, code: \.code, preferred: preferred) { chosen = pick; break }
            }
            guard let correct = chosen ?? fullPool.randomElement() else { continue }
            usedCodes.insert(correct.code)

            let capital = name(for: correct.code)
            let others = world.filter { $0.code != correct.code }.shuffled()
            var options: [String]
            var answer: String
            switch effectiveFormat {
            case .capitalToFlag:
                answer = correct.code
                options = [correct.code] + others.prefix(3).map(\.code)
            case .capitalToCountry:
                answer = correct.turkishName
                var seen: Set<String> = [D(correct.turkishName)]
                var names: [String] = []
                for other in others where seen.insert(D(other.turkishName)).inserted {
                    names.append(other.turkishName)
                    if names.count == 3 { break }
                }
                options = [correct.turkishName] + names
            default:
                answer = capital
                var seen: Set<String> = [capital]
                var names: [String] = []
                for other in others {
                    let otherCapital = name(for: other.code)
                    if seen.insert(otherCapital).inserted { names.append(otherCapital) }
                    if names.count == 3 { break }
                }
                options = [capital] + names
            }

            result.append(CapitalQuestion(
                format: effectiveFormat, countryCode: correct.code, countryName: correct.turkishName,
                capitalName: capital, options: options.shuffled(), correct: answer
            ))
        }
        return result
    }
}
