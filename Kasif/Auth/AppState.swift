import AuthenticationServices
import SwiftUI

/// Uygulamanın kimlik doğrulama + oyuncu profili durumu. Apple'ın verdiği
/// `userIdentifier` cihazda saklanır (Keychain değil UserDefaults — hassas bir sır
/// değil, sadece opak bir tanımlayıcı); her açılışta `getCredentialState` ile hâlâ
/// geçerli mi diye sorulur (Apple hesabından çıkış/iptal durumunu yakalamak için).
@Observable
final class AppState {
    enum Phase {
        case checkingExistingSession
        case signedOut
        case signingIn
        case loadingProfile
        case signedIn(PlayerProfile)
        /// Hesap oluşturmadan önce deneme modu — bkz. enterGuestMode(). Yalnızca
        /// Bayrak Tahmin › Avrupa › Etap 1 oynanabilir, ilerleme kalıcı değildir.
        case guest
        case error(String)
    }

    private(set) var phase: Phase = .checkingExistingSession
    let appleSignIn = AppleSignInCoordinator()

    private static let userIdentifierKey = "kasif.appleUserIdentifier"

    init() {
        appleSignIn.onSignedIn = { [weak self] userIdentifier, fullName, email in
            self?.handleSignedIn(userIdentifier: userIdentifier, fullName: fullName, email: email)
        }
        appleSignIn.onFailed = { [weak self] message in
            guard let self else { return }
            // Kullanıcı sistem sayfasını iptal ettiyse (ya da simulator'de Apple ID
            // yoksa) onu hata ekranına değil, misafir moduna düşürüyoruz — deneme
            // fırsatı hâlâ devam ediyor.
            self.phase = message.map { .error($0) } ?? .guest
        }
    }

    func start() {
        guard let savedUserIdentifier = UserDefaults.standard.string(forKey: Self.userIdentifierKey) else {
            phase = .signedOut
            return
        }
        Task {
            do {
                let state = try await ASAuthorizationAppleIDProvider().credentialState(forUserID: savedUserIdentifier)
                switch state {
                case .authorized:
                    await loadProfile(userIdentifier: savedUserIdentifier, fallbackName: "Kaşif")
                case .revoked, .notFound, .transferred:
                    // Kullanıcı Apple hesabından bu uygulamanın erişimini gerçekten iptal
                    // etmiş — burada oturumu kapatmak doğru.
                    UserDefaults.standard.removeObject(forKey: Self.userIdentifierKey)
                    phase = .signedOut
                @unknown default:
                    await loadProfile(userIdentifier: savedUserIdentifier, fallbackName: "Kaşif")
                }
            } catch {
                // Durum sorgusu ağ/geçici bir sebeple başarısız oldu — bu, kullanıcının
                // gerçekten çıkış yaptığı anlamına gelmez. Onu login ekranına geri atmak
                // yerine iyimser şekilde profille devam ediyoruz (loadProfile zaten
                // CloudKit'e erişilemezse yerel bir profile düşüyor).
                await loadProfile(userIdentifier: savedUserIdentifier, fallbackName: "Kaşif")
            }
        }
    }

    func signInWithApple() {
        // Kullanıcı butona art arda dokunursa birden fazla auth isteği kuyruğa
        // girmesin diye zaten devam eden bir girişi yok sayıyoruz.
        guard case .signingIn = phase else {
            phase = .signingIn
            appleSignIn.signIn()
            return
        }
    }

    /// "Şimdi değil, önce deneyeyim" — Apple'a hiç dokunmadan doğrudan misafir moduna
    /// geçer (bkz. Phase.guest).
    func enterGuestMode() {
        phase = .guest
    }

    #if DEBUG
    /// Yalnızca DEBUG derlemelerinde: gerçek Apple ID'ye ihtiyaç duymadan (simulator'de
    /// iCloud hesabı olmadığında) akışı test edebilmek için. Release/App Store
    /// derlemesine hiç girmez.
    func signInAsDebugGuest() {
        phase = .signedIn(.newPlayer(appleUserIdentifier: "debug-guest", displayName: "Test Kaşif"))
    }
    #endif

    func signOut() {
        UserDefaults.standard.removeObject(forKey: Self.userIdentifierKey)
        phase = .signedOut
    }

    private func handleSignedIn(userIdentifier: String, fullName: PersonNameComponents?, email: String?) {
        UserDefaults.standard.set(userIdentifier, forKey: Self.userIdentifierKey)
        let name = [fullName?.givenName, fullName?.familyName].compactMap { $0 }.joined(separator: " ")
        Task { await loadProfile(userIdentifier: userIdentifier, fallbackName: name.isEmpty ? "Kaşif" : name, email: email) }
    }

    @MainActor
    private func loadProfile(userIdentifier: String, fallbackName: String, email: String? = nil) async {
        phase = .loadingProfile
        do {
            let profile = try await PlayerCloudKitService.fetchOrCreateProfile(appleUserIdentifier: userIdentifier, displayName: fallbackName, email: email)
            phase = .signedIn(profile)
        } catch {
            // CloudKit'e erişilemiyorsa (iCloud oturumu yok, ağ yok vb.) kullanıcıyı
            // uygulama dışında bırakmak yerine yerel/varsayılan bir profille devam ettiriyoruz.
            phase = .signedIn(PlayerProfile.newPlayer(appleUserIdentifier: userIdentifier, displayName: fallbackName, email: email))
        }
    }

