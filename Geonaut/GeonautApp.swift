//
//  GeonautApp.swift
//  Geonaut
//
//  Created by Aspurçe on 10.09.2026.
//

import SwiftUI

@main
struct GeonautApp: App {
    @State private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        #if DEBUG
        if UserDefaults.standard.bool(forKey: "debugCardsCheck") { StageCards.debugSelfCheck() }
        if UserDefaults.standard.bool(forKey: "debugDailyCheck") { DailyEngagement.debugSelfCheck() }
        #endif
    }

    #if DEBUG
    private func debugCapitalQuestion(_ format: CapitalQuestion.Format, _ options: [String], _ correct: String) -> some View {
        CapitalQuestionView(
            question: CapitalQuestion(format: format, countryCode: "DE", countryName: "Almanya", capitalName: "Berlin", options: options, correct: correct),
            questionIndex: 3, totalQuestions: 10, hearts: 5, onAnswer: { _ in }, onBack: {}
        )
    }
    #endif

    @ViewBuilder private var debugOrRoot: some View {
        #if DEBUG
        // `-debugScreen hearts|streaklost|reminder|learnfoods|learncontinents|capq_*`: tek tek ekranları doğrudan göster (ekran görüntüsü/test için).
        switch UserDefaults.standard.string(forKey: "debugScreen") {
        case "hearts": OutOfHeartsView(currentPoints: 340, correctCount: 6, onContinueWithPoints: {}, onRestartStage: {})
        case "streaklost": StreakLostView(streakDays: 12, points: 340, onRevive: {}, onGiveUp: {})
        // Ayarlar (hesap silme görünürlüğü, App Review 2026-11-17).
        case "settings":
            SettingsView(displayName: "Kaşif", email: "ornek@example.com", avatarColorHex: 0xF0D777, character: AvatarCharacter(),
                         streakDays: 3, onBack: {}, onEditAvatar: {}, onSave: { _ in }, onSignOut: {},
                         onDeleteAccount: { true }, onOpenCredits: {})
        // Düello seviye şartı uyarısı (kullanıcı kararı 2026-11-19).
        case "firstlevel":
            GeoColor.bgCanvas.ignoresSafeArea()
                .firstLevelRequiredAlert()
                .onAppear { DuelManager.shared.showFirstLevelRequired = true }
        // TikTok tanıtım videosu (kullanıcı isteği 2026-11-19): `promo` canlı, `promoexport` MP4 yazar.
        case "carousels": CarouselsDebugScreen()
        case "promo": PromoDebugScreen(export: false)
        case "promoexport": PromoDebugScreen(export: true)
        case "reminder": ReminderPromptSheet(streakDays: 3, onAccept: {}, onDecline: {})
        case "learnfoods": LearnFoodsView(onBack: {})
        case "foodcard":
            Color.white.foodInfoSheet(selected: .constant(FoodCardInfo(code: "ES", name: Countries.all.first { $0.code == "ES" }?.name ?? "İspanya", dish: "Paella", dessert: "Churros", drink: "Portakal Suyu")))
        // Pas çubuğu: kartsız doğrudan bir Başkentler seviyesi (`-debugScreen passbar`).
        case "passbar":
            CapitalQuizSessionView(
                session: CapitalQuizSession(stageIndex: 0, questions: Capitals.makeQuestions(forContinent: "Avrupa", stageIndex: 0)),
                points: .constant(340),
                onCompleted: { _, _ in }, onFinished: { _, _ in }, onExit: {}
            )
        case "friends":
            ScrollView { FriendsSection(myPoints: 1240).padding(.horizontal, GeoSpacing.xl).padding(.top, 80) }
                .background(GeoColor.bgCanvas)
        // Düello ekranları (bot rakiple, Game Center'sız): friendsfull | duelintro | duelplay | duelresult_won/lost/tied
        case "friendsfull":
            FriendsView(me: DuelPlayerInfo(id: "me", name: "Test", avatarColorHex: 0xF0D777, character: AvatarCharacter(hairStyle: .kivircik, accessory: .gozluk)),
                        myCategories: ["flags", "capitals", "languages"], myPoints: 980, onBack: {})
        case "duelintro", "duelplay":
            let manager = DuelManager.shared
            let _ = { manager.me = DuelPlayerInfo(id: "me", name: "Test", avatarColorHex: 0xF0D777, character: AvatarCharacter(hairStyle: .kivircik, accessory: .gozluk)); manager.myCategories = ["flags", "capitals", "languages", "foods"] }()
            let context = manager.startBotDuel()
            if UserDefaults.standard.string(forKey: "debugScreen") == "duelplay" {
                DuelPlayView(context: context, onFinished: { _ in })
            } else {
                DuelIntroView(context: context, onBack: {}, onStart: {})
            }
        case "duelresult_won", "duelresult_lost", "duelresult_tied":
            let outcome: DuelOutcome = UserDefaults.standard.string(forKey: "debugScreen") == "duelresult_won" ? .won : (UserDefaults.standard.string(forKey: "debugScreen") == "duelresult_lost" ? .lost : .tied)
            let mine = DuelResult(answers: Array(repeating: true, count: outcome == .lost ? 6 : (outcome == .tied ? 7 : 8)) + Array(repeating: false, count: outcome == .lost ? 4 : (outcome == .tied ? 3 : 2)), totalMilliseconds: 60_000)
            let theirs = DuelResult(answers: Array(repeating: true, count: outcome == .won ? 6 : (outcome == .tied ? 7 : 8)) + Array(repeating: false, count: outcome == .won ? 4 : (outcome == .tied ? 3 : 2)), totalMilliseconds: 60_000)
            DuelResultView(result: .init(id: "d", me: DuelPlayerInfo(id: "me", name: "Test", avatarColorHex: 0xF0D777, character: AvatarCharacter(hairStyle: .kivircik, accessory: .gozluk)),
                                         opponent: DuelPlayerInfo(id: "o", name: "Ayşe", avatarColorHex: 0x9ED3F2, character: AvatarCharacter(skinTone: .bugday, hairStyle: .uzun, hairColorHex: 0xC09910)),
                                         myResult: mine, theirResult: theirs, outcome: outcome, opponentID: "o", isBot: true),
                           onRematch: {}, onBack: {})
        case "capitalcard":
            Color.white.countryInfoSheet(selected: .constant(CountryCardInfo(code: "DE", name: Countries.all.first { $0.code == "DE" }?.name ?? "Almanya", language: "Almanca", continent: "Avrupa", capital: "Berlin")))
        case "learnflags": LearnFlagsView(onBack: {})
        case "learncapitals": LearnCapitalsView(onBack: {})
        case "learnlanguages": LearnLanguagesView(onBack: {})
        case "learncontinents": LearnContinentsView(onBack: {})
        case "capq_flagname": debugCapitalQuestion(.flagWithNameToCapital, ["Berlin", "Paris", "Roma", "Madrid"], "Berlin")
        case "capq_flag": debugCapitalQuestion(.flagToCapital, ["Berlin", "Paris", "Roma", "Madrid"], "Berlin")
        case "capq_map": debugCapitalQuestion(.mapToCapital, ["Berlin", "Paris", "Roma", "Madrid"], "Berlin")
        case "capq_country": debugCapitalQuestion(.capitalToCountry, ["Almanya", "Fransa", "İtalya", "İspanya"], "Almanya")
        case "capq_flags": debugCapitalQuestion(.capitalToFlag, ["DE", "FR", "IT", "ES"], "DE")
        // 1.0.3: hatasız seviye + günlük haber kartı / kombo rozeti (bellek içi test hesabı, kayıt yazmaz).
        case "stagecomplete", "stagecomplete_full":
            StageCompleteView(stageIndex: 2, correctCount: 10, pointsEarned: 100, heartsRemaining: 5, onContinue: {})
                .onAppear { DailyEngagement.shared.debugSimulateDay(freezesBefore: UserDefaults.standard.string(forKey: "debugScreen") == "stagecomplete_full" ? 2 : 0) }
        // Günlük hedef kartı/sayfası: `daily` (yolda), `daily_done` (hedef tamam), `daily_sheet`, `daily_sheet_done`.
        case "daily", "daily_done", "daily_sheet", "daily_sheet_done", "goalprompt":
            DailyDebugScreen(variant: UserDefaults.standard.string(forKey: "debugScreen") ?? "daily")
        // Avatar düzenleyici (2026-11-14 tasarımı).
        case "avatar":
            AvatarBuilderView(avatarColorHex: 0xF0D777, character: AvatarCharacter(hairStyle: .kivircik, accessory: .gozluk), onBack: {}, onSave: { _, _ in })
        case "avatars":
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], spacing: 16) {
                    ForEach(0..<15, id: \.self) { n in
                        let tones = SkinTone.allCases, hairs = HairStyle.allCases
                        GeoAvatar(backgroundColor: GeoColor.avatarSwatches[n % 6].color,
                                  character: AvatarCharacter(skinTone: tones[n % 4], hairStyle: hairs[n % 5],
                                                             hairColorHex: GeoHairColor.options[(n * 5) % 6].hex,
                                                             accessory: n % 3 == 2 ? nil : AvatarAccessory.allCases[n % 4],
                                                             facialFeature: n % 2 == 1 ? AvatarFacialFeature.allCases[n % 3] : nil))
                    }
                }
                .padding(.top, 60).padding(.horizontal)
            }
            .background(GeoColor.bgCanvas)
        case "combo":
            OutOfHeartsView(currentPoints: 340, correctCount: 6, onContinueWithPoints: {}, onRestartStage: {})
                .task {
                    for n in 1...6 {
                        try? await Task.sleep(for: .seconds(1.2))
                        RewardFlash.shared.trigger(combo: n + 2)
                    }
                }
        default: RootView(appState: appState)
        }
        #else
        RootView(appState: appState)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            debugOrRoot
                // iPad: arayüz telefon genişliğinde tasarlandı, o yüzden geniş ekranda
                // uzayıp bozulmaması için ortalanmış bir sütun olarak gösteriliyor —
                // ama artık iPad'de iPhone'dan daha geniş bir sütun (bkz.
                // GeoLayout.columnMaxWidth): kategori kartları, rozet ızgarası gibi
                // kendi kendine sarmalanan (flow) bileşenler bu sayede iPad'de daha
                // fazla öğeyi tek satırda/ekranda gösterebiliyor (iPhone'da maxWidth etkisiz).
                .frame(maxWidth: GeoLayout.columnMaxWidth)
                .frame(maxWidth: .infinity)
                .background(GeoColor.bgCanvas.ignoresSafeArea())
                // Tasarım yalnızca açık (krem) tema için hazırlandı: sabit renkli zeminlerde
                // koyu moddaki sistem metin renkleri okunmaz hâle gelirdi — her zaman açık tema.
                .preferredColorScheme(.light)
                .overlay { RewardFloatOverlay() }
                .task { appState.start() }
                // Uygulama arka plandan dönünce gün değişmiş olabilir: seri koruyucu gerekiyorsa devreye girer.
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        appState.handleBecameActive()
                        // Arkadaşın sırasını oynamış olabilir: düello listesini tazele (bağlı değilse no-op).
                        Task { await DuelManager.shared.refresh() }
                        // Uygulama öne gelince App Store'da yeni sürüm var mı (günde en fazla bir kez).
                        Task { await AppUpdateChecker.shared.checkIfNeeded() }
                    }
                }
        }
    }
}

