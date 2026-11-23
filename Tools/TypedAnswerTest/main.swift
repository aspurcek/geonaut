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
for stage in 0..<8 { for _ in 0..<200 {
    let n = Countries.typedQuestionCount(section: "Karışık", stageIndex: stage)
    let qs = Countries.makeQuestions(from: Countries.pool(forContinent: "Karışık"), isRecall: stage >= 5, stageIndex: stage, typedCount: n)
    let typed = qs.filter { $0.direction == .typeName }
    if typed.count != n || qs.first?.direction == .typeName { genFail += 1 }
    if typed.contains(where: { !TypedAnswer.isTypeable(Country(code: $0.countryCode, name: $0.countryName)) }) { genFail += 1 }
    let other = Countries.makeQuestions(from: Countries.pool(forContinent: "Avrupa"), isRecall: stage >= 5, stageIndex: stage, typedCount: Countries.typedQuestionCount(section: "Avrupa", stageIndex: stage))
    if other.contains(where: { $0.direction == .typeName }) { genFail += 1 }
}}

print("Hatalı beklenti: \(failures), ülke çakışması: \(crossAccepted), üretim hatası: \(genFail)")
exit(failures + crossAccepted + genFail == 0 ? 0 : 1)
