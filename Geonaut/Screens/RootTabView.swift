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
    var onStageCompleted: (_ points: Int, _ completedStageKeys: Set<String>, _ learnedCountryCodes: Set<String>, _ bestPointsByStage: [String]) -> Void = { _, _, _, _ in }
    /// Ayarlar ekranındaki "Çıkış Yap" — AppState.signOut'a kadar iletilir.
    var onSignOut: () -> Void = {}
    /// Başarılıysa true — false ise Ayarlar'da hata gösterilir.
    var onDeleteAccount: () async -> Bool = { true }

    @State private var selectedTab: GeoTab = .home
    @State private var progress: GameProgress
    @State private var points: Int

    init(
        profile: PlayerProfile, isGuest: Bool = false, cloudReachable: Bool = true, cloudAccountMissing: Bool = false,
        onRequireSignIn: @escaping () -> Void = {},
        onSaveSettings: @escaping (_ displayName: String) -> Void = { _ in },
        onSaveAvatar: @escaping (_ avatarColorHex: UInt32, _ character: AvatarCharacter) -> Void = { _, _ in },
        onStageCompleted: @escaping (_ points: Int, _ completedStageKeys: Set<String>, _ learnedCountryCodes: Set<String>, _ bestPointsByStage: [String]) -> Void = { _, _, _, _ in },
        onSignOut: @escaping () -> Void = {},
        onDeleteAccount: @escaping () async -> Bool = { true }
    ) {
        self.profile = profile
        self.isGuest = isGuest
        self.cloudReachable = cloudReachable
        self.cloudAccountMissing = cloudAccountMissing
        self.onRequireSignIn = onRequireSignIn
        self.onSaveSettings = onSaveSettings
        self.onSaveAvatar = onSaveAvatar
        self.onStageCompleted = onStageCompleted
        self.onSignOut = onSignOut
        self.onDeleteAccount = onDeleteAccount
        #if DEBUG
        // `-debugTab cups|profile` ile başlat (ekran görüntüsü için).
        switch UserDefaults.standard.string(forKey: "debugTab") {
        case "cups": _selectedTab = State(initialValue: .cups)
        case "profile": _selectedTab = State(initialValue: .profile)
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
        switch selectedTab {
        case .home:
            HomeView(
                selectedTab: $selectedTab,
                points: $points, streak: profile.streakDays,
                streakAtRisk: streakAtRisk, cloudReachable: cloudReachable, cloudAccountMissing: cloudAccountMissing,
                progress: progress,
                avatarColorHex: profile.avatarColorHex, avatarCharacter: profile.avatarCharacter, hasCustomAvatar: hasCustomAvatar,
                isGuest: false, onRequireSignIn: onRequireSignIn,
                onStageCompleted: { onStageCompleted(points, progress.completedStageKeysExport, progress.learnedCountryCodes, progress.bestPointsExport) }
            )
        case .cups:
            BadgesView(selectedTab: $selectedTab, progress: progress)
        case .profile:
            ProfileView(
                selectedTab: $selectedTab,
                displayName: profile.displayName, email: profile.email, points: points, streak: profile.streakDays, lastActiveDate: profile.lastActiveDate,
                avatarColorHex: profile.avatarColorHex, character: profile.avatarCharacter,
                progress: progress,
                onSaveSettings: onSaveSettings, onSaveAvatar: onSaveAvatar, onSeeAllBadges: { selectedTab = .cups },
                onSignOut: onSignOut, onDeleteAccount: onDeleteAccount
            )
        }
    }
}

#Preview {
    RootTabView(profile: .newPlayer(appleUserIdentifier: "preview", displayName: "Aslı"))
}
