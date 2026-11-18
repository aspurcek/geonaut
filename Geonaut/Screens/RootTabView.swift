import SwiftUI

/// Uygulama içi 3 sekme (Ana Sayfa/Kupalar/Profil) arasındaki gerçek geçişi yönetir.
/// Her ekran kendi NavBar'ını Figma'ya sadık kalarak kendi içinde render eder
/// (bkz. tasarım notu: her ekranın kendi NavBar instance'ı var); geçiş burada,
/// paylaşılan `selectedTab` binding'i üzerinden yönetiliyor.
///
/// ÖNEMLİ: `progress` ve `points` bilerek burada, `body`'deki `switch`in DIŞINDA
/// tutuluyor. Daha önce bunlar HomeView'in kendi `@State`'iydi — ama switch'in bir
/// dalından diğerine geçmek (ör. Ana Sayfa → Kupalar) SwiftUI'da o dalın view
/// kimliğini komple değiştirir, bu da tüm `@State`'i sıfırlardı: kullanıcı Kupalar'a
/// bakıp Ana Sayfa'ya dönünce tamamladığı etaplar ve kazandığı puanlar kaybolurdu.
/// Bu state RootTabView seviyesinde tutulduğu için sekme geçişlerinde hayatta kalır.
struct RootTabView: View {
    let profile: PlayerProfile
    /// Hesap oluşturmadan önce deneme modu — yalnızca Bayrak Tahmin › Avrupa › Etap 1
    /// oynanabilir, Kupalar/Profil kilitli görünür (bkz. GuestLockedView).
    var isGuest: Bool = false
    /// bkz. AppState.cloudReachable — Ana Sayfa'da "çevrimdışı" bilgisi göstermek için.
    var cloudReachable: Bool = true
    var cloudAccountMissing: Bool = false
    var onRequireSignIn: () -> Void = {}
    /// Ayarlar ekranında "Kaydet" (yalnızca ad) — AppState.updateProfile'a kadar iletilir.
    var onSaveSettings: (_ displayName: String) -> Void = { _ in }
    /// "Avatarını Oluştur" ekranında "Kaydet" — AppState.updateAvatar'a kadar iletilir.
    var onSaveAvatar: (_ avatarColorHex: UInt32, _ character: AvatarCharacter) -> Void = { _, _ in }
    /// Bir etap bitince çağrılır — AppState.recordStageCompletion'a kadar iletilir; hem
    /// günlük seriyi günceller hem ilerlemeyi CloudKit'e kalıcı yazar. Bilerek TEK bir
    /// closure: seri güncellemesi ve ilerleme senkronizasyonu ayrı ayrı çağrılıp her biri
    /// kendi CloudKit save()'ini ateşleseydi, aynı kayıt üzerinde yarışan iki save
    /// doğardı (bkz. AppState.recordStageCompletion'daki not).
    var onStageCompleted: (_ points: Int, _ completedStageKeys: Set<String>, _ learnedCountryCodes: Set<String>, _ bestPointsByStage: [String]) -> Int = { _, _, _, _ in 0 }
    /// Canlar bitince (seviye başarısız) çağrılır: o gün yine de oynandı sayılır. Haftalık seri bonusu çıktıysa miktarı döner.
    var onSessionFailed: () -> Int = { 0 }
    /// Ayarlar ekranındaki "Çıkış Yap" — AppState.signOut'a kadar iletilir.
    var onSignOut: () -> Void = {}
    /// Başarılıysa true — false ise Ayarlar'da hata gösterilir.
    var onDeleteAccount: () async -> Bool = { true }
    /// Seri koruyucu kaç günü kurtardı (bkz. AppState.freezeNoticeDays) — bir kez bilgi verilir.
    var freezeNoticeDays: Int? = nil
    var onDismissFreezeNotice: () -> Void = {}
    /// Düello / arkadaş daveti ödülü — AppState.awardPoints'e kadar iletilir.
    var onAwardPoints: (Int) -> Void = { _ in }

    @State private var selectedTab: GeoTab = .home
    /// Kupalar ekranına Profil'deki "Tümünü Gör" ile mi gelindi — geri okunu göstermek için.
    @State private var cupsOpenedFromProfile = false
    @State private var progress: GameProgress
    @State private var points: Int
    /// Haftalık seri bonusu kazanıldıysa miktarı (kutlama uyarısını açar).
    @State private var weeklyBonusAwarded: Int?

