import GameKit
import SwiftUI

/// Game Center ile arkadaşlar (kullanıcı kararı 2026-11-14: "game center arkadaş ekle olsun").
/// Sunucu yok: arkadaş listesi, arkadaş daveti ve puan karşılaştırması tamamen Apple'ın Game Center'ı
/// üzerinden. Giriş yalnızca kullanıcı Profil'deki "Game Center'a bağlan"a dokununca istenir
/// (açılışta pencere çıkarmaz). Puan: ömür boyu Geonaut puanı, tek bir skor tablosuna gönderilir —
/// App Store Connect'te aynı kimlikle bir skor tablosu oluşturulmalı (bkz. pointsLeaderboardID).
@MainActor
@Observable
final class GameCenterManager {
    static let shared = GameCenterManager()

    /// App Store Connect > Game Center > Skor Tablosu kimliği (Klasik, yüksek puan, büyükten küçüğe).
    static let pointsLeaderboardID = "geonaut.points.alltime"
    /// Haftalık (tekrarlanan, Pazartesi başlar) skor tablosu — "Bu hafta" sekmesi.
    static let weeklyLeaderboardID = "geonaut.points.weekly"

    enum Scope: Equatable { case week, allTime }

    enum Status: Equatable {
        case idle
        case authenticating
        case signedIn
        /// Kullanıcı girişten vazgeçti ya da Game Center kapalı (Apple aynı oturumda tekrar giriş penceresi açtırmaz).
        case unavailable
    }

    enum FriendsAccess: Equatable { case unknown, granted, denied }

    struct Friend: Identifiable {
        let id: String
        let name: String
        var points: Int?
        var photo: UIImage?
        var isMe = false
    }

    private(set) var status: Status = .idle
    private(set) var friendsAccess: FriendsAccess = .unknown
    private(set) var friends: [Friend] = []
    private(set) var isLoadingFriends = false
    /// Sıralama kapsamı (Arkadaşlar ekranındaki sekme).
    var scope: Scope = .week
    /// Düello daveti için Game Center oyuncu nesneleri.
    private var players: [String: GKPlayer] = [:]
    private let listener = DuelEventListener()
    private var didRegisterListener = false

    func player(id: String) -> GKPlayer? { players[id] }

    var isSignedIn: Bool { status == .signedIn }
    var localPlayerName: String { GKLocalPlayer.local.displayName }

    private init() {}

    /// Daha önce bağlanan oyuncu için açılışta sessizce yeniden bağlanmak (Game Center her açılışta
    /// authenticateHandler ister; bağlıysa pencere açmaz, yalnızca "Tekrar hoş geldin" bandı).
    private static let connectedKey = "geonaut.gameCenter.connected"

    func restoreIfPreviouslyConnected() {
        guard UserDefaults.standard.bool(forKey: Self.connectedKey), status == .idle else { return }
        authenticate()
    }

    // MARK: Giriş

