import Foundation
import Observation

/// 1.0.3 — oyuncunun her gün geri gelmesi için: günlük hedef (doğru cevap sayısı), 3 günlük görev,
/// seri koruyucu ve soru içi kombo (üst üste doğru). Bkz. Notion Kararlar Günlüğü 13 Kasım 2026.
///
/// - Veriler yalnızca BU CİHAZDA, hesaba göre ayrı tutulur (UserDefaults). CloudKit şeması
///   değişmez; "veri toplamıyoruz" taahhüdü aynen geçerli.
/// - Günlük sayaçlar cihazın yerel gününe göre gece yarısı sıfırlanır. Okuma tarafı her zaman
///   bugüne göre hesaplar (`today(now:)`), böylece uygulama gece yarısı açık kalsa da dünün
///   sayıları bugünün gibi görünmez.
/// - Hedef PUAN değil DOĞRU CEVAP sayar: tamamlanmış bir seviyeyi tekrar oynamak puan vermez
///   (bkz. GameProgress.pointsToAward), ama pratik yapmak günlük hedefe yine sayılmalı.
/// - Misafir modunda (`activate(accountKey: nil)`) hiçbir şey kaydedilmez ve arayüz gizlenir.
@Observable
final class DailyEngagement {
    static let shared = DailyEngagement()

    static let goalOptions = [10, 20, 40]
    static let defaultGoal = 20
    static let maxFreezes = 2
    static let comboHighlightThreshold = 3

    enum Quest: String, CaseIterable, Codable, Identifiable {
        case dailyGoal, twoStages, perfectStage, comboFive, threeStars
        var id: String { rawValue }

        var icon: String {
            switch self {
            case .dailyGoal: "target"
            case .twoStages: "flag.checkered"
            case .perfectStage: "checkmark.seal.fill"
            case .comboFive: "flame.fill"
            case .threeStars: "star.fill"
            }
        }

        var title: String {
            switch self {
            case .dailyGoal: L("Günlük hedefini tamamla")
            case .twoStages: L("2 seviye bitir")
            case .perfectStage: L("Hatasız bir seviye bitir")
            case .comboFive: L("Üst üste 5 doğru cevap ver")
            case .threeStars: L("Bir seviyeyi 3 yıldızla bitir")
            }
        }
    }

    /// Bir günün durumu (okuma için; değiştirilemez kopya).
    struct Day: Equatable {
        var correct = 0
        var stages = 0
        var perfectStages = 0
        var threeStarStages = 0
        var bestCombo = 0
        var goal = DailyEngagement.defaultGoal
        var freezes = 0
        var questsRewarded = false
        var quests: [Quest] = []

        var goalReached: Bool { correct >= goal }

        func target(_ quest: Quest) -> Int {
            switch quest {
            case .dailyGoal: goal
            case .twoStages: 2
            case .perfectStage, .threeStars: 1
            case .comboFive: 5
            }
        }

        func progress(_ quest: Quest) -> Int {
            let value: Int
            switch quest {
            case .dailyGoal: value = correct
            case .twoStages: value = stages
            case .perfectStage: value = perfectStages
            case .comboFive: value = bestCombo
            case .threeStars: value = threeStarStages
            }
            return min(value, target(quest))
        }

        func isDone(_ quest: Quest) -> Bool { progress(quest) >= target(quest) }
        var questsDone: Int { quests.filter(isDone).count }
        var allQuestsDone: Bool { !quests.isEmpty && questsDone == quests.count }
    }

    /// Bir seviye bitince "Seviye Tamamlandı" ekranında gösterilecek günlük haberler.
    struct StageEvents: Equatable {
        var goalReached = false
        var questsCompleted = false
        /// Görevler bitti ama seri koruyucu zaten en fazla sayıdaydı → yeni koruyucu verilmedi.
        var freezeAwarded = false
        var isEmpty: Bool { !goalReached && !questsCompleted }
    }

    /// Diskte saklanan ham durum.
    private struct Stored: Codable {
        var day = ""
        var correct = 0
        var stages = 0
        var perfectStages = 0
        var threeStarStages = 0
        var bestCombo = 0
        var goal = DailyEngagement.defaultGoal
        var freezes = 0
        var goalCelebrated = false
        var questsRewarded = false
        /// Gerçekleşmiş ama henüz gösterilmemiş haberler (bkz. takeStageEvents).
        var pendingGoal = false
        var pendingQuests = false
        var pendingFreezeAwarded = false