    init(
        profile: PlayerProfile, isGuest: Bool = false, cloudReachable: Bool = true, cloudAccountMissing: Bool = false,
        onRequireSignIn: @escaping () -> Void = {},
        onSaveSettings: @escaping (_ displayName: String) -> Void = { _ in },
        onSaveAvatar: @escaping (_ avatarColorHex: UInt32, _ character: AvatarCharacter) -> Void = { _, _ in },
        onStageCompleted: @escaping (_ points: Int, _ completedStageKeys: Set<String>, _ learnedCountryCodes: Set<String>, _ bestPointsByStage: [String]) -> Int = { _, _, _, _ in 0 },
        onSessionFailed: @escaping () -> Int = { 0 },
        onSignOut: @escaping () -> Void = {},
        onDeleteAccount: @escaping () async -> Bool = { true },
        freezeNoticeDays: Int? = nil,
        onDismissFreezeNotice: @escaping () -> Void = {},
        onAwardPoints: @escaping (Int) -> Void = { _ in }
    ) {
        self.onAwardPoints = onAwardPoints
        self.profile = profile
        self.isGuest = isGuest
        self.cloudReachable = cloudReachable
        self.cloudAccountMissing = cloudAccountMissing
        self.onRequireSignIn = onRequireSignIn
        self.onSaveSettings = onSaveSettings
        self.onSaveAvatar = onSaveAvatar
        self.onStageCompleted = onStageCompleted
        self.onSessionFailed = onSessionFailed
        self.onSignOut = onSignOut
        self.onDeleteAccount = onDeleteAccount
        self.freezeNoticeDays = freezeNoticeDays
        self.onDismissFreezeNotice = onDismissFreezeNotice
        #if DEBUG
        // `-debugTab cups|profile` ile başlat (ekran görüntüsü için).
        switch UserDefaults.standard.string(forKey: "debugTab") {
        case "cups": _selectedTab = State(initialValue: .cups)
        case "profile": _selectedTab = State(initialValue: .profile)
        case "cupsback": _selectedTab = State(initialValue: .cups); _cupsOpenedFromProfile = State(initialValue: true)
        default: break
        }
        #endif
        _progress = State(initialValue: GameProgress(
            completedStageKeys: profile.completedStageKeys,
            learnedCountryCodes: profile.learnedCountryCodes,
            bestPointsByStage: profile.bestPointsByStage
        ))
        _points = State(initialValue: profile.points)
    }

    /// Avatar oluşturuldu mu: kayıtlı bayrak YA DA varsayılandan farklı renk/karakter.
    /// (Bayrak sonradan eklendiği için eski profillerde kayıtlı değil; avatarı olan
    /// kullanıcının header'da varsayılan ikon görmemesi için değerlerden de çıkarılır.)
    private var hasCustomAvatar: Bool {
        profile.hasCustomAvatar
            || profile.avatarColorHex != PlayerProfile.defaultAvatarColorHex
            || profile.avatarCharacter != AvatarCharacter()
    }

    private var streakAtRisk: Bool {
        StreakStatus.compute(lastActiveDate: profile.lastActiveDate, streakDays: profile.streakDays) == .atRisk
    }

