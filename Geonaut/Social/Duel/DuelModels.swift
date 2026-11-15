import Foundation

/// Düello (kullanıcı kararı 2026-11-14/15, Figma FLOW12 node 1119:23343):
/// Game Center sıra tabanlı maçı ile iki arkadaş, ikisinin de TAMAMLADIĞI kategorilerden aynı
/// 10 soruyu sırayla çözer. Önce doğru sayısı, eşitse toplam süre kazandırır. Can/pas yok,
/// soru başına 15 saniye. Kazanana +20, oynayana +5 puan.

enum DuelRules {
    static let questionCount = 10
    static let secondsPerQuestion = 15
    static let winReward = 20
    static let playReward = 5
    /// Arkadaş 3 gün içinde oynamazsa davet/sıra düşer (Game Center sıra zaman aşımı).
    static let turnTimeout: TimeInterval = 3 * 24 * 60 * 60
    /// Davet ödülü: listeye ilk kez gelen her arkadaş için, en fazla bu kadar arkadaşa.
    static let friendReward = 25
    static let maxRewardedFriends = 10
}

/// Bir oyuncunun maça yazılan kartı — karşı taraf avatarı ve adı bununla görür.
struct DuelPlayerInfo: Codable, Equatable {
    let id: String
    let name: String
    let avatarColorHex: UInt32
    let character: AvatarCharacter
}

/// Tek düello sorusu. Seçenekler ham anahtarlardır (ülke kodu / başkent için ülke kodu /
/// dil adı / kıta adı); ekranda her cihaz kendi diline göre gösterir.
struct DuelQuestion: Codable, Hashable {
    enum Kind: String, Codable {
        case flag       // bayrak → ülke
        case capital    // ülke → başkent (seçenekler ülke kodu, başkent adı gösterilir)
        case language   // ülke → ana dil
        case food       // yemek → ülke
        case continent  // ülke → kıta (Haritalar)
    }

    let kind: Kind
    /// Sorulan ülke.
    let code: String
    let options: [String]
    let answer: String
}

/// Bir oyuncunun bu düellodaki sonucu.
struct DuelResult: Codable, Equatable {
    var answers: [Bool]
    /// Toplam cevaplama süresi (ms). Cevaplanmayan/süresi dolan soru tam süre sayılır.
    var totalMilliseconds: Int
    var correct: Int { answers.filter { $0 }.count }
}

/// Game Center maç verisi (match data) — iki cihaz arasında taşınan her şey.
struct DuelMatchData: Codable {
    var version = 1
    var challenger: DuelPlayerInfo
    /// Davet edenin Tur 1'ini bitirdiği kategoriler (TourCategory anahtarları).
    var challengerCategories: [String]
    var opponent: DuelPlayerInfo?
    var questions: [DuelQuestion] = []
    /// Oyuncu kimliğine (gamePlayerID) göre sonuçlar.
    var results: [String: DuelResult] = [:]

    func encoded() -> Data { (try? JSONEncoder().encode(self)) ?? Data() }
    static func decode(_ data: Data?) -> DuelMatchData? {
        guard let data, !data.isEmpty else { return nil }
        return try? JSONDecoder().decode(DuelMatchData.self, from: data)
    }
}

enum DuelOutcome: Equatable {
    case won, lost, tied

    /// Önce doğru sayısı, eşitse daha kısa toplam süre kazanır; o da eşitse berabere.
    static func compare(mine: DuelResult, theirs: DuelResult) -> DuelOutcome {
        if mine.correct != theirs.correct { return mine.correct > theirs.correct ? .won : .lost }
        if mine.totalMilliseconds != theirs.totalMilliseconds { return mine.totalMilliseconds < theirs.totalMilliseconds ? .won : .lost }
        return .tied
    }

    var reward: Int { self == .won ? DuelRules.winReward : DuelRules.playReward }
}

extension TourCategory {
    /// Maç verisinde taşınan kararlı anahtar.
    var duelKey: String {
        switch self {
        case .flags: "flags"
        case .maps: "maps"
        case .languages: "languages"
        case .foods: "foods"
        case .capitals: "capitals"
        }
    }

    init?(duelKey: String) {
        guard let match = TourCategory.allCases.first(where: { $0.duelKey == duelKey }) else { return nil }
        self = match
    }

    var duelTitle: String {
        switch self {
        case .flags: "Bayraklar"
        case .maps: "Haritalar"
        case .languages: "Diller"
        case .foods: "Lezzetler"
        case .capitals: "Başkentler"
        }
    }
}

extension GameProgress {
    /// Tur 1'i bitirilmiş kategoriler — düello soru havuzu bunların kesişiminden çıkar.
    var duelCategories: [String] {
        TourCategory.allCases.filter { isCategoryCompleted($0, tour: 0) }.map(\.duelKey)
    }
}
