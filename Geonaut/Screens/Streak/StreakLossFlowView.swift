import SwiftUI

/// Seri koptuğunda uygulama açılışında Ana Sayfa'nın önüne geçen akış — bkz. Figma
/// "FLOW4- Seri Kaybı Akışı" (node 508:11954). Kullanıcı ya 50 puanla canlandırır ya
/// da "Vazgeç" deyip seriyi sıfırlar; her iki durumda da `onDone` ile normal uygulamaya
/// dönülür (profil zaten AppState tarafından güncellenmiş olur).
struct StreakLossFlowView: View {
    var onRevive: () -> Void
    var onRestart: () -> Void
    var onDone: () -> Void

    // streakDays/points bilerek @State ile "donduruluyor": bu view ekranda kaldığı
    // sürece (RootView onu isHandlingStreakLoss ile canlı tutuyor), onRevive/onRestart
    // AppState'teki profili değiştirse bile (puan düşer, lastActiveDate güncellenir)
    // burada gösterilen sayılar akış bitene kadar ilk değerinde kalmalı — yoksa
    // "canlandırıldı" ekranındaki "kalan puan" hesabı ikinci kez düşülmüş görünür.
    @State private var streakDays: Int
    @State private var points: Int
    private enum Phase { case askRevive, revived, giveUp }
    @State private var phase: Phase = .askRevive

    init(streakDays: Int, points: Int, onRevive: @escaping () -> Void, onRestart: @escaping () -> Void, onDone: @escaping () -> Void) {
        _streakDays = State(initialValue: streakDays)
        _points = State(initialValue: points)
        self.onRevive = onRevive
        self.onRestart = onRestart
        self.onDone = onDone
    }

    var body: some View {
        switch phase {
        case .askRevive:
            StreakLostView(
                streakDays: streakDays, points: points,
                onRevive: {
                    onRevive()
                    phase = .revived
                },
                onGiveUp: { phase = .giveUp }
            )

        case .revived:
            StreakRevivedView(
                streakDays: streakDays,
                pointsSpent: GameRules.streakReviveCost,
                pointsRemaining: points - GameRules.streakReviveCost,
                onContinue: onDone
            )

        case .giveUp:
            StreakRestartView(streakDays: streakDays, onRestart: {
                onRestart()
                onDone()
            })
        }
    }
}

#Preview {
    StreakLossFlowView(streakDays: 12, points: 340, onRevive: {}, onRestart: {}, onDone: {})
}