        init() {}

        /// Sonradan eklenen alanlar eski kayıtları bozmasın diye her alan isteğe bağlı okunur.
        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            day = try c.decodeIfPresent(String.self, forKey: .day) ?? ""
            correct = try c.decodeIfPresent(Int.self, forKey: .correct) ?? 0
            stages = try c.decodeIfPresent(Int.self, forKey: .stages) ?? 0
            perfectStages = try c.decodeIfPresent(Int.self, forKey: .perfectStages) ?? 0
            threeStarStages = try c.decodeIfPresent(Int.self, forKey: .threeStarStages) ?? 0
            bestCombo = try c.decodeIfPresent(Int.self, forKey: .bestCombo) ?? 0
            goal = try c.decodeIfPresent(Int.self, forKey: .goal) ?? DailyEngagement.defaultGoal
            freezes = try c.decodeIfPresent(Int.self, forKey: .freezes) ?? 0
            goalCelebrated = try c.decodeIfPresent(Bool.self, forKey: .goalCelebrated) ?? false
            questsRewarded = try c.decodeIfPresent(Bool.self, forKey: .questsRewarded) ?? false
            pendingGoal = try c.decodeIfPresent(Bool.self, forKey: .pendingGoal) ?? false
            pendingQuests = try c.decodeIfPresent(Bool.self, forKey: .pendingQuests) ?? false
            pendingFreezeAwarded = try c.decodeIfPresent(Bool.self, forKey: .pendingFreezeAwarded) ?? false
            if !DailyEngagement.goalOptions.contains(goal) { goal = DailyEngagement.defaultGoal }
            freezes = min(max(freezes, 0), DailyEngagement.maxFreezes)
        }
    }

    private var stored = Stored()
    /// nil: misafir modu / çıkış yapılmış — kayıt yok, arayüz gizli.
    private(set) var accountKey: String?
    /// Bu seviyedeki üst üste doğru sayısı (kaydedilmez).
    private(set) var combo = 0
    /// Son biten seviyenin haberleri — "Seviye Tamamlandı" ekranı okur. Yeni seviye başlayınca temizlenir.
    private(set) var lastStageEvents: StageEvents?

    var isActive: Bool { accountKey != nil }

    private let defaults: UserDefaults?
    private var calendar: Calendar

    init(defaults: UserDefaults? = .standard, calendar: Calendar = .current) {
        self.defaults = defaults
        self.calendar = calendar
    }

    private static func storageKey(_ account: String) -> String { "geonaut.daily.v1.\(account)" }

    // MARK: Hesap

    /// Giriş/çıkışta çağrılır. Aynı hesap için tekrar çağrılırsa bellekteki durumu korur.
    func activate(accountKey: String?) {
        guard accountKey != self.accountKey else { return }
        self.accountKey = accountKey
        combo = 0
        lastStageEvents = nil
        stored = Stored()
        guard let accountKey, let defaults,
              let data = defaults.data(forKey: Self.storageKey(accountKey)),
              let decoded = try? JSONDecoder().decode(Stored.self, from: data) else { return }
        stored = decoded
    }

    private func save() {
        guard let accountKey, let defaults, let data = try? JSONEncoder().encode(stored) else { return }
        defaults.set(data, forKey: Self.storageKey(accountKey))
    }

    // MARK: Gün

    func dayKey(_ date: Date) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04ld-%02ld-%02ld", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    /// Görev seçimi için sabit bir referanstan bu yana geçen gün sayısı (herkeste aynı gün aynı görevler).
    private func dayNumber(_ date: Date) -> Int {
        let reference = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)) ?? .distantPast
        return calendar.dateComponents([.day], from: calendar.startOfDay(for: reference), to: calendar.startOfDay(for: date)).day ?? 0
    }

    /// Her gün: günlük hedef + 4 görevden 2'si. "Hatasız" ve "3 yıldız" aynı güne düşmez (biri diğerini kapsar).
    func quests(for date: Date) -> [Quest] {
        let pairs: [(Quest, Quest)] = [
            (.twoStages, .perfectStage), (.twoStages, .comboFive), (.twoStages, .threeStars),
            (.perfectStage, .comboFive), (.comboFive, .threeStars),
        ]
        let n = dayNumber(date)
        let index = ((n % pairs.count) + pairs.count) % pairs.count
        return [.dailyGoal, pairs[index].0, pairs[index].1]
    }

    /// Bugünün durumu. Kayıt dünden kalmışsa günlük sayaçlar sıfır görünür (hedef ve koruyucular korunur).
    func today(now: Date = .now) -> Day {
        let isToday = stored.day == dayKey(now)
        var day = Day(goal: stored.goal, freezes: stored.freezes, quests: quests(for: now))
        if isToday {
            day.correct = stored.correct
            day.stages = stored.stages
            day.perfectStages = stored.perfectStages
            day.threeStarStages = stored.threeStarStages
            day.bestCombo = stored.bestCombo
            day.questsRewarded = stored.questsRewarded
        }
        return day
    }

    private func rollIfNeeded(_ now: Date) {
        let key = dayKey(now)
        guard stored.day != key else { return }
        let goal = stored.goal, freezes = stored.freezes
        stored = Stored()
        stored.day = key
        stored.goal = goal
        stored.freezes = freezes
    }

    /// Hedefe ulaşıldı mı / görevler bitti mi — ödülü HEMEN verir, haberi gösterilene kadar bekletir.
    private func evaluate(_ now: Date) {
        let day = today(now: now)
        if day.goalReached && !stored.goalCelebrated {
            stored.goalCelebrated = true
            stored.pendingGoal = true
        }
        if day.allQuestsDone && !stored.questsRewarded {
            stored.questsRewarded = true
            stored.pendingQuests = true
            if stored.freezes < Self.maxFreezes {
                stored.freezes += 1
                stored.pendingFreezeAwarded = true
            }
        }
    }

    // MARK: Oyun olayları

    /// Her cevapta (tüm kategoriler) çağrılır. Dönüş: güncel kombo (yanlışsa 0).
    /// `isFirstQuestion`: seviyenin ilk sorusu — önceki seviyeden kalan kombo ve haberler sıfırlanır.
    @discardableResult
    func recordAnswer(isCorrect: Bool, isFirstQuestion: Bool, now: Date = .now) -> Int {
        if isFirstQuestion {
            combo = 0
            lastStageEvents = nil
        }
        combo = isCorrect ? combo + 1 : 0
        guard isActive else { return combo }
        rollIfNeeded(now)
        if isCorrect {
            stored.correct += 1
            stored.bestCombo = max(stored.bestCombo, combo)
        }
        evaluate(now)
        save()
        return combo
    }

    /// Bir seviye tamamlanınca (bkz. HomeView.commitStage). Dönen haberler aynı zamanda `lastStageEvents`'e yazılır.
    @discardableResult
    func recordStageCompleted(correct: Int, total: Int, now: Date = .now) -> StageEvents {
        guard isActive else {
            lastStageEvents = nil
            return StageEvents()
        }
        rollIfNeeded(now)
        stored.stages += 1
        if total > 0 && correct >= total { stored.perfectStages += 1 }
        if GameRules.stars(correctCount: correct) == 3 { stored.threeStarStages += 1 }
        evaluate(now)
        let events = takePendingEvents()
        save()
        lastStageEvents = events
        return events
    }

    private func takePendingEvents() -> StageEvents {
        let events = StageEvents(goalReached: stored.pendingGoal, questsCompleted: stored.pendingQuests, freezeAwarded: stored.pendingFreezeAwarded)
        stored.pendingGoal = false
        stored.pendingQuests = false
        stored.pendingFreezeAwarded = false
        return events
    }

    /// Günlük sayfa açılınca: oyuncu durumu orada zaten görüyor, bekleyen haberler bir daha gösterilmez.
    func markEventsSeen(now: Date = .now) {
        guard isActive else { return }
        rollIfNeeded(now)
        evaluate(now)
        _ = takePendingEvents()
        save()
    }

    func setGoal(_ goal: Int, now: Date = .now) {
        guard isActive, Self.goalOptions.contains(goal), goal != stored.goal else { return }
        rollIfNeeded(now)
        stored.goal = goal
        // Yeni hedef bugün zaten aşılmışsa kutlama bir kez daha çıkmasın diye "gösterildi" sayılır.
        if today(now: now).goalReached { stored.goalCelebrated = true }
        evaluate(now)
        stored.pendingGoal = false
        stored.pendingQuests = false
        stored.pendingFreezeAwarded = false
        save()
    }

    /// "Hesabımı Sil": bu hesabın cihazdaki günlük kaydını da siler.
    func deleteStoredData(accountKey: String) {
        defaults?.removeObject(forKey: Self.storageKey(accountKey))
        if self.accountKey == accountKey { stored = Stored() }
    }

    #if DEBUG
    /// Yalnızca geliştirme ekranı: diske yazmadan bir günü oynanmış gibi doldurur (hedef + görevler tamam haberi).
    func debugSimulateDay(freezesBefore: Int) {
        accountKey = "debug-screen"
        stored = Stored()
        stored.freezes = freezesBefore
        stored.goal = 10
        for round in 0..<3 {
            for i in 0..<10 { recordAnswerInMemory(isCorrect: true, isFirstQuestion: i == 0) }
            if round < 2 { stored.stages += 1; stored.perfectStages += 1; stored.threeStarStages += 1 }
        }
        stored.stages += 1; stored.perfectStages += 1; stored.threeStarStages += 1
        evaluate(.now)
        lastStageEvents = takePendingEvents()
    }

    /// Yalnızca geliştirme ekranı: günlük kartın görünümünü test etmek için bellekte bir gün kurar (diske yazmaz).
    func debugSetDay(correct: Int, goal: Int, freezes: Int, stages: Int, perfect: Int = 0) {
        accountKey = "debug-screen"
        stored = Stored()
        stored.day = dayKey(.now)
        stored.goal = goal
        stored.freezes = freezes
        stored.correct = correct
        stored.stages = stages
        stored.perfectStages = perfect
        stored.threeStarStages = perfect
        stored.bestCombo = min(correct, 4)
    }

    private func recordAnswerInMemory(isCorrect: Bool, isFirstQuestion: Bool) {
        if isFirstQuestion { combo = 0 }
        combo = isCorrect ? combo + 1 : 0
        rollIfNeeded(.now)
        if isCorrect { stored.correct += 1; stored.bestCombo = max(stored.bestCombo, combo) }
    }

    func debugSetFreezes(_ count: Int) {
        stored.freezes = min(max(count, 0), Self.maxFreezes)
        save()
    }
    #endif

    // MARK: Seri koruyucu

    /// `missedDays` gün oynanmadıysa koruyucular yeter mi?
    func canCover(missedDays: Int) -> Bool {
        isActive && missedDays >= 1 && stored.freezes >= missedDays
    }

    /// Yeterliyse koruyucuları harcar ve true döner; yetmiyorsa hiçbirini harcamaz.
    func consumeFreezes(_ missedDays: Int) -> Bool {
        guard canCover(missedDays: missedDays) else { return false }
        stored.freezes -= missedDays
        save()
        return true
    }
}