    var body: some View {
        Group { tabContent }
            .onAppear {
                // Düello/davet ödülleri: ekrandaki bakiye + profile kalıcı yazım (misafirde yok).
                SocialStats.shared.onReward = isGuest ? nil : { amount in
                    points += amount
                    onAwardPoints(amount)
                }
                guard !isGuest else { return }
                // Düello kimliği (ad + avatar) ve kategoriler; Game Center'a önceden bağlandıysa sessizce yeniden bağlan.
                DuelManager.shared.me = DuelPlayerInfo(id: "me", name: profile.displayName, avatarColorHex: profile.avatarColorHex, character: profile.avatarCharacter)
                DuelManager.shared.myCategories = progress.duelCategories
                DuelManager.shared.hasCompletedALevel = !progress.completedStageKeysExport.isEmpty
                GameCenterManager.shared.restoreIfPreviouslyConnected()
                #if DEBUG
                if UserDefaults.standard.bool(forKey: "debugDuelTurn") { DuelManager.shared.debugInjectTurn() }
                #endif
            }
            // Oturum içinde ilk seviye bitince düello şartı ve kategoriler güncellensin.
            .onChange(of: progress.completedStageKeysExport.count) { _, count in
                DuelManager.shared.hasCompletedALevel = count > 0
                DuelManager.shared.myCategories = progress.duelCategories
            }
            .onChange(of: selectedTab) { _, newTab in
                // Başka sekmeye geçilince "Profil'den geldim" bilgisi sıfırlanır.
                if newTab != .cups { cupsOpenedFromProfile = false }
            }
            .alert("Haftalık seri ödülü!", isPresented: Binding(get: { weeklyBonusAwarded != nil }, set: { if !$0 { weeklyBonusAwarded = nil } })) {
                Button("Harika!", role: .cancel) {}
            } message: {
                Text("\(profile.streakDays) gün üst üste oynadın. Hediye: +\(weeklyBonusAwarded ?? 0) puan.")
            }
            // Aynı görünüme iki .alert bağlamak birini sessizce devre dışı bırakabildiği için ayrı bir katmanda.
            .background {
                Color.clear
                    .alert("Seri koruyucu devreye girdi", isPresented: Binding(get: { freezeNoticeDays != nil }, set: { if !$0 { onDismissFreezeNotice() } })) {
                        Button("Harika!", role: .cancel) {}
                    } message: {
                        Text("Oynamadığın \(freezeNoticeDays ?? 0) gün için seri koruyucu kullanıldı. \(profile.streakDays) günlük serin devam ediyor. Bugün oynamayı unutma!")
                    }
            }
    }

    @ViewBuilder private var tabContent: some View {
        switch selectedTab {
        case .home:
            HomeView(
                selectedTab: $selectedTab,
                points: $points, streak: profile.streakDays,
                streakAtRisk: streakAtRisk, cloudReachable: cloudReachable, cloudAccountMissing: cloudAccountMissing,
                progress: progress,
                avatarColorHex: profile.avatarColorHex, avatarCharacter: profile.avatarCharacter, hasCustomAvatar: hasCustomAvatar,
                isGuest: isGuest, isDemo: profile.appleUserIdentifier == "demo", onRequireSignIn: onRequireSignIn,
                onStageCompleted: {
                    let bonus = onStageCompleted(points, progress.completedStageKeysExport, progress.learnedCountryCodes, progress.bestPointsExport)
                    if bonus > 0 {
                        points += bonus // AppState bonusu profile'a zaten yazdı; ekrandaki bakiye de eşit kalsın
                        weeklyBonusAwarded = bonus
                    }
                },
                onSessionFailed: {
                    let bonus = onSessionFailed()
                    if bonus > 0 {
                        points += bonus
                        weeklyBonusAwarded = bonus
                    }
                }
            )
        case .cups:
            if isGuest {
                GuestLockedView(selectedTab: $selectedTab, onSignIn: onRequireSignIn)
            } else {
                BadgesView(
                    selectedTab: $selectedTab, progress: progress,
                    onBack: cupsOpenedFromProfile ? { cupsOpenedFromProfile = false; selectedTab = .profile } : nil
                )
            }
        case .profile:
            if isGuest {
                GuestLockedView(selectedTab: $selectedTab, onSignIn: onRequireSignIn)
            } else {
                ProfileView(
                    selectedTab: $selectedTab,
                    displayName: profile.displayName, email: profile.email, points: points, streak: profile.streakDays, lastActiveDate: profile.lastActiveDate,
                    avatarColorHex: profile.avatarColorHex, character: profile.avatarCharacter,
                    progress: progress,
                    onSaveSettings: onSaveSettings, onSaveAvatar: onSaveAvatar, onSeeAllBadges: { cupsOpenedFromProfile = true; selectedTab = .cups },
                    onSignOut: onSignOut, onDeleteAccount: onDeleteAccount
                )
            }
        }
    }
}

#Preview {
    RootTabView(profile: .newPlayer(appleUserIdentifier: "preview", displayName: "Aslı"))
}
