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
var formatCounts: [Int: Set<String>] = [:]   // etap → görülen biçimler
for continent in continents {
    for tour in 0..<TourStructure.count {
        for stage in 0..<CapitalStructure.stagesPerSection {
            let qs = Capitals.makeQuestions(forContinent: continent, stageIndex: stage, tour: tour)
            total += qs.count
            let tag = "\(continent) tur\(tour + 1) etap\(stage + 1)"
            let allowed = Capitals.formats(forStage: stage)
            check(qs.count == GameRules.questionsPerStage, "\(tag): 10 soru (\(qs.count))")
            check(Set(qs.map(\.countryCode)).count == qs.count, "\(tag): aynı ülke tekrar etmiyor")
            for q in qs {
                formatCounts[stage, default: []].insert("\(q.format)")
                // Seviye kuralı: sadece izin verilen biçimler (harita yalnızca 7-8; havuzda koordinat yoksa bayrağa düşer)
                check(allowed.contains(q.format) || q.format == .flagToCapital, "\(tag): biçim seviyeye uygun (\(q.format))")
                check(q.options.count == 4 && Set(q.options).count == 4, "\(tag) \(q.countryCode): 4 farklı şık \(q.options)")
                check(q.options.contains(q.correct), "\(tag) \(q.countryCode): doğru cevap şıklarda")
                check(Capitals.has(q.countryCode), "\(tag): soru ülkesinin başkenti var")
                check(q.countryCode != "IL", "\(tag): İsrail sorulmuyor")
                check(q.capitalName == Capitals.name(for: q.countryCode), "\(tag) \(q.countryCode): gösterilen başkent doğru")
                switch q.format {
                case .capitalToFlag:
                    check(q.correct == q.countryCode && q.options.allSatisfy { allCodes.contains($0) }, "\(tag): bayrak şıkları ülke kodu")
                case .capitalToCountry:
                    check(q.correct == q.countryName, "\(tag) \(q.countryCode): doğru ülke adı")
                default:
                    check(q.correct == q.capitalName, "\(tag) \(q.countryCode): doğru cevap o ülkenin başkenti")
                }
                if q.format == .mapToCapital { check(CountryCoordinates.coordinate(for: q.countryCode) != nil, "\(tag) \(q.countryCode): harita koordinatı var") }
            }
        }
    }
}
// Seviye bazlı beklenen biçimler
check(formatCounts[0] == ["flagWithNameToCapital"] && formatCounts[1] == ["flagWithNameToCapital"], "Seviye 1-2: yalnızca bayrak + ülke adı")
check(formatCounts[2] == ["capitalToCountry", "capitalToFlag"], "Seviye 3: başkent adı → ülke adı ya da bayrak")
check(formatCounts[3] == ["flagToCapital"], "Seviye 4: yalnızca bayrak")
check((formatCounts[4] ?? []).count == 4 && (formatCounts[5] ?? []).count == 4, "Seviye 5-6: 4 biçim karışık")
check((formatCounts[6] ?? []).contains("mapToCapital") && (formatCounts[7] ?? []).contains("mapToCapital"), "Seviye 7-8: harita da var")
check(!(formatCounts[4] ?? []).contains("mapToCapital"), "Seviye 5-6: harita yok")
print("Üretilen toplam soru:", total, " etap başına biçimler:", formatCounts.sorted { $0.key < $1.key }.map { "\($0.key + 1)=\($0.value.sorted())" })
print(fails == 0 ? "TÜMÜ GEÇTİ" : "\(fails) HATA")
exit(fails == 0 ? 0 : 1)