#if DEBUG
extension DailyEngagement {
    /// Yalnızca geliştirme: kuralları bellek içi bir örnekle doğrular (`-debugDailyCheck 1`, çıktı konsola).
    static func debugSelfCheck() {
        var fails = 0
        func check(_ ok: Bool, _ message: String) { print(ok ? "DAILYCHECK ok:" : "DAILYCHECK FAIL:", message); if !ok { fails += 1 } }
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Europe/Istanbul")!
        func date(_ d: Int, _ h: Int = 12) -> Date { cal.date(from: DateComponents(year: 2026, month: 11, day: d, hour: h))! }

        let e = DailyEngagement(defaults: nil, calendar: cal)
        e.recordAnswer(isCorrect: true, isFirstQuestion: true, now: date(13))
        check(e.today(now: date(13)).correct == 0, "misafir (hesap yok): sayaç tutulmaz")
        e.activate(accountKey: "test")
        check(e.today(now: date(13)).goal == 20 && e.today(now: date(13)).freezes == 0, "varsayılan hedef 20, koruyucu 0")

        // Kombo
        var c = 0
        for i in 0..<4 { c = e.recordAnswer(isCorrect: true, isFirstQuestion: i == 0, now: date(13)) }
        check(c == 4, "4 doğru -> kombo 4")
        c = e.recordAnswer(isCorrect: false, isFirstQuestion: false, now: date(13))
        check(c == 0, "yanlış -> kombo 0")
        c = e.recordAnswer(isCorrect: true, isFirstQuestion: true, now: date(13))
        check(c == 1, "yeni seviye -> kombo baştan")
        check(e.today(now: date(13)).correct == 5 && e.today(now: date(13)).bestCombo == 4, "doğru 5, en iyi kombo 4")

        // Görev seçimi: her gün günlük hedef + 2 farklı görev, hatasız + 3 yıldız aynı gün yok
        var allValid = true
        for d in 1...30 {
            let q = e.quests(for: date(d))
            if q.count != 3 || q[0] != .dailyGoal || Set(q).count != 3 || (q.contains(.perfectStage) && q.contains(.threeStars)) { allValid = false }
        }
        check(allValid, "30 gün: görev seçimi geçerli")
        check(e.quests(for: date(13, 1)) == e.quests(for: date(13, 23)), "gün içinde görevler sabit")

        // Hedef + görevleri tamamla -> koruyucu
        let f = DailyEngagement(defaults: nil, calendar: cal)
        f.activate(accountKey: "t2")
        f.setGoal(10, now: date(13))
        var events = DailyEngagement.StageEvents()
        for round in 0..<3 {
            for i in 0..<10 { f.recordAnswer(isCorrect: true, isFirstQuestion: i == 0, now: date(13)) }
            events = f.recordStageCompleted(correct: 10, total: 10, now: date(13))
            if round == 0 { check(events.goalReached, "ilk seviye: hedef (10) tamam haberi") }
        }
        let day = f.today(now: date(13))
        check(day.allQuestsDone, "3 hatasız seviye -> bugünün tüm görevleri tamam (\(day.quests.map(\.rawValue)))")
        check(day.freezes == 1, "görevler -> 1 seri koruyucu")
        events = f.recordStageCompleted(correct: 10, total: 10, now: date(13))
        check(events.isEmpty, "aynı gün tekrar: haber yok, çift ödül yok")
        check(f.today(now: date(13)).freezes == 1, "koruyucu hâlâ 1")

        // Ertesi gün: sayaçlar sıfır, hedef ve koruyucu korunur
        let next = f.today(now: date(14))
        check(next.correct == 0 && next.stages == 0 && next.goal == 10 && next.freezes == 1, "gece yarısı: sayaçlar sıfır, hedef/koruyucu korunur")

        // Koruyucu üst sınırı (2)
        for d in 14...16 {
            for _ in 0..<3 {
                for i in 0..<10 { f.recordAnswer(isCorrect: true, isFirstQuestion: i == 0, now: date(d)) }
                f.recordStageCompleted(correct: 10, total: 10, now: date(d))
            }
        }
        check(f.today(now: date(16)).freezes == 2, "koruyucu en fazla 2")

        // Harcama
        check(!f.canCover(missedDays: 3), "3 gün kaçırma: 2 koruyucu yetmez")
        check(!f.consumeFreezes(3) && f.today(now: date(16)).freezes == 2, "yetmezse hiç harcanmaz")
        check(f.consumeFreezes(1) && f.today(now: date(16)).freezes == 1, "1 gün kaçırma: 1 koruyucu harcanır")

        // Kalıcılık
        let suite = UserDefaults(suiteName: "geonaut.dailycheck")!
        suite.removePersistentDomain(forName: "geonaut.dailycheck")
        let p1 = DailyEngagement(defaults: suite, calendar: cal)
        p1.activate(accountKey: "persist")
        p1.setGoal(40, now: date(13))
        p1.recordAnswer(isCorrect: true, isFirstQuestion: true, now: date(13))
        let p2 = DailyEngagement(defaults: suite, calendar: cal)
        p2.activate(accountKey: "persist")
        check(p2.today(now: date(13)).goal == 40 && p2.today(now: date(13)).correct == 1, "kayıt: hedef ve sayaç diske yazılır")
        p2.activate(accountKey: "other")
        check(p2.today(now: date(13)).correct == 0 && p2.today(now: date(13)).goal == 20, "başka hesap: ayrı kayıt")
        suite.removePersistentDomain(forName: "geonaut.dailycheck")

        print("DAILYCHECK done fails=\(fails)")
    }
}
#endif
