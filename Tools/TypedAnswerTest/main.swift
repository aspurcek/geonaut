import Foundation

var failures = 0
func expect(_ input: String, _ code: String, _ want: TypedAnswer.Verdict) {
    let got = TypedAnswer.check(input, code: code)
    if got != want { failures += 1; print("HATA  \"\(input)\" → \(code): beklenen \(want), gelen \(got)") }
}

// Tam doğru: Türkçe, büyük/küçük harf, Türkçe karakter yok, diğer diller, kısaltmalar.
expect("Arjantin", "AR", .exact)
expect("arjantin", "AR", .exact)
expect("  ARJANTİN ", "AR", .exact)
expect("Argentina", "AR", .exact)
expect("Argentinien", "AR", .exact)
expect("turkiye", "TR", .exact)
expect("Türkiye", "TR", .exact)
expect("Turkey", "TR", .exact)
expect("isvicre", "CH", .exact)
expect("ABD", "US", .exact)
expect("amerika", "US", .exact)
expect("Amerika Birleşik Devletleri", "US", .exact)
expect("Birleşik Krallık", "GB", .exact)
expect("ingiltere", "GB", .exact)
expect("Holland", "NL", .exact)
expect("bosna-hersek", "BA", .exact)
expect("Kongo", "CD", .exact)
expect("Kongo", "CG", .exact)
expect("Güney Kore", "KR", .exact)
expect("Germany", "DE", .exact)
expect("Deutschland", "DE", .exact)
expect("Alemania", "DE", .exact)

// Küçük yazım hataları kabul.
expect("Arjantn", "AR", .closeEnough)
expect("Arjentin", "AR", .closeEnough)
expect("Brezilay", "BR", .closeEnough)
expect("Avustrlya", "AU", .closeEnough)
expect("Japonia", "JP", .closeEnough)

// Başka ülke ya da çok farklı yazım: yanlış.
expect("Avusturya", "AU", .wrong)   // Avustralya sorusunda Avusturya
expect("Avustralya", "AT", .wrong)
expect("Nijer", "NG", .wrong)       // Nijerya sorusunda Nijer
expect("Nijerya", "NE", .wrong)
expect("Kuzey Kore", "KR", .wrong)
expect("Gine", "GN", .exact)
expect("Gine", "GW", .wrong)
expect("Iran", "IQ", .wrong)        // Irak sorusunda İran
expect("Irak", "IR", .wrong)
expect("Şili", "CN", .wrong)
expect("Mali", "ML", .exact)
expect("Malta", "ML", .wrong)
expect("", "AR", .wrong)
expect("a", "AR", .wrong)
expect("Brezilya", "AR", .wrong)
expect("Arj", "AR", .wrong)

// Belirsiz yazım hatası: iki ülkeye de 1 uzaklıkta olan yazım kabul edilmez.
for c in Countries.uniqueByCode(Countries.all) {
    // Her ülkenin kendi adı kendisine tam doğru olmalı, başka hiçbir ülkeye doğru sayılmamalı.
    if TypedAnswer.check(c.turkishName, code: c.code) != .exact { failures += 1; print("KENDİ ADI KABUL EDİLMEDİ", c.code, c.turkishName) }
}
var crossAccepted = 0
let all = Countries.uniqueByCode(Countries.all)
for a in all { for b in all where a.code != b.code {
    if TypedAnswer.check(a.turkishName, code: b.code) != .wrong {
        // Aynı adı paylaşanlar (ör. alias "Kongo") hariç gerçek çakışma.
        crossAccepted += 1; print("ÇAKIŞMA: \(a.turkishName) yazınca \(b.code) doğru sayıldı")
    }
}}

// Yazılı soru üretimi: Karışık'ta 2/3 yazılı soru, ilk soru hiç yazılı değil, diğer bölümlerde hiç yok.
var genFail = 0
var foodStagesWithoutTyped = 0
for stage in 0..<8 { for _ in 0..<200 {
    let n = Countries.typedQuestionCount(section: "Karışık", stageIndex: stage)
    let qs = Countries.makeQuestions(from: Countries.pool(forContinent: "Karışık"), isRecall: stage >= 5, stageIndex: stage, typedCount: n)
    let typed = qs.filter { $0.direction == .typeName }
    if typed.count != n || qs.first?.direction == .typeName { genFail += 1 }
    if typed.contains(where: { !TypedAnswer.isTypeable(Country(code: $0.countryCode, name: $0.countryName)) }) { genFail += 1 }
    let other = Countries.makeQuestions(from: Countries.pool(forContinent: "Avrupa"), isRecall: stage >= 5, stageIndex: stage, typedCount: Countries.typedQuestionCount(section: "Avrupa", stageIndex: stage))
    if other.contains(where: { $0.direction == .typeName }) { genFail += 1 }
}}