/// Kimlik doğrulama durumuna göre Onboarding/yükleniyor/ana uygulama arasında geçer.
private struct RootView: View {
    var appState: AppState
    // Akış başladıktan sonra (canlandır/vazgeç ile) profil değişip StreakStatus artık
    // "lost" dönmese bile, kullanıcı "Devam Et"/"Yeniden Başla"ya basana kadar akışı
    // ekranda tutar — bkz. StreakLossFlowView'ın kendi @State'iyle dondurduğu sayılar.
    @State private var isHandlingStreakLoss = false
    /// İlk açılışta 3 sayfalık tanıtım (IntroView) bir kez gösterilir; sonra doğrudan giriş ekranı.
    @AppStorage("geonaut.hasSeenIntro") private var hasSeenIntro = false

    var body: some View {
        switch appState.phase {
        case .checkingExistingSession, .signingIn, .loadingProfile:
            ZStack {
                GeoColor.bgCanvas.ignoresSafeArea()
                GeoStatusView(style: .loading, title: "Yükleniyor…", subtitle: "Dünyanı hazırlıyoruz.")
            }

        case .signedOut:
            Group {
                if hasSeenIntro {
                    OnboardingView(
                        onContinueWithApple: { appState.signInWithApple() },
                        onTryAsGuest: { appState.enterGuestMode() },
                        onDemoLogin: { appState.enterDemoMode() }
                    )
                    #if DEBUG
                    .safeAreaInset(edge: .bottom) {
                        Button("DEBUG: Tam profille devam et") { appState.signInAsDebugGuest() }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, GeoSpacing.lg)
                            .background(Color.red)
                    }
                    #endif
                } else {
                    IntroView(
                        onFinish: { hasSeenIntro = true },
                        onTryAsGuest: { hasSeenIntro = true; appState.enterGuestMode() }
                    )
                }
            }
                #if DEBUG
                .onAppear {
                    // `-debugIntro 1`: tanıtımı (IntroView) yeniden göster.
                    if UserDefaults.standard.bool(forKey: "debugIntro") { hasSeenIntro = false }
                    // `-debugSignIn 1` ile başlat: ekran görüntüsü almak için otomatik giriş.
                    if UserDefaults.standard.bool(forKey: "debugSignIn") { appState.signInAsDebugGuest() }
                    // `-debugPhase demo|guest`: demo girişi / misafir deneme akışını doğrudan aç.
                    switch UserDefaults.standard.string(forKey: "debugPhase") {
                    case "demo": appState.enterDemoMode()
                    case "guest": appState.enterGuestMode()
                    default: break
                    }
                }
                #endif

        case .guest:
            // Deneme modu: yalnızca Bayraklar › Avrupa › 1. seviye oynanır, Kupalar/Profil kilitli.
            RootTabView(
                profile: .newPlayer(appleUserIdentifier: "guest", displayName: String(localized: "Geonaut")),
                isGuest: true,
                onRequireSignIn: { appState.signInWithApple() },
                onSignOut: { appState.signOut() },
                onDeleteAccount: { appState.signOut(); return true }
            )

        case .demo:
            // Demo girişi (App Review/tanıtım): tüm özellikler ve kilitler açık. İlerleme yalnızca bu
            // oturumda tutulur, buluta yazılmaz.
            let demoProfile: PlayerProfile = {
                var p = PlayerProfile.newPlayer(appleUserIdentifier: "demo", displayName: String(localized: "Geonaut"))
                p.completedStageKeys = GameProgress.allStageKeys
                // Her etap tam puanla bitmiş sayılır — seviye (ömür boyu puandan) ve "öğrenilen ülke"
                // sayısı tüm kilitlerin açık olduğuyla tutarlı görünsün (bkz. GeoLevel).
                let fullStagePoints = GameRules.questionsPerStage * GameRules.pointsPerCorrectAnswer
                p.bestPointsByStage = GameProgress.allStageKeys.sorted().map { "\($0)=\(fullStagePoints)" }
                p.learnedCountryCodes = Set(Countries.all.map(\.code))
                return p
            }()
            RootTabView(
                profile: demoProfile,
                onSignOut: { appState.signOut() },
                // Demo: bulutta hiçbir şey yok; cihazdaki demo günlük kaydı silinir ve çıkış yapılır.
                onDeleteAccount: { DailyEngagement.shared.deleteStoredData(accountKey: "demo"); appState.signOut(); return true }
            )

        case .signedIn(let profile):
            // Seri koptuysa (bkz. Streak.swift), Ana Sayfa'nın önüne Seri Kaybı Akışı
            // geçer — kullanıcı canlandırıp/vazgeçip normal uygulamaya döner.
            // Seri koruyucu yetiyorsa akış hiç açılmaz; koruyucu RootTabView görünür görünmez uygulanır.
            let status = StreakStatus.compute(lastActiveDate: profile.lastActiveDate, streakDays: profile.streakDays)
            let coverable = status == .lost && appState.streakCoverableByFreezes(profile)
            let lost = status == .lost && !coverable
            if isHandlingStreakLoss || lost {
                StreakLossFlowView(
                    streakDays: profile.streakDays,
                    points: profile.points,
                    onRevive: { appState.reviveStreak() },
                    onRestart: { appState.restartStreak() },
                    onDone: { isHandlingStreakLoss = false }
                )
                .onAppear { isHandlingStreakLoss = true }
            } else {
                RootTabView(
                    profile: profile, cloudReachable: appState.cloudReachable, cloudAccountMissing: appState.cloudAccountMissing,
                    onSaveSettings: { displayName in
                        appState.updateProfile(displayName: displayName)
                    },
                    onSaveAvatar: { avatarColorHex, character in
                        appState.updateAvatar(avatarColorHex: avatarColorHex, character: character)
                    },
                    onStageCompleted: { points, completedStageKeys, learnedCountryCodes, bestPointsByStage in
                        return appState.recordStageCompletion(points: points, completedStageKeys: completedStageKeys, learnedCountryCodes: learnedCountryCodes, bestPointsByStage: bestPointsByStage)
                    },
                    onSessionFailed: { appState.recordFailedAttempt() },
                    onSignOut: { appState.signOut() },
                    onDeleteAccount: { await appState.deleteAccount() },
                    freezeNoticeDays: appState.freezeNoticeDays,
                    onDismissFreezeNotice: { appState.clearFreezeNotice() },
                    onAwardPoints: { appState.awardPoints($0) }
                )
                .task(id: coverable) {
                    if coverable { appState.handleBecameActive() }
                }
            }

        case .error(let message):
            GeoStatusView(
                style: .error, title: "Bir şeyler ters gitti", subtitle: message,
                actionTitle: "Tekrar Dene", action: { appState.signInWithApple() }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GeoColor.bgCanvas)
        }
    }
}
