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
var localP = PlayerProfile.newPlayer(appleUserIdentifier: "x", displayName: "Geonaut")
localP.completedStageKeys = ["Tur2-Avrupa|0"]; localP.points = 120
localP.bestPointsByStage = ["Avrupa|0=60", "Tur2-Avrupa|0=90"]
let mp = localP.merging(cloud: cloudP)
check(mp.completedStageKeys == ["Avrupa|0", "Avrupa|1", "Tur2-Avrupa|0"], "Birleştirme: etap anahtarları birleşim")
check(mp.points == 300, "Birleştirme: puan maksimum")
check(mp.bestPointsByStage.contains("Avrupa|0=80") && mp.bestPointsByStage.contains("Tur2-Avrupa|0=90") && mp.bestPointsByStage.count == 2, "Birleştirme: en iyi puan maksimum")
check(mp.hasCustomAvatar && mp.avatarColorHex == 0x123456, "Birleştirme: buluttaki özel avatar varsayılan yerel avatarla ezilmiyor")
check(mp.displayName == "Ayşe", "Birleştirme: varsayılan yerel ad, buluttaki gerçek adı ezmiyor")
check(mp.streakDays == 5, "Birleştirme: daha yeni aktif günün serisi alınıyor")

// --- Haftalık seri takvimi (Profil) ---
var utc = Calendar(identifier: .gregorian); utc.timeZone = TimeZone(identifier: "UTC")!
func day(_ d: Int) -> Date { utc.date(from: DateComponents(year: 2026, month: 10, day: d, hour: 12))! }
let U = StreakWeekDay.upcoming, C = StreakWeekDay.completed, A = StreakWeekDay.active, P = StreakWeekDay.playedToday, M = StreakWeekDay.missed
// 7 Ekim 2026 = Çarşamba (hafta Pzt 5 Ekim'de başlar)
check(StreakStatus.weekDays(lastActiveDate: day(7), streakDays: 0, now: day(7), calendar: utc) == [U,U,A,U,U,U,U], "Seri yok: yalnızca bugün 'aktif'")
check(StreakStatus.weekDays(lastActiveDate: day(7), streakDays: 3, now: day(7), calendar: utc) == [C,C,P,U,U,U,U], "3 günlük seri, bugün oynandı: Pzt-Sal soluk yeşil, Çar canlı yeşil")
check(StreakStatus.weekDays(lastActiveDate: day(7), streakDays: 5, now: day(7), calendar: utc) == [C,C,P,U,U,U,U], "Seri geçen haftaya taşsa da bu hafta yalnızca geçen günler")
check(StreakStatus.weekDays(lastActiveDate: day(6), streakDays: 2, now: day(7), calendar: utc) == [C,C,A,U,U,U,U], "Dün oynandı, bugün henüz değil: bugün 'aktif'")
check(StreakStatus.weekDays(lastActiveDate: day(3), streakDays: 4, now: day(7), calendar: utc) == [M,M,A,U,U,U,U], "Seri bozulduysa: koptuktan sonra oynanmayan günler 'kaçırıldı', bugün 'aktif'")
check(StreakStatus.weekDays(lastActiveDate: day(11), streakDays: 7, now: day(11), calendar: utc) == [C,C,C,C,C,C,P], "Pazar günü 7 günlük seri: Pzt-Cmt soluk yeşil, Pazar canlı yeşil")

// --- Seviye: kazanılan toplam puan harcamayla düşmez ---
let lp = GameProgress()
check(lp.lifetimePoints == GameRules.newPlayerStartingPoints, "Yeni oyuncu: toplam kazanılan = başlangıç puanı")
_ = lp.pointsToAward(continent: "Avrupa", stageIndex: 0, earnedPoints: 80)
_ = lp.pointsToAward(continent: "Avrupa", stageIndex: 1, earnedPoints: 100)
check(lp.lifetimePoints == GameRules.newPlayerStartingPoints + 180, "Toplam kazanılan = başlangıç + etapların en iyileri")
_ = lp.pointsToAward(continent: "Avrupa", stageIndex: 0, earnedPoints: 50) // daha düşük tekrar
check(lp.lifetimePoints == GameRules.newPlayerStartingPoints + 180, "Daha düşük tekrar toplamı azaltmaz")
check(GameRules.streakBonus(forStreak: 0) == 0 && GameRules.streakBonus(forStreak: 6) == 0, "Seri 0 ve 6: bonus yok")
check(GameRules.streakBonus(forStreak: 7) == GameRules.weeklyStreakBonus, "Seri 7: haftalık bonus")
check(GameRules.streakBonus(forStreak: 8) == 0 && GameRules.streakBonus(forStreak: 13) == 0, "Seri 8 ve 13: bonus yok")
check(GameRules.streakBonus(forStreak: 14) == GameRules.weeklyStreakBonus && GameRules.streakBonus(forStreak: 21) == GameRules.weeklyStreakBonus, "Seri 14 ve 21: her hafta bonus")
print(fails == 0 ? "TÜMÜ GEÇTİ" : "\(fails) HATA")
