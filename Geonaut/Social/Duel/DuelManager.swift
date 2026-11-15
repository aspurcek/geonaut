import GameKit
import SwiftUI

/// Game Center sıra tabanlı maçlarla düellolar (bkz. DuelModels). Akış:
/// 1. Davet eden maçı kurar, kendi kartını + kategorilerini yazar, sırayı arkadaşına verir.
/// 2. Arkadaş daveti kabul eder; ortak kategorilerden 10 soru üretilir, oynar, sırayı geri verir.
/// 3. Davet eden aynı soruları oynar; sonuçlar karşılaştırılır ve maç biter.
/// Biten her düello iki tarafta da bir kez kaydedilir (SocialStats) ve sonuç ekranı açılır.
@MainActor
@Observable
final class DuelManager {
    static let shared = DuelManager()

    enum EntryState: Equatable {
        case yourTurn
        case waiting
        case finished(DuelOutcome)
        case expired
    }

    struct Entry: Identifiable {
        let id: String
        let match: GKTurnBasedMatch?
        let data: DuelMatchData?
        let opponentID: String?
        let opponentName: String
        let opponentInfo: DuelPlayerInfo?
        let state: EntryState
    }

    /// Oynanacak düello (soru ekranı bunu açar).
    struct PlayContext: Identifiable {
        let id: String
        let questions: [DuelQuestion]
        let me: DuelPlayerInfo
        let opponent: DuelPlayerInfo?
        let opponentName: String
        let opponentResult: DuelResult?
        let isBot: Bool
    }

    /// Sonuç ekranı.
    struct ResultPresentation: Identifiable {
        let id: String
        let me: DuelPlayerInfo
        let opponent: DuelPlayerInfo
        let myResult: DuelResult
        let theirResult: DuelResult
        let outcome: DuelOutcome
        let opponentID: String
        let isBot: Bool
    }

    private(set) var entries: [Entry] = []
    private(set) var isLoading = false
    var errorMessage: String?
    var resultToShow: ResultPresentation?
    /// Şu an açık olan düello akışı (sonucu o akış gösterir; Profil'deki genel sonuç penceresi açılmaz).
    var activeFlowID: String?

    /// Oyuncunun kendi kartı ve kategorileri (Arkadaşlar ekranı profilden doldurur).
    /// Kimlik, bağlıysa her zaman Game Center oyuncu kimliğidir (sonuçlar bu anahtarla yazılır).
    private var myCard: DuelPlayerInfo?
    var me: DuelPlayerInfo? {
        get {
            guard let card = myCard else { return nil }
            let id = GKLocalPlayer.local.isAuthenticated ? GKLocalPlayer.local.gamePlayerID : card.id
            return DuelPlayerInfo(id: id, name: card.name, avatarColorHex: card.avatarColorHex, character: card.character)
        }
        set { myCard = newValue }
    }
    var myCategories: [String] = []

    private init() {}

    // MARK: Liste

    func refresh() async {
        guard GKLocalPlayer.local.isAuthenticated else {
            #if DEBUG
            if UserDefaults.standard.bool(forKey: "debugDuelTurn") || UserDefaults.standard.bool(forKey: "debugFriends") { return }
            #endif
            entries = []
            return
        }
        isLoading = true
        defer { isLoading = false }
        guard let matches = try? await GKTurnBasedMatch.loadMatches() else { return }
        let myID = GKLocalPlayer.local.gamePlayerID
        var list: [Entry] = []
        for match in matches {
            let data = DuelMatchData.decode(match.matchData)
            let other = match.participants.first { $0.player?.gamePlayerID != myID }
            let opponentID = other?.player?.gamePlayerID
            let info = data.flatMap { d in d.challenger.id == myID ? d.opponent : d.challenger }
            let name = info?.name ?? other?.player?.displayName ?? L("Arkadaşın")
            let state: EntryState
            if let data, let mine = data.results[myID], let theirsKey = data.results.keys.first(where: { $0 != myID }), let theirs = data.results[theirsKey] {
                state = .finished(DuelOutcome.compare(mine: mine, theirs: theirs))
            } else if match.status == .ended {
                state = .expired
            } else if match.currentParticipant?.player?.gamePlayerID == myID {
                state = .yourTurn
            } else {
                state = .waiting
            }
            list.append(Entry(id: match.matchID, match: match, data: data, opponentID: opponentID, opponentName: name, opponentInfo: info, state: state))
        }
        // Önce sırası sende olanlar, sonra bekleyenler, en son bitenler.
        entries = list.sorted { rank($0.state) < rank($1.state) }
        presentNewlyFinished()
    }

    private func rank(_ state: EntryState) -> Int {
        switch state {
        case .yourTurn: 0
        case .waiting: 1
        case .finished: 2
        case .expired: 3
        }
    }