    func authenticate() {
        guard status == .idle || status == .unavailable else { return }
        if GKLocalPlayer.local.isAuthenticated {
            status = .signedIn
            didSignIn()
            Task { await reloadFriends() }
            return
        }
        status = .authenticating
        // Game Center hiç cevap vermezse (ör. cihazda/simülatörde hesap yok) sonsuza dek beklemede kalma.
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(10))
            if self.status == .authenticating && !GKLocalPlayer.local.isAuthenticated {
                self.status = .unavailable
            }
        }
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, _ in
            Task { @MainActor in
                guard let self else { return }
                if let viewController {
                    Self.topViewController()?.present(viewController, animated: true)
                    return
                }
                if GKLocalPlayer.local.isAuthenticated {
                    self.status = .signedIn
                    self.didSignIn()
                    await self.reloadFriends()
                } else {
                    self.status = .unavailable
                }
            }
        }
    }

    /// Daha önce bağlanmış bir oyuncu için sessizce durumu tazeler (pencere açmaz).
    func refreshIfSignedIn(myPoints: Int? = nil) {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        status = .signedIn
        didSignIn()
        Task { await reloadFriends(myPoints: myPoints) }
    }

    /// Bağlanınca: oyuncuya özel sayaçları aç, düello olaylarını dinle, düello listesini tazele.
    private func didSignIn() {
        UserDefaults.standard.set(true, forKey: Self.connectedKey)
        SocialStats.shared.activate(playerID: GKLocalPlayer.local.gamePlayerID)
        if !didRegisterListener {
            GKLocalPlayer.local.register(listener)
            didRegisterListener = true
        }
        Task { await DuelManager.shared.refresh() }
    }

    // MARK: Arkadaşlar

    func reloadFriends(myPoints: Int? = nil) async {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        isLoadingFriends = true
        defer { isLoadingFriends = false }

        let players: [GKPlayer]
        do {
            players = try await GKLocalPlayer.local.loadFriends()
            friendsAccess = .granted
            self.players = Dictionary(uniqueKeysWithValues: players.map { ($0.gamePlayerID, $0) })
            // Davet ödülü: listeye ilk kez gelen arkadaşlar (bkz. SocialStats.registerFriends).
            SocialStats.shared.registerFriends(players.map(\.gamePlayerID))
        } catch {
            let authorization = try? await GKLocalPlayer.local.loadFriendsAuthorizationStatus()
            friendsAccess = authorization == .denied || authorization == .restricted ? .denied : .unknown
            friends = []
            return
        }

        var scores: [String: Int] = [:]
        let boardID = scope == .week ? Self.weeklyLeaderboardID : Self.pointsLeaderboardID
        let myScore = scope == .week ? SocialStats.shared.currentWeekPoints : myPoints
        if let board = try? await GKLeaderboard.loadLeaderboards(IDs: [boardID]).first,
           let result = try? await board.loadEntries(for: .friendsOnly, timeScope: .allTime, range: NSRange(location: 1, length: 100)) {
            if let me = result.0 { scores[me.player.gamePlayerID] = me.score }
            for entry in result.1 { scores[entry.player.gamePlayerID] = entry.score }
        }

        var list = players.map { Friend(id: $0.gamePlayerID, name: $0.displayName, points: scores[$0.gamePlayerID]) }
        let me = GKLocalPlayer.local
        list.append(Friend(id: me.gamePlayerID, name: me.displayName, points: myScore ?? scores[me.gamePlayerID], isMe: true))
        friends = list.sorted { ($0.points ?? -1) > ($1.points ?? -1) }

        // Fotoğraflar ayrıca yüklenir (liste beklemesin).
        for player in players + [me] {
            if let image = try? await player.loadPhoto(for: .small),
               let index = friends.firstIndex(where: { $0.id == player.gamePlayerID }) {
                friends[index].photo = image
            }
        }
    }

    /// Apple'ın arkadaş daveti penceresi (Mesajlar vb. ile davet gönderilir).
    func presentAddFriend() {
        guard GKLocalPlayer.local.isAuthenticated, let top = Self.topViewController() else { return }
        try? GKLocalPlayer.local.presentFriendRequestCreator(from: top)
    }

    // MARK: Puan

    /// Ömür boyu puanı skor tablosuna gönderir (yalnızca bağlıysa; pencere açmaz).
    func submit(points: Int) {
        guard GKLocalPlayer.local.isAuthenticated, points > 0 else { return }
        Task {
            try? await GKLeaderboard.submitScore(points, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [Self.pointsLeaderboardID])
        }
    }

    /// Bu haftanın toplam puanını haftalık skor tablosuna gönderir.
    func submitWeekly(points: Int) {
        guard GKLocalPlayer.local.isAuthenticated, points > 0 else { return }
        Task {
            try? await GKLeaderboard.submitScore(points, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [Self.weeklyLeaderboardID])
        }
    }

    // MARK: Yardımcı

    #if DEBUG
    /// `-debugFriends 1`: Game Center olmadan dolu arkadaş listesini göstermek için sahte veri.
    func debugFill(myPoints: Int) {
        status = .signedIn
        friendsAccess = .granted
        let week = scope == .week
        friends = [
            Friend(id: "ayse", name: "Ayşe", points: week ? 340 : 1240),
            Friend(id: "me", name: "Sen", points: week ? 210 : myPoints, isMe: true),
            Friend(id: "mert", name: "Mert", points: week ? 150 : 720),
            Friend(id: "deniz", name: "Deniz", points: week ? 40 : 410),
            Friend(id: "selin", name: "Selin", points: nil)
        ]
    }
    #endif

    private static func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive } ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        var top = scene?.windows.first { $0.isKeyWindow }?.rootViewController
        while let presented = top?.presentedViewController { top = presented }
        return top
    }
}