    /// "Ayarlar" ekranından ad güncellemesi — önce yerel durumu (ve dolayısıyla UI'ı)
    /// hemen günceller, sonra CloudKit'e arka planda yazar. Kaydetme başarısız olsa
    /// bile (ağ yok vb.) oturum içi değişiklik kalıcı görünür; bir sonraki başarılı
    /// senkronizasyonda gerçekten kalıcı hâle gelir.
    func updateProfile(displayName: String) {
        guard case .signedIn(var profile) = phase else { return }
        profile.displayName = displayName
        phase = .signedIn(profile)
        Task { try? await PlayerCloudKitService.save(profile) }
    }

    /// "Avatarını Oluştur" ekranından zemin rengi + karakter (ten/saç/aksesuar/yüz
    /// detayı) güncellemesi — bkz. updateProfile'daki aynı fire-and-forget gerekçesi.
    func updateAvatar(avatarColorHex: UInt32, character: AvatarCharacter) {
        guard case .signedIn(var profile) = phase else { return }
        profile.avatarColorHex = avatarColorHex
        profile.avatarCharacter = character
        phase = .signedIn(profile)
        Task { try? await PlayerCloudKitService.save(profile) }
    }

    /// "Seri Kaybı Akışı" (bkz. Streak.swift) — "50 Puan ile Canlandır": puan düşer,
    /// `lastActiveDate` bugüne çekilir (seri sayısı korunur, artık "kayıp" sayılmaz).
    func reviveStreak() {
        guard case .signedIn(var profile) = phase, profile.points >= GameRules.streakReviveCost else { return }
        profile.points -= GameRules.streakReviveCost
        profile.lastActiveDate = .now
        phase = .signedIn(profile)
        Task { try? await PlayerCloudKitService.save(profile) }
    }

    /// "Vazgeç" → "Yeniden Başla": seri sıfırlanır, bugünden itibaren yeniden sayılır.
    func restartStreak() {
        guard case .signedIn(var profile) = phase else { return }
        profile.streakDays = 0
        profile.lastActiveDate = .now
        phase = .signedIn(profile)
        Task { try? await PlayerCloudKitService.save(profile) }
    }

    /// Bir etap tamamlandığında (Bayrak Tahmin, Harita Bilmece ya da Ana Diller) çağrılır — hem günlük
    /// seriyi hem de kazanılan puan/GameProgress'in ham hâlini TEK bir profil mutasyonunda
    /// birleştirip TEK bir CloudKit save() çağrısıyla kaydeder.
    ///
    /// ÖNEMLİ: Bunları eskiden ayrı ayrı metotlar (recordDailyActivity + syncGameProgress)
    /// olarak, her biri kendi `Task { save(profile) }`'ini ateşleyerek çağırıyorduk. HomeView
    /// ikisini de aynı etap-bitti olayında art arda çağırdığı için bu, AYNI CKRecord üzerinde
    /// yarışan iki save() doğuruyordu: PlayerCloudKitService.save artık var olan kaydı önce
    /// getirip üzerine yazdığından (bkz. o dosyadaki not), iki save aynı anda fetch edip
    /// birbirinin üstüne yazmaya çalışınca kaybeden CKError.serverRecordChanged ile
    /// (try? tarafından sessizce) reddedilir — o çağrının taşıdığı güncelleme (seri YA DA
    /// puan/ilerleme) hiç CloudKit'e ulaşmadan kaybolabilirdi. Tek çağrı/tek save bunu ortadan kaldırır.
    func recordStageCompletion(points: Int, completedStageKeys: Set<String>, learnedCountryCodes: Set<String>, bestPointsByStage: [String]) {
        guard case .signedIn(var profile) = phase else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let last = calendar.startOfDay(for: profile.lastActiveDate)
        let daysSince = calendar.dateComponents([.day], from: last, to: today).day ?? 0

        if profile.streakDays == 0 {
            profile.streakDays = 1 // ilk gün ya da restartStreak() sonrası yeni serinin başlangıcı
        } else if daysSince == 1 {
            profile.streakDays += 1
        } else if daysSince > 1 {
            // Buraya normalde StreakLossFlowView'dan geçmeden gelinmemeli, ama savunma
            // amaçlı: aradan gün(ler) geçtiyse seriyi bugünden başlat.
            profile.streakDays = 1
        }
        // daysSince <= 0 ve streakDays > 0: bugün zaten oynanmış, sayı değişmez.
        profile.lastActiveDate = .now

        profile.points = points
        profile.completedStageKeys = completedStageKeys
        profile.learnedCountryCodes = learnedCountryCodes
        profile.bestPointsByStage = bestPointsByStage

        phase = .signedIn(profile)
        Task { try? await PlayerCloudKitService.save(profile) }
    }
}
