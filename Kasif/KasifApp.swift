//
//  KasifApp.swift
//  Kasif
//
//  Created by Aspurçe on 10.09.2026.
//

import SwiftUI

@main
struct KasifApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView(appState: appState)
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
                KasifColor.bgCanvas.ignoresSafeArea()
                ProgressView()
                    .tint(KasifColor.accentPrimary)
            }

        case .signedOut:
            OnboardingView(
                onContinueWithApple: { appState.signInWithApple() },
                onTryAsGuest: { appState.enterGuestMode() }
            )
                #if DEBUG
                .safeAreaInset(edge: .bottom) {
                    Button("DEBUG: Tam profille devam et") { appState.signInAsDebugGuest() }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, KasifSpacing.lg)
                        .background(Color.red)
                }
                #endif

        case .guest:
            RootTabView(
                profile: .newPlayer(appleUserIdentifier: "guest", displayName: "Kaşif"),
                isGuest: true,
                onRequireSignIn: { appState.signInWithApple() }
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
                    profile: profile,
                    onSaveSettings: { displayName, avatarColorHex in
                        appState.updateProfile(displayName: displayName, avatarColorHex: avatarColorHex)
                    },
                    onStageCompleted: { points, completedStageKeys, learnedCountryCodes, bestPointsByStage in
                        appState.recordStageCompletion(points: points, completedStageKeys: completedStageKeys, learnedCountryCodes: learnedCountryCodes, bestPointsByStage: bestPointsByStage)
                    }
                )
            }

        case .error(let message):
            VStack(spacing: KasifSpacing.lg) {
                Text("Bir şeyler ters gitti")
                    .font(KasifTypography.headingM)
                Text(message)
                    .font(KasifTypography.bodySemibold)
                    .foregroundStyle(KasifColor.textSecondary)
                    .multilineTextAlignment(.center)
                Button("Tekrar Dene") { appState.signInWithApple() }
                    .buttonStyle(.kasifPrimary)
            }
            .padding(KasifSpacing.xxxl)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(KasifColor.bgCanvas)
        }
    }
}
