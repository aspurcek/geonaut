import Foundation
var fails = 0
func check(_ c: Bool, _ m: String) { if !c { print("FAIL:", m); fails += 1 } else { print("ok:", m) } }

func completeFlags(_ p: GameProgress, tour: Int) {
    for e in ContinentPathNode.order { for i in 0..<FlagGuessStructure.stagesPerSection { p.markStageCompleted(continent: TourStructure.progressKey(e.name, tour: tour), stageIndex: i) } }
}
func completeMaps(_ p: GameProgress, tour: Int) {
    for i in 0..<8 { p.markStageCompleted(continent: TourStructure.progressKey(MapPuzzleStructure.progressKey, tour: tour), stageIndex: i) }
    for i in 0..<8 { p.markStageCompleted(continent: TourStructure.progressKey(CountryPuzzleStructure.progressKey, tour: tour), stageIndex: i) }
}
let p = GameProgress()
check(p.isTourUnlocked(.flags, tour: 0), "Tur 1 hep açık")
check(!p.isTourUnlocked(.flags, tour: 1), "Tur 2 başta kilitli")
check(!p.isMapPuzzleCategoryCompleted(), "Haritalar başta kilitli (Bayraklar Tur 1 bitmedi)")
completeFlags(p, tour: 0)
check(p.isFlagGuessCategoryCompleted(), "Bayraklar Tur 1 bitti -> sonraki kategori açılır")
check(p.isTourUnlocked(.flags, tour: 1), "Tur 1 bitince Tur 2 açılır")
check(!p.isTourUnlocked(.flags, tour: 2), "Tur 2 bitmeden Tur 3 kilitli")
check(!p.isCategoryTrophyEarned(.flags), "Tur 1 ile kupa yok")
completeFlags(p, tour: 1)
check(p.isTourUnlocked(.flags, tour: 2), "Tur 2 bitince Tur 3 açılır")
check(!p.isCategoryTrophyEarned(.flags), "Tur 2 ile kupa yok")
completeFlags(p, tour: 2)
check(p.isCategoryTrophyEarned(.flags), "3 tur bitince kupa")
// eski anahtarlar
check(TourStructure.progressKey("Avrupa", tour: 0) == "Avrupa", "Tur 1 anahtarı eskisiyle aynı")
check(TourStructure.progressKey("Avrupa", tour: 1) == "Tur2-Avrupa", "Tur 2 anahtarı")
// export/import round trip
let keys = p.completedStageKeysExport
let q = GameProgress(completedStageKeys: keys)
check(q.isCategoryTrophyEarned(.flags), "Dışa/içe aktarmadan sonra ilerleme korunuyor (\(keys.count) anahtar)")
check(keys.contains("Tur2-Avrupa|0") && keys.contains("Avrupa|0"), "Anahtar biçimi kıta|etap")
// Maps need both sections
let m = GameProgress()
for i in 0..<8 { m.markStageCompleted(continent: MapPuzzleStructure.progressKey, stageIndex: i) }
check(!m.isMapPuzzleCategoryCompleted(), "Haritalar: sadece Kıtalar yetmez")
completeMaps(m, tour: 0)
check(m.isMapPuzzleCategoryCompleted(), "Haritalar Tur 1: Kıtalar+Ülkeler")
check(ContinentPathNode.mapPuzzleTracksPath(progress: m, tour: 1)[1].state == .locked, "Tur 2'de Ülkeler Kıtalar bitmeden kilitli")
check(ContinentPathNode.flagGuessPath(progress: p, tour: 2).allSatisfy { $0.state == .completed }, "Yol Tur 3 tamamlandı")
check(ContinentPathNode.flagGuessPath(progress: GameProgress(), tour: 1)[0].state == .active, "Boş Tur 2: Avrupa aktif")
// pencere: turlar arası farklılık
let codes = Countries.europe.map { $0.code }
let w0 = TourStructure.preferredCodes(codes, tour: 0, stageIndex: 0)
let w1 = TourStructure.preferredCodes(codes, tour: 1, stageIndex: 0)
let w2 = TourStructure.preferredCodes(codes, tour: 2, stageIndex: 0)
check(w0.count == 10 && w1.count == 10 && w2.count == 10, "Pencere 10 ülke (havuz \(codes.count))")
check(w0.isDisjoint(with: w1) && w1.isDisjoint(with: w2) && w0.isDisjoint(with: w2), "Aynı etap, 3 tur: ülkeler birbirinden farklı")
for tour in 0..<3 {
    let qs = Countries.makeQuestions(from: Countries.europe, isRecall: false, tour: tour, stageIndex: 0)
    let pw = TourStructure.preferredCodes(codes, tour: tour, stageIndex: 0)
    check(qs.count == 10 && Set(qs.map { $0.countryCode }).count == 10 && Set(qs.map { $0.countryCode }).isSubset(of: pw), "Tur \(tour+1) Etap 1: 10 farklı soru, hepsi o turun penceresinden")
}
// küçük havuz
let anta = Countries.makeQuestions(from: Countries.antarctica, isRecall: true, tour: 1, stageIndex: 3)
check(anta.count == 10, "Küçük havuz (\(Countries.antarctica.count) ülke) 10 soru üretiyor")
// --- Profil birleştirme (internetsiz oynama + bulut) ---
var cloudP = PlayerProfile.newPlayer(appleUserIdentifier: "x", displayName: "Ayşe")
cloudP.completedStageKeys = ["Avrupa|0", "Avrupa|1"]; cloudP.points = 300
cloudP.hasCustomAvatar = true; cloudP.avatarColorHex = 0x123456
cloudP.bestPointsByStage = ["Avrupa|0=80"]; cloudP.streakDays = 5
cloudP.lastActiveDate = Date().addingTimeInterval(1000)
var localP = PlayerProfile.newPlayer(appleUserIdentifier: "x", displayName: "Kaşif")
localP.completedStageKeys = ["Tur2-Avrupa|0"]; localP.points = 120
localP.bestPointsByStage = ["Avrupa|0=60", "Tur2-Avrupa|0=90"]
let mp = localP.merging(cloud: cloudP)
check(mp.completedStageKeys == ["Avrupa|0", "Avrupa|1", "Tur2-Avrupa|0"], "Birleştirme: etap anahtarları birleşim")
check(mp.points == 300, "Birleştirme: puan maksimum")
check(mp.bestPointsByStage.contains("Avrupa|0=80") && mp.bestPointsByStage.contains("Tur2-Avrupa|0=90") && mp.bestPointsByStage.count == 2, "Birleştirme: en iyi puan maksimum")
check(mp.hasCustomAvatar && mp.avatarColorHex == 0x123456, "Birleştirme: buluttaki özel avatar varsayılan yerel avatarla ezilmiyor")
check(mp.displayName == "Ayşe", "Birleştirme: varsayılan yerel ad, buluttaki gerçek adı ezmiyor")
check(mp.streakDays == 5, "Birleştirme: daha yeni aktif günün serisi alınıyor")
print(fails == 0 ? "TÜMÜ GEÇTİ" : "\(fails) HATA")