    /// Bitip henüz kaydedilmemiş bir düello varsa kaydet (ödül) ve sonuç ekranını aç.
    private func presentNewlyFinished() {
        guard resultToShow == nil, let me else { return }
        for entry in entries {
            guard case .finished(let outcome) = entry.state, let data = entry.data,
                  let mine = data.results[me.id], let opponentID = entry.opponentID,
                  let theirs = data.results[opponentID] else { continue }
            if SocialStats.shared.recordDuel(matchID: entry.id, opponentID: opponentID, outcome: outcome) {
                let opponent = entry.opponentInfo ?? DuelPlayerInfo(id: opponentID, name: entry.opponentName, avatarColorHex: GeoColor.avatarSwatches[2].hex, character: AvatarCharacter())
                resultToShow = ResultPresentation(id: entry.id, me: me, opponent: opponent, myResult: mine, theirResult: theirs, outcome: outcome, opponentID: opponentID, isBot: false)
                return
            }
        }
    }

    // MARK: Davet

    func challenge(friendID: String) async {
        guard let me, let player = GameCenterManager.shared.player(id: friendID) else {
            errorMessage = L("Düello başlatılamadı. Biraz sonra tekrar dene.")
            return
        }
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        request.recipients = [player]
        request.inviteMessage = L("Geonaut'ta seni düelloya çağırıyorum!")
        do {
            let match = try await GKTurnBasedMatch.find(for: request)
            let data = DuelMatchData(challenger: me, challengerCategories: myCategories)
            let next = match.participants.filter { $0.player?.gamePlayerID != me.id }
            try await match.endTurn(withNextParticipants: next, turnTimeout: DuelRules.turnTimeout, match: data.encoded())
            await refresh()
        } catch {
            errorMessage = L("Düello başlatılamadı. Biraz sonra tekrar dene.")
        }
    }

    // MARK: Oynama

    func startPlaying(_ entry: Entry) async -> PlayContext? {
        guard let me, var match = entry.match else { return nil }
        do {
            let local = match.participants.first { $0.player?.gamePlayerID == me.id }
            if local?.status == .invited {
                match = try await match.acceptInvite()
            }
            let loaded = try await match.loadMatchData()
            guard var data = DuelMatchData.decode(loaded) else { return nil }
            if data.questions.isEmpty {
                // Davet edilen taraf: soruları ortak kategorilerden üret, kartını yaz ve kaydet.
                let shared = data.challengerCategories.filter { myCategories.contains($0) }
                data.questions = DuelQuestionFactory.makeQuestions(sharedCategories: shared)
                data.opponent = me
                try await match.saveCurrentTurn(withMatch: data.encoded())
            }
            let opponentInfo = data.challenger.id == me.id ? data.opponent : data.challenger
            let opponentResult = data.results.first { $0.key != me.id }?.value
            return PlayContext(id: match.matchID, questions: data.questions, me: me, opponent: opponentInfo,
                               opponentName: opponentInfo?.name ?? entry.opponentName, opponentResult: opponentResult, isBot: false)
        } catch {
            errorMessage = L("Düello açılamadı. Biraz sonra tekrar dene.")
            return nil
        }
    }

    /// Oyuncu 10 soruyu (ya da çıkışta kalanları yanlış sayarak) bitirdi.
    func submit(_ context: PlayContext, result: DuelResult) async {
        if context.isBot {
            finishBot(context, result: result)
            return
        }
        guard let matches = try? await GKTurnBasedMatch.loadMatches(),
              let match = matches.first(where: { $0.matchID == context.id }),
              let loaded = try? await match.loadMatchData(),
              var data = DuelMatchData.decode(loaded) else {
            errorMessage = L("Sonuç gönderilemedi. İnternet bağlantını kontrol edip tekrar dene.")
            return
        }
        data.results[context.me.id] = result
        let others = match.participants.filter { $0.player?.gamePlayerID != context.me.id }
        do {
            if let theirs = data.results.first(where: { $0.key != context.me.id })?.value {
                let outcome = DuelOutcome.compare(mine: result, theirs: theirs)
                for participant in match.participants {
                    let isMe = participant.player?.gamePlayerID == context.me.id
                    switch outcome {
                    case .won: participant.matchOutcome = isMe ? .won : .lost
                    case .lost: participant.matchOutcome = isMe ? .lost : .won
                    case .tied: participant.matchOutcome = .tied
                    }
                }
                try await match.endMatchInTurn(withMatch: data.encoded())
            } else {
                try await match.endTurn(withNextParticipants: others, turnTimeout: DuelRules.turnTimeout, match: data.encoded())
            }
        } catch {
            errorMessage = L("Sonuç gönderilemedi. İnternet bağlantını kontrol edip tekrar dene.")
        }
        await refresh()
    }

    /// Bitmiş/süresi dolmuş düelloyu listeden kaldır.
    func remove(_ entry: Entry) async {
        try? await entry.match?.remove()
        await refresh()
    }

    // MARK: Bot düellosu (yalnızca geliştirme sürümü — tek başına test için)

