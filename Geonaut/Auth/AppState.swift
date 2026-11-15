import AuthenticationServices
import CloudKit
import SwiftUI

/// Uygulamanın kimlik doğrulama + oyuncu profili durumu. Apple'ın verdiği
/// `userIdentifier` cihazda saklanır (Keychain'de); her açılışta `getCredentialState` ile hâlâ
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
        /// Demo girişi (kullanıcı adı + şifre, App Review/tanıtım için): tüm özellikler açık, ilerleme buluta yazılmaz.
        case demo
        case error(String)
    }

    private(set) var phase: Phase = .checkingExistingSession
    /// Son CloudKit çağrısı başarısızsa false — yerel yedek kullanılıyor demektir.
    private(set) var cloudReachable = true
    /// iCloud hesabı yok / giriş yapılmamış (CKError.notAuthenticated) — Ana Sayfa'da, ilerlemenin
    /// yalnızca bu cihazda kalacağını açıkça söyleyen ayrı bir uyarı gösterilir.
    private(set) var cloudAccountMissing = false
    /// Seri koruyucu kaç günü kurtardı — Ana Sayfa bir kez bilgi verir, sonra temizlenir (bkz. DailyEngagement).
    private(set) var freezeNoticeDays: Int?
    /// Yerel yedek gerçek oyuncu verisi taşıyorsa bulut tekrar denenebilir; yedek yoksa
    /// (boş varsayılan profil) buluttaki gerçek kaydın üzerine yazma riski nedeniyle denenmez.
    private var localIsAuthoritative = true
    private var saveGeneration = 0
    private var pendingSave: Task<Void, Never>?
    let appleSignIn = AppleSignInCoordinator()

    private static let userIdentifierKey = "geonaut.appleUserIdentifier"

    /// Son CloudKit sonucunu Ayarlar'daki teknik satır için saklar ("ok" ya da hata kodu).
    private func updateCloudAccountState(_ error: Error?) {
        cloudAccountMissing = (error as? CKError)?.code == .notAuthenticated
    }

    private static func recordCloudStatus(_ error: Error?) {
        let text: String
        if let error {
            let ns = error as NSError
            text = "\(ns.domain) \(ns.code)"
        } else {
            text = "ok"
        }
        UserDefaults.standard.set(text, forKey: "geonaut.cloudStatus")
    }

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
        // Eski sürümlerde UserDefaults'ta saklanan kimliği Keychain'e taşı.
        if KeychainStore.string(forKey: Self.userIdentifierKey) == nil,
           let legacy = UserDefaults.standard.string(forKey: Self.userIdentifierKey) {
            KeychainStore.set(legacy, forKey: Self.userIdentifierKey)
        }
        UserDefaults.standard.removeObject(forKey: Self.userIdentifierKey)
        guard let savedUserIdentifier = KeychainStore.string(forKey: Self.userIdentifierKey) else {
            phase = .signedOut
            return
        }
        Task {
            do {
                let state = try await ASAuthorizationAppleIDProvider().credentialState(forUserID: savedUserIdentifier)
                switch state {
                case .authorized:
                    await loadProfile(userIdentifier: savedUserIdentifier, fallbackName: String(localized: "Geonaut"))
                case .revoked, .notFound, .transferred:
                    // Kullanıcı Apple hesabından bu uygulamanın erişimini gerçekten iptal
                    // etmiş — burada oturumu kapatmak doğru.
                    KeychainStore.remove(Self.userIdentifierKey)
                    phase = .signedOut
                @unknown default:
                    await loadProfile(userIdentifier: savedUserIdentifier, fallbackName: String(localized: "Geonaut"))
                }
            } catch {
                // Durum sorgusu ağ/geçici bir sebeple başarısız oldu — bu, kullanıcının
                // gerçekten çıkış yaptığı anlamına gelmez. Onu login ekranına geri atmak
                // yerine iyimser şekilde profille devam ediyoruz (loadProfile zaten
                // CloudKit'e erişilemezse yerel bir profile düşüyor).
                await loadProfile(userIdentifier: savedUserIdentifier, fallbackName: String(localized: "Geonaut"))
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
        DailyEngagement.shared.activate(accountKey: nil)
        phase = .guest
    }

    /// Demo girişi başarılı olunca (bkz. DemoAccess) — tüm kilitler açık demo oturumu.
    func enterDemoMode() {
        DailyEngagement.shared.activate(accountKey: "demo")
        phase = .demo
    }

    #if DEBUG
    /// Yalnızca DEBUG derlemelerinde: gerçek Apple ID'ye ihtiyaç duymadan (simulator'de
    /// iCloud hesabı olmadığında) akışı test edebilmek için. Release/App Store
    /// derlemesine hiç girmez. Bayrak Tahmin, Harita Bilmece ve Ana Diller'i baştan
    /// tamamlanmış işaretler ki Dünya Yemekleri (en yeni kategori) simulator'de her
    /// seferinde 3 kategoriyi elle bitirmeden doğrudan test edilebilsin — Dünya
    /// Yemekleri'nin kendisi kasıtlı olarak bomboş bırakıldı, gerçek oynanışı test edilebilsin.
    func signInAsDebugGuest() {
        var profile = PlayerProfile.newPlayer(appleUserIdentifier: "debug-guest", displayName: UserDefaults.standard.string(forKey: "debugName") ?? "Test Geonaut")
        profile.completedStageKeys = Self.debugAllPriorCategoriesCompletedKeys
        if UserDefaults.standard.object(forKey: "debugStreak") != nil {
            // `-debugStreak N -debugStreakAgo D`: N günlük seri, son oynama D gün önce.
            profile.streakDays = UserDefaults.standard.integer(forKey: "debugStreak")
            let ago = UserDefaults.standard.integer(forKey: "debugStreakAgo")
            profile.lastActiveDate = Calendar.current.date(byAdding: .day, value: -ago, to: .now) ?? .now
        }
        DailyEngagement.shared.activate(accountKey: "debug-guest")
        if let raw = UserDefaults.standard.string(forKey: "debugFreezes"), let freezes = Int(raw) {
            // `-debugFreezes N`: seri koruyucu sayısını ayarla (seri koruyucu akışını denemek için).
            DailyEngagement.shared.debugSetFreezes(freezes)
        }
        let covered = applyStreakFreezes(&profile)
        if covered > 0 { freezeNoticeDays = covered }
        phase = .signedIn(profile)
    }

    private static var debugAllPriorCategoriesCompletedKeys: Set<String> {
        var keys: Set<String> = []
        let allStages = 0..<FlagGuessStructure.stagesPerSection
        for continent in ContinentPathNode.order.map(\.name) {
            for stage in allStages {
                keys.insert("\(continent)|\(stage)") // Bayraklar
                keys.insert("\(MainLanguageStructure.progressKey(for: continent))|\(stage)") // Diller
            }
        }
        for stage in 0..<MapPuzzleStructure.stageCount {
            keys.insert("\(MapPuzzleStructure.progressKey)|\(stage)") // Haritalar · Kıtalar
        }
        for stage in 0..<CountryPuzzleStructure.stageCount {
            keys.insert("\(CountryPuzzleStructure.progressKey)|\(stage)") // Haritalar · Ülkeler
        }
        return keys
    }
    #endif

    func signOut() {
        if case .signedIn(let profile) = phase {
            LocalProfileCache.deleteIfSynced(userIdentifier: profile.appleUserIdentifier)
        }
        KeychainStore.remove(Self.userIdentifierKey)
        StreakReminderScheduler.cancelAll() // çıkış yapan kişiye eski serinin hatırlatması gitmesin
        DailyEngagement.shared.activate(accountKey: nil)
        freezeNoticeDays = nil
        phase = .signedOut
    }

    /// "Hesabımı Sil" — CloudKit kaydını siler, yerel oturumu temizler. Silme başarısız
    /// olursa (ağ yok vb.) oturum AÇIK kalır ve false döner; kullanıcı tekrar deneyebilir.
    @MainActor
    func deleteAccount() async -> Bool {
        guard case .signedIn(let profile) = phase else { return false }
        // Apple iznini iptal edebilmek için taze bir kod (yalnızca sunucu adresi tanımlıysa; kullanıcı vazgeçerse silme yine devam eder).
        // Yalnızca onaylayan kişi giriş yapmış kişiyse (başka bir Apple Kimliği seçilirse onun iznini iptal etmeyelim).
        let revocationCode: String?
        if AppleTokenRevocation.isConfigured, let result = await appleSignIn.requestAuthorizationCode(), result.user == profile.appleUserIdentifier {
            revocationCode = result.code
        } else {
            revocationCode = nil
        }
        do {
            try await PlayerCloudKitService.delete(appleUserIdentifier: profile.appleUserIdentifier)
        } catch {
            return false
        }
        if let revocationCode { _ = await AppleTokenRevocation.revoke(authorizationCode: revocationCode) }
        LocalProfileCache.delete(userIdentifier: profile.appleUserIdentifier)
        KeychainStore.remove(Self.userIdentifierKey)
        StreakReminderScheduler.cancelAll()
        DailyEngagement.shared.deleteStoredData(accountKey: profile.appleUserIdentifier)
        DailyEngagement.shared.activate(accountKey: nil)
        freezeNoticeDays = nil
        phase = .signedOut
        return true
    }

    private func handleSignedIn(userIdentifier: String, fullName: PersonNameComponents?, email: String?) {
        KeychainStore.set(userIdentifier, forKey: Self.userIdentifierKey)
        let name = [fullName?.givenName, fullName?.familyName].compactMap { $0 }.joined(separator: " ")
        Task { await loadProfile(userIdentifier: userIdentifier, fallbackName: name.isEmpty ? String(localized: "Geonaut") : name, email: email) }
    }

    /// `operation` süre dolmadan bitmezse `CKError(.networkUnavailable)` fırlatır. İptale saygı
    /// göstermeyen bir çağrıyı da beklemeden bırakabilmek için task group değil, ilk biten kazanır.
    private nonisolated static func withTimeout<T: Sendable>(
        seconds: Double, _ operation: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            let gate = OneShotGate()
            Task {
                do {
                    let value = try await operation()
                    if gate.claim() { continuation.resume(returning: value) }
                } catch {
                    if gate.claim() { continuation.resume(throwing: error) }
                }
            }
            Task {
                try? await Task.sleep(for: .seconds(seconds))
                if gate.claim() { continuation.resume(throwing: CKError(.networkUnavailable)) }
            }
        }
    }

    @MainActor
    private func loadProfile(userIdentifier: String, fallbackName: String, email: String? = nil) async {
        phase = .loadingProfile
        DailyEngagement.shared.activate(accountKey: userIdentifier)
        let cached = LocalProfileCache.load(userIdentifier: userIdentifier)
        do {
            // iCloud yanıt vermezse (yavaş/kopuk ağ) CloudKit çağrısı süresiz bekleyebilir ve
            // "Yükleniyor"da takılırdık; 20 sn sonra hata sayıp cihazdaki yedekle devam ediyoruz.
            var profile = try await Self.withTimeout(seconds: 20) {
                try await PlayerCloudKitService.fetchOrCreateProfile(appleUserIdentifier: userIdentifier, displayName: fallbackName, email: email)
            }
            if let cached {
                // Cihazdaki yedek varsa HER ZAMAN buluttakiyle BİRLEŞTİR (ezme yok, bkz.
                // PlayerProfile.merging): bulut kaydı eskiyse ya da bir yazma kaybolduysa
                // ilerleme yedekten geri gelir, sonra buluta yeniden gönderilir.
                profile = cached.profile.merging(cloud: profile)
                persist(profile)
            } else {
                LocalProfileCache.save(profile, dirty: false)
            }
            Self.recordCloudStatus(nil)
            updateCloudAccountState(nil)
            let covered = applyStreakFreezes(&profile)
            phase = .signedIn(profile)
            if covered > 0 {
                freezeNoticeDays = covered
                persist(profile)
            }
        } catch {
            Self.recordCloudStatus(error)
            updateCloudAccountState(error)
            // CloudKit'e erişilemiyorsa (iCloud oturumu yok, ağ yok vb.) kullanıcıyı
            // uygulama dışında bırakmak yerine cihazdaki yedekle (yoksa yeni profille) devam
            // ettiriyoruz. Değişiklikler `dirty` işaretlenir; bulut kaydının üzerine boş
            // profil yazılmaz, bağlantı gelince yedek gönderilir.
            var profile = cached?.profile ?? PlayerProfile.newPlayer(appleUserIdentifier: userIdentifier, displayName: fallbackName, email: email)
            LocalProfileCache.save(profile, dirty: cached?.dirty ?? false)
            cloudReachable = false
            localIsAuthoritative = cached != nil
            let covered = applyStreakFreezes(&profile)
            phase = .signedIn(profile)
            if covered > 0 {
                freezeNoticeDays = covered
                persist(profile)
            }
        }
    }

    /// Profili önce cihaza yazar (her zaman), sonra buluta göndermeyi dener. Bulut
    /// erişilemiyorsa yedek `dirty` kalır ve sonraki açılışta gönderilir.
    private func persist(_ profile: PlayerProfile) {
        LocalProfileCache.save(profile, dirty: true)
        guard cloudReachable || localIsAuthoritative else { return }
        // Bulut yazmaları SIRAYLA yapılır ve her biri o anki EN GÜNCEL profili gönderir;
        // aksi halde art arda iki kayıt yarışırsa eski profil sonradan bitip yeni ilerlemenin
        // üzerine yazabilirdi. Yedek yalnızca arada yeni değişiklik olmadıysa "temiz" işaretlenir.
        saveGeneration += 1
        let generation = saveGeneration
        let previous = pendingSave
        pendingSave = Task { @MainActor in
            await previous?.value
            let latest: PlayerProfile
            if case .signedIn(let current) = phase { latest = current } else { latest = profile }
            do {
                try await PlayerCloudKitService.save(latest)
                if generation == saveGeneration { LocalProfileCache.save(latest, dirty: false) }
                cloudReachable = true
                Self.recordCloudStatus(nil)
                updateCloudAccountState(nil)
            } catch {
                cloudReachable = false
                Self.recordCloudStatus(error)
                updateCloudAccountState(error)
            }
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
        persist(profile)
    }

    /// "Avatarını Oluştur" ekranından zemin rengi + karakter (ten/saç/aksesuar/yüz
    /// detayı) güncellemesi — bkz. updateProfile'daki aynı fire-and-forget gerekçesi.
    /// Düello / arkadaş daveti ödülü — puanı profile ekleyip kalıcı yazar.
    func awardPoints(_ amount: Int) {
        guard amount > 0, case .signedIn(var profile) = phase else { return }
        profile.points += amount
        phase = .signedIn(profile)
        persist(profile)
    }

    func updateAvatar(avatarColorHex: UInt32, character: AvatarCharacter) {
        guard case .signedIn(var profile) = phase else { return }
        profile.avatarColorHex = avatarColorHex
        profile.avatarCharacter = character
        profile.hasCustomAvatar = true
        phase = .signedIn(profile)
        persist(profile)
    }

    // MARK: Seri koruyucu

    /// Oynanmadan geçen gün sayısı (dün oynandıysa 0). Seri yoksa 0.
    private static func missedDays(_ profile: PlayerProfile, now: Date = .now) -> Int {
        guard profile.streakDays > 0 else { return 0 }
        let calendar = Calendar.current
        let daysSince = calendar.dateComponents([.day], from: calendar.startOfDay(for: profile.lastActiveDate), to: calendar.startOfDay(for: now)).day ?? 0
        return max(daysSince - 1, 0)
    }

    /// Kopan seri, eldeki seri koruyucularla kurtarılabilir mi? (RootView bu durumda Seri Kaybı akışını göstermez.)
    func streakCoverableByFreezes(_ profile: PlayerProfile) -> Bool {
        DailyEngagement.shared.canCover(missedDays: Self.missedDays(profile))
    }

    /// Kaçırılan her gün için bir seri koruyucu harcar ve son aktif günü DÜNE çeker: seri sayısı korunur,
    /// bugün oynanınca normal şekilde bir artar. Koruyucular yetmezse hiçbir şey değişmez (Seri Kaybı akışı çıkar).
    /// Dönüş: kurtarılan gün sayısı (0 = harcanmadı).
    private func applyStreakFreezes(_ profile: inout PlayerProfile) -> Int {
        let missed = Self.missedDays(profile)
        guard missed > 0, DailyEngagement.shared.consumeFreezes(missed) else { return 0 }
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: .now)) ?? .now
        profile.lastActiveDate = yesterday.addingTimeInterval(12 * 60 * 60)
        return missed
    }

    /// Uygulama ön plana gelince (gün değişmiş olabilir) — gerekiyorsa seri koruyucuyu uygular.
    func handleBecameActive() {
        guard case .signedIn(var profile) = phase else { return }
        let covered = applyStreakFreezes(&profile)
        guard covered > 0 else { return }
        freezeNoticeDays = covered
        phase = .signedIn(profile)
        persist(profile)
    }

    func clearFreezeNotice() {
        freezeNoticeDays = nil
    }

    /// "Seri Kaybı Akışı" (bkz. Streak.swift) — "50 Puan ile Canlandır": puan düşer,
    /// `lastActiveDate` bugüne çekilir (seri sayısı korunur, artık "kayıp" sayılmaz).
    func reviveStreak() {
        guard case .signedIn(var profile) = phase, profile.points >= GameRules.streakReviveCost else { return }
        profile.points -= GameRules.streakReviveCost
        profile.lastActiveDate = .now
        phase = .signedIn(profile)
        persist(profile)
    }

    /// "Vazgeç" → "Yeniden Başla": seri sıfırlanır, bugünden itibaren yeniden sayılır.
    func restartStreak() {
        guard case .signedIn(var profile) = phase else { return }
        profile.streakDays = 0
        profile.lastActiveDate = .now
        phase = .signedIn(profile)
        persist(profile)
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
    /// Dönüş değeri: bu etapla seri 7'nin katına ulaştıysa verilen haftalık seri bonusu (yoksa 0).
    @discardableResult
    func recordStageCompletion(points: Int, completedStageKeys: Set<String>, learnedCountryCodes: Set<String>, bestPointsByStage: [String]) -> Int {
        guard case .signedIn(var profile) = phase else { return 0 }
        let bonus = advanceStreakForToday(&profile)

        profile.points = points + bonus
        profile.completedStageKeys = completedStageKeys
        profile.learnedCountryCodes = learnedCountryCodes
        profile.bestPointsByStage = bestPointsByStage

        phase = .signedIn(profile)
        persist(profile)

        // Bugün oynandığı için "yarın 19:00" hatırlatmasını yeniden planla — kullanıcı
        // Ayarlar'dan açtıysa devam eder, kapalıysa reschedule zaten no-op (bkz. Scheduler).
        let reminderEnabled = UserDefaults.standard.bool(forKey: StreakReminderScheduler.enabledDefaultsKey)
        StreakReminderScheduler.reschedule(streakDays: profile.streakDays, enabled: reminderEnabled)
        return bonus
    }

    /// Canlar bitip seviye başarısız olsa da o gün "oynandı" sayılır: seri artar/korunur. Kullanıcının en
    /// moral bozuk anında seriyi de kaybetmesi geri dönüşü zorlaştırırdı. Puan/ilerleme ETKİLENMEZ.
    /// Bugün zaten sayılmışsa hiçbir şey yazılmaz (gereksiz CloudKit save yok). Haftalık bonus çıktıysa miktarı döner.
    @discardableResult
    func recordFailedAttempt() -> Int {
        guard case .signedIn(var profile) = phase else { return 0 }
        let alreadyCountedToday = profile.streakDays > 0 && Calendar.current.isDate(profile.lastActiveDate, inSameDayAs: .now)
        guard !alreadyCountedToday else { return 0 }
        let bonus = advanceStreakForToday(&profile)
        profile.points += bonus
        phase = .signedIn(profile)
        persist(profile)
        let reminderEnabled = UserDefaults.standard.bool(forKey: StreakReminderScheduler.enabledDefaultsKey)
        StreakReminderScheduler.reschedule(streakDays: profile.streakDays, enabled: reminderEnabled)
        return bonus
    }

    /// Günlük seriyi "bugün oynandı" olarak ilerletir (recordStageCompletion ve recordFailedAttempt ortak kullanır).
    /// Seri bu çağrıyla 7'nin katına ulaştıysa haftalık bonus miktarını döner, yoksa 0.
    private func advanceStreakForToday(_ profile: inout PlayerProfile) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let last = calendar.startOfDay(for: profile.lastActiveDate)
        let daysSince = calendar.dateComponents([.day], from: last, to: today).day ?? 0

        var bonus = 0
        if profile.streakDays == 0 {
            profile.streakDays = 1 // ilk gün ya da restartStreak() sonrası yeni serinin başlangıcı
        } else if daysSince == 1 {
            profile.streakDays += 1
            bonus = GameRules.streakBonus(forStreak: profile.streakDays) // yalnızca seri ARTTIĞI gün → çift ödül olmaz
        } else if daysSince > 1 {
            // Buraya normalde StreakLossFlowView'dan geçmeden gelinmemeli, ama savunma
            // amaçlı: aradan gün(ler) geçtiyse seriyi bugünden başlat.
            profile.streakDays = 1
        }
        // daysSince <= 0 ve streakDays > 0: bugün zaten oynanmış, sayı değişmez.
        profile.lastActiveDate = .now
        return bonus
    }
}

/// Birden fazla yarışan görevden yalnızca ilkinin sonucu sayılsın diye.
private nonisolated final class OneShotGate: @unchecked Sendable {
    private let lock = NSLock()
    private var claimed = false
    func claim() -> Bool {
        lock.lock(); defer { lock.unlock() }
        if claimed { return false }
        claimed = true
        return true
    }
}
