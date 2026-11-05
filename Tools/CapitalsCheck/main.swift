import Foundation
var fails = 0
func check(_ c: Bool, _ m: String) { if !c { print("FAIL:", m); fails += 1 } }

// 1) Veri bütünlüğü
let allCodes = Set(Countries.all.map(\.code))
check(Capitals.names.keys.allSatisfy { allCodes.contains($0) }, "Her başkent kodu Countries.all'da var")
check(!Capitals.has("IL"), "İsrail Başkentler'de yok")
check(!allCodes.contains("IL"), "İsrail Countries.all'da yok")
for (code, n) in Capitals.names {
    check(!n.tr.isEmpty && !n.en.isEmpty && !n.de.isEmpty && !n.es.isEmpty, "\(code): 4 dilde başkent adı dolu")
}
let missingCoordinates = Capitals.codes.filter { CountryCoordinates.coordinate(for: $0) == nil }
print("Haritası gösterilemeyen başkentli ülke:", missingCoordinates.count, missingCoordinates.prefix(10))
check(missingCoordinates.isEmpty, "Başkentli her ülkenin harita koordinatı var (Karışık harita soruları için)")

// 2) Tüm kıta × etap × tur için soru üretimi
let continents = FlagGuessStructure.continents + ["Karışık"]
var total = 0
for continent in continents {
    for tour in 0..<TourStructure.count {
        for stage in 0..<CapitalStructure.stagesPerSection {
            let qs = Capitals.makeQuestions(forContinent: continent, stageIndex: stage, tour: tour)
            total += qs.count
            let tag = "\(continent) tur\(tour + 1) etap\(stage + 1)"
            check(qs.count == GameRules.questionsPerStage, "\(tag): 10 soru (\(qs.count))")
            check(Set(qs.map(\.countryCode)).count == qs.count, "\(tag): aynı ülke tekrar etmiyor")
            for q in qs {
                check(q.kind == .capital, "\(tag): soru türü başkent")
                check(q.options.count == 4 && Set(q.options).count == 4, "\(tag) \(q.countryCode): 4 farklı şık \(q.options)")
                check(q.options.contains(q.correctLanguage), "\(tag) \(q.countryCode): doğru cevap şıklarda")
                check(q.correctLanguage == Capitals.name(for: q.countryCode), "\(tag) \(q.countryCode): doğru cevap o ülkenin başkenti")
                check(Capitals.has(q.countryCode), "\(tag): soru ülkesinin başkenti var")
                check(q.countryCode != "IL", "\(tag): İsrail sorulmuyor")
                if q.stimulus == .map { check(CountryCoordinates.coordinate(for: q.countryCode) != nil, "\(tag) \(q.countryCode): harita sorusunun koordinatı var") }
                if stage < 6 { check(q.stimulus == .flag, "\(tag): etap 1-6 yalnızca bayrak") }
            }
        }
    }
}
print("Üretilen toplam soru:", total)
print(fails == 0 ? "TÜMÜ GEÇTİ" : "\(fails) HATA")
exit(fails == 0 ? 0 : 1)
