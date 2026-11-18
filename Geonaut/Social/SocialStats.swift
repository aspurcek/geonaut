import Foundation

/// Düello ve arkadaşlık sayaçları — rozetler, ödüller ve haftalık sıralama puanı buradan.
/// Cihazda, Game Center oyuncusu başına saklanır (DailyEngagement gibi; iCloud şeması değişmez).
/// Ödüller yalnızca BİR KEZ verilir: maç kimliği / arkadaş kimliği kaydedilir.
@MainActor
@Observable
final class SocialStats {
    static let shared = SocialStats()

    struct Record: Codable, Equatable {
        var won = 0, lost = 0, tied = 0
        var summary: String { "\(won)G · \(lost)M" + (tied > 0 ? " · \(tied)B" : "") }
    }

    struct Stored: Codable {
        var played = 0
        var wins = 0
        var winStreak = 0
        var bestWinStreak = 0
        var rewardedMatchIDs: [String] = []
        var rewardedFriendIDs: [String] = []
        var maxFriendCount = 0
        var records: [String: Record] = [:]
        var weekStart: Date?
        var weekPoints = 0
    }

    private(set) var stored = Stored()
    private var storageKey = "geonaut.social.local"
    private let defaults = UserDefaults.standard

    /// Puan ödülü (RootTabView bağlar: ekrandaki bakiye + profile kalıcı yazım).
    var onReward: ((Int) -> Void)?

    private init() { load() }

    func activate(playerID: String) {
        let key = "geonaut.social.\(playerID)"
        guard key != storageKey else { return }
        storageKey = key
        load()
    }

    // MARK: Düello

    /// Biten düelloyu bir kez kaydeder; yeni kaydedildiyse ödülü verir ve true döner.
    @discardableResult
    func recordDuel(matchID: String, opponentID: String, outcome: DuelOutcome) -> Bool {
        guard !stored.rewardedMatchIDs.contains(matchID) else { return false }
        stored.rewardedMatchIDs.append(matchID)
        if stored.rewardedMatchIDs.count > 300 { stored.rewardedMatchIDs.removeFirst(100) }
        stored.played += 1
        var record = stored.records[opponentID] ?? Record()
        switch outcome {
        case .won:
            stored.wins += 1
            stored.winStreak += 1
            stored.bestWinStreak = max(stored.bestWinStreak, stored.winStreak)
            record.won += 1
        case .lost:
            stored.winStreak = 0
            record.lost += 1
        case .tied:
            record.tied += 1
        }
        stored.records[opponentID] = record
        save()
        onReward?(outcome.reward)
        return true
    }

    func record(with friendID: String) -> Record? { stored.records[friendID] }

    // MARK: Arkadaşlar

    /// Listede ilk kez görünen arkadaşlar için davet ödülü (en fazla DuelRules.maxRewardedFriends).
    /// Verilen toplam puanı döner.
    @discardableResult
    func registerFriends(_ ids: [String]) -> Int {
        stored.maxFriendCount = max(stored.maxFriendCount, ids.count)
        var awarded = 0
        for id in ids where !stored.rewardedFriendIDs.contains(id) {
            guard stored.rewardedFriendIDs.count < DuelRules.maxRewardedFriends else { break }
            stored.rewardedFriendIDs.append(id)
            awarded += DuelRules.friendReward
        }
        save()
        if awarded > 0 { onReward?(awarded) }
        return awarded
    }

    // MARK: Haftalık puan (Game Center "Bu hafta" sıralaması)

    /// Bu hafta (Pazartesi başlangıçlı) kazanılan puan.
    var currentWeekPoints: Int {
        guard let start = stored.weekStart, start == Self.weekStart(for: .now) else { return 0 }
        return stored.weekPoints
    }

    /// Seviyede kazanılan puanı haftalık toplama ekler, güncel haftalık toplamı döner.
    @discardableResult
    func addWeekPoints(_ points: Int) -> Int {
        guard points > 0 else { return currentWeekPoints }
        let start = Self.weekStart(for: .now)
        if stored.weekStart != start {
            stored.weekStart = start
            stored.weekPoints = 0
        }
        stored.weekPoints += points
        save()
        return stored.weekPoints
    }

    static func weekStart(for date: Date) -> Date {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        return calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? calendar.startOfDay(for: date)
    }

    // MARK: Kayıt

    private func load() {
        if let data = defaults.data(forKey: storageKey), let decoded = try? JSONDecoder().decode(Stored.self, from: data) {
            stored = decoded
        } else {
            stored = Stored()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(stored) { defaults.set(data, forKey: storageKey) }
    }

    /// "Hesabımı Sil": bu cihazdaki tüm düello/arkadaş sayaçlarını (her Game Center oyuncusu için) siler.
    func deleteAllLocalData() {
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix("geonaut.social.") {
            defaults.removeObject(forKey: key)
        }
        stored = Stored()
        storageKey = "geonaut.social.local"
    }

    #if DEBUG
    func debugReset() {
        stored = Stored()
        save()
    }
    #endif
}