// Başkentler.
func expectCap(_ input: String, _ code: String, _ want: TypedAnswer.Verdict) {
    let got = TypedAnswer.check(input, key: code, kind: .capital)
    if got != want { failures += 1; print("BAŞKENT HATA  \"\(input)\" → \(code): beklenen \(want), gelen \(got)") }
}
expectCap("Buenos Aires", "AR", .exact)
expectCap("buenosaires", "AR", .exact)
expectCap("Ankara", "TR", .exact)
expectCap("Viyana", "AT", .exact)
expectCap("Vienna", "AT", .exact)
expectCap("Wien", "AT", .exact)
expectCap("Pekin", "CN", .exact)
expectCap("Beijing", "CN", .exact)
expectCap("Washington", "US", .exact)
expectCap("Ankra", "TR", .closeEnough)
expectCap("Canbera", "AU", .closeEnough)
expectCap("Sidney", "AU", .wrong)
expectCap("İstanbul", "TR", .wrong)
expectCap("Viyana", "DE", .wrong)
expectCap("Berlin", "AT", .wrong)
for code in Capitals.codes {
    guard let n = Capitals.names[code] else { continue }
    for name in [n.tr, n.en, n.de, n.es] where TypedAnswer.check(name, key: code, kind: .capital) != .exact {
        failures += 1; print("BAŞKENT KENDİ ADI KABUL EDİLMEDİ", code, name)
    }
}

// Diller.
func expectLang(_ input: String, _ lang: String, _ want: TypedAnswer.Verdict) {
    let got = TypedAnswer.check(input, key: lang, kind: .language)
    if got != want { failures += 1; print("DİL HATA  \"\(input)\" → \(lang): beklenen \(want), gelen \(got)") }
}
expectLang("İspanyolca", "İspanyolca", .exact)
expectLang("ispanyolca", "İspanyolca", .exact)
expectLang("Spanish", "İspanyolca", .exact)
expectLang("Español", "İspanyolca", .exact)
expectLang("Ispanyolca", "İspanyolca", .exact)
expectLang("İspanyolac", "İspanyolca", .closeEnough)
expectLang("Portekizce", "İspanyolca", .wrong)
expectLang("Hollandaca", "Flamanca", .exact)
expectLang("Flamanca", "Hollandaca", .exact)
expectLang("Yunanca", "Rumca", .exact)
expectLang("Svahili", "Kiswahili", .exact)
expectLang("Azerice", "Azerbaycan Türkçesi", .exact)
expectLang("Türkçe", "Azerbaycan Türkçesi", .wrong)
expectLang("Malayca", "Maltaca", .wrong)
expectLang("Arapça", "Farsça", .wrong)
for lang in Set(CountryData.facts.values.map(\.mainLanguage)).subtracting(["Yok"]) where TypedAnswer.check(lang, key: lang, kind: .language) != .exact {
    failures += 1; print("DİL KENDİ ADI KABUL EDİLMEDİ", lang)
}

// Üretim: Başkentler / Diller / Lezzetler Karışık.
for stage in 0..<8 { for _ in 0..<100 {
    let n = TypedAnswer.questionCount(section: "Karışık", stageIndex: stage)
    let caps = Capitals.makeQuestions(forContinent: "Karışık", stageIndex: stage, typedCount: n)
    let ct = caps.filter(\.typed)
    if ct.count != n || caps.first?.typed == true || ct.contains(where: { $0.format != .flagWithNameToCapital || !TypedAnswer.isCapitalTypeable($0.countryCode) }) { genFail += 1; print("BAŞKENT ÜRETİM", stage, ct.count) }
    let langs = Languages.makeQuestions(forContinent: "Karışık", stageIndex: stage, typedCount: n)
    let lt = langs.filter(\.typed)
    if lt.count != n || langs.first?.typed == true || lt.contains(where: { !TypedAnswer.isLanguageTypeable($0.correctLanguage) }) { genFail += 1; print("DİL ÜRETİM", stage, lt.count) }
    let foods = WorldFoods.makeQuestions(forSection: "Karışık", stageIndex: stage, typedCount: n)
    let ft = foods.filter(\.typed)
    if ft.count > n || foods.first?.typed == true || ft.contains(where: { ![.foodImageToCountry, .foodNameToCountryText, .foodNameToCountryFlags].contains($0.style) }) { genFail += 1; print("LEZZET ÜRETİM", stage, ft.count) }
    if stage == 0 && ft.isEmpty { foodStagesWithoutTyped += 1 }
    for other in ["Avrupa", "Asya"] {
        if Capitals.makeQuestions(forContinent: other, stageIndex: stage, typedCount: TypedAnswer.questionCount(section: other, stageIndex: stage)).contains(where: \.typed) { genFail += 1 }
    }
    if WorldFoods.makeQuestions(forSection: "Yemekler", stageIndex: stage, typedCount: TypedAnswer.questionCount(section: "Yemekler", stageIndex: stage)).contains(where: \.typed) { genFail += 1 }
}}
var typedFoodCounts: [Int: Int] = [:]
for stage in 0..<8 { var total = 0; for _ in 0..<50 { total += WorldFoods.makeQuestions(forSection: "Karışık", stageIndex: stage, typedCount: TypedAnswer.questionCount(section: "Karışık", stageIndex: stage)).filter(\.typed).count }; typedFoodCounts[stage] = total / 50 }
print("Lezzetler Karışık seviye başına ortalama yazılı soru:", typedFoodCounts.sorted { $0.key < $1.key }.map { "\($0.key + 1)=\($0.value)" }.joined(separator: " "))

print("Hatalı beklenti: \(failures), ülke çakışması: \(crossAccepted), üretim hatası: \(genFail)")
exit(failures + crossAccepted + genFail == 0 ? 0 : 1)
