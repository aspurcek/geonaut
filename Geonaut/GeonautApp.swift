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
        case "reminder": ReminderPromptSheet(streakDays: 3, onAccept: {}, onDecline: {})
        case "learnfoods": LearnFoodsView(onBack: {})
        case "learncontinents": LearnContinentsView(onBack: {})
        case "capq_flagname": debugCapitalQuestion(.flagWithNameToCapital, ["Berlin", "Paris", "Roma", "Madrid"], "Berlin")
        case "capq_flag": debugCapitalQuestion(.flagToCapital, ["Berlin", "Paris", "Roma", "Madrid"], "Berlin")
        case "capq_map": debugCapitalQuestion(.mapToCapital, ["Berlin", "Paris", "Roma", "Madrid"], "Berlin")
        case "capq_country": debugCapitalQuestion(.capitalToCountry, ["Almanya", "Fransa", "İtalya", "İspanya"], "Almanya")
        case "capq_flags": debugCapitalQuestion(.capitalToFlag, ["DE", "FR", "IT", "ES"], "DE")
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
                onDeleteAccount: { appState.signOut(); return true }
            )

        case .signedIn(let profile):
            // Seri koptuysa (bkz. Streak.swift), Ana Sayfa'nın önüne Seri Kaybı Akışı
            // geçer — kullanıcı canlandırıp/vazgeçip normal uygulamaya döner.
            let lost = StreakStatus.compute(lastActiveDate: profile.lastActiveDate, streakDays: profile.streakDays) == .lost
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
                    onDeleteAccount: { await appState.deleteAccount() }
                )
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