    #if DEBUG
    /// `-debugFriends 1`: Arkadaşlar ekranındaki "Düellolarım" listesini dolu göstermek için.
    func debugFillEntries() {
        let me = self.me ?? DuelPlayerInfo(id: "me", name: "Sen", avatarColorHex: 0xF0D777, character: AvatarCharacter())
        let ayse = DuelPlayerInfo(id: "ayse", name: "Ayşe", avatarColorHex: 0x9ED3F2, character: AvatarCharacter(skinTone: .bugday, hairStyle: .uzun, hairColorHex: 0xC09910))
        let mert = DuelPlayerInfo(id: "mert", name: "Mert", avatarColorHex: 0x97E4C2, character: AvatarCharacter(skinTone: .esmer, hairStyle: .kisa, accessory: .sapka))
        let deniz = DuelPlayerInfo(id: "deniz", name: "Deniz", avatarColorHex: 0xDACCF7, character: AvatarCharacter(skinTone: .acik, hairStyle: .topuz, hairColorHex: 0x9783BE, accessory: .gozluk))
        var finished = DuelMatchData(challenger: me, challengerCategories: [])
        finished.opponent = mert
        finished.results = [me.id: DuelResult(answers: Array(repeating: true, count: 8) + [false, false], totalMilliseconds: 50_000),
                            "mert": DuelResult(answers: Array(repeating: true, count: 6) + Array(repeating: false, count: 4), totalMilliseconds: 60_000)]
        entries = [
            Entry(id: "e1", match: nil, data: nil, opponentID: "ayse", opponentName: "Ayşe", opponentInfo: ayse, state: .yourTurn),
            Entry(id: "e2", match: nil, data: nil, opponentID: "deniz", opponentName: "Deniz", opponentInfo: deniz, state: .waiting),
            Entry(id: "e3", match: nil, data: finished, opponentID: "mert", opponentName: "Mert", opponentInfo: mert, state: .finished(.won))
        ]
    }

    /// `-debugDuelTurn 1`: Ana Sayfa'daki "Düello: sıra sende" kartını görmek için sahte bir sıra.
    func debugInjectTurn() {
        let ayse = DuelPlayerInfo(id: "ayse", name: "Ayşe", avatarColorHex: 0x9ED3F2,
                                  character: AvatarCharacter(skinTone: .bugday, hairStyle: .uzun, hairColorHex: 0xC09910))
        entries = [Entry(id: "debug-turn", match: nil, data: nil, opponentID: "ayse", opponentName: "Ayşe", opponentInfo: ayse, state: .yourTurn)]
    }

    func startBotDuel() -> PlayContext {
        let me = self.me ?? DuelPlayerInfo(id: "me", name: L("Sen"), avatarColorHex: GeoColor.avatarSwatches[0].hex, character: AvatarCharacter())
        let bot = DuelPlayerInfo(
            id: "geonaut-bot", name: "Geo Bot",
            avatarColorHex: GeoColor.avatarSwatches.randomElement()?.hex ?? 0x9ED3F2,
            character: AvatarCharacter(skinTone: SkinTone.allCases.randomElement() ?? .bugday,
                                       hairStyle: HairStyle.allCases.randomElement() ?? .kisa,
                                       hairColorHex: GeoHairColor.options.randomElement()?.hex ?? 0x222938,
                                       accessory: Bool.random() ? .gozluk : nil)
        )
        let correct = Int.random(in: 4...9)
        var answers = Array(repeating: true, count: correct) + Array(repeating: false, count: DuelRules.questionCount - correct)
        answers.shuffle()
        let botResult = DuelResult(answers: answers, totalMilliseconds: Int.random(in: 35_000...110_000))
        let shared = myCategories.isEmpty ? [] : myCategories
        return PlayContext(id: "bot-\(UUID().uuidString)", questions: DuelQuestionFactory.makeQuestions(sharedCategories: shared),
                           me: me, opponent: bot, opponentName: bot.name, opponentResult: botResult, isBot: true)
    }
    #endif

    private func finishBot(_ context: PlayContext, result: DuelResult) {
        guard let opponent = context.opponent, let theirs = context.opponentResult else { return }
        let outcome = DuelOutcome.compare(mine: result, theirs: theirs)
        SocialStats.shared.recordDuel(matchID: context.id, opponentID: opponent.id, outcome: outcome)
        resultToShow = ResultPresentation(id: context.id, me: context.me, opponent: opponent, myResult: result, theirResult: theirs,
                                          outcome: outcome, opponentID: opponent.id, isBot: true)
    }
}

/// Game Center sıra/maç olaylarını dinler (bildirime dokunma, rakibin sırasını bitirmesi...).
final class DuelEventListener: NSObject, GKLocalPlayerListener {
    nonisolated func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        Task { @MainActor in await DuelManager.shared.refresh() }
    }

    nonisolated func player(_ player: GKPlayer, matchEnded match: GKTurnBasedMatch) {
        Task { @MainActor in await DuelManager.shared.refresh() }
    }
}
