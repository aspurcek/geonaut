import Foundation
func dupCount(_ codes: [String]) -> Int { codes.count - Set(codes).count }
var report: [String: (runs: Int, withDup: Int, maxDup: Int)] = [:]
var badCount = 0
var dupOptions = 0
var sameItemDup = 0
let nameToCode = Dictionary(uniqueKeysWithValues: Countries.all.map { ($0.name, $0.code) })
func rec(_ k: String, _ codes: [String]) { if codes.count != 10 { badCount += 1; print("SORU SAYISI", k, codes.count) }; var r = report[k] ?? (0,0,0); r.runs += 1; let d = dupCount(codes); if d > 0 { r.withDup += 1 }; r.maxDup = max(r.maxDup, d); report[k] = r }
let N = 40
for tour in 0..<3 { for stage in 0..<8 { for _ in 0..<N {
    for e in ContinentPathNode.order {
        let q = Countries.makeQuestions(from: Countries.pool(forContinent: e.name), isRecall: stage >= 5, tour: tour, stageIndex: stage)
        rec("Bayraklar/\(e.name)", q.map { $0.countryCode })
        let l = Languages.makeQuestions(forContinent: e.name, stageIndex: stage, tour: tour)
        rec("Diller/\(e.name)", l.map { $0.countryCode })
        for q in l { let shown = q.options.map { D($0) }; if Set(shown).count != shown.count { dupOptions += 1 } }
    }
    for s in WorldFoodStructure.sections {
        let f = WorldFoods.makeQuestions(forSection: s, stageIndex: stage, tour: tour)
        rec("Lezzetler/\(s)", f.map { $0.countryCode })
        for q in f {
            switch q.style {
            case .foodImageToCountry, .foodNameToCountryText:
                for opt in q.options where opt != q.countryName { if let c = nameToCode[opt], WorldFoods.item(for: c, type: q.foodType) == q.foodItem { sameItemDup += 1 } }
            case .foodNameToCountryFlags:
                for code in q.flagOptions where code != q.countryCode { if WorldFoods.item(for: code, type: q.foodType) == q.foodItem { sameItemDup += 1 } }
            default: break
            }
        }
    }
    rec("Haritalar/Kıtalar", MapQuizGenerator.makeQuestions(stageIndex: stage, tour: tour).map { $0.country.code })
    rec("Haritalar/Ülkeler", CountryQuizGenerator.makeQuestions(stageIndex: stage, tour: tour).map { $0.country.code })
}}}
for (k, v) in report.sorted(by: { $0.key < $1.key }) {
    print(k.padding(toLength: 28, withPad: " ", startingAt: 0), "tekrarlı test: \(v.withDup)/\(v.runs)", "en çok tekrar: \(v.maxDup)")
}
for e in ContinentPathNode.order { print("havuz", e.name, Countries.pool(forContinent: e.name).count, "zor-dil:", Languages.trickyPool(forContinent: e.name).count) }
print("yemek havuzu", WorldFoods.imageCoveredCountries.count)

print("10 sorudan az/çok çıkan test:", badCount)

print("Diller: gösterilen şık tekrarı olan soru:", dupOptions)
print("Lezzetler: doğru ülkeyle aynı yemek adına sahip yanlış şık sayısı:", sameItemDup)
