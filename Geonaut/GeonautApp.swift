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

    var body: some Scene {
        WindowGroup {
            RootView(appState: appState)
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

    var body: some View {
        switch appState.phase {
        case .checkingExistingSession, .signingIn, .loadingProfile:
            ZStack {
                GeoColor.bgCanvas.ignoresSafeArea()
                GeoStatusView(style: .loading, title: "Yükleniyor…", subtitle: "Dünyanı hazırlıyoruz.")
            }

        case .signedOut:
            OnboardingView(
                onContinueWithApple: { appState.signInWithApple() },
                onTryAsGuest: { appState.enterGuestMode() },
                onDemoLogin: { appState.enterDemoMode() }
            )
                #if DEBUG
                .onAppear {
                    // `-debugSignIn 1` ile başlat: ekran görüntüsü almak için otomatik giriş.
                    if UserDefaults.standard.bool(forKey: "debugSignIn") { appState.signInAsDebugGuest() }
                }
                .safeAreaInset(edge: .bottom) {
                    Button("DEBUG: Tam profille devam et") { appState.signInAsDebugGuest() }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, GeoSpacing.lg)
                        .background(Color.red)
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
                        appState.recordStageCompletion(points: points, completedStageKeys: completedStageKeys, learnedCountryCodes: learnedCountryCodes, bestPointsByStage: bestPointsByStage)
                    },
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
