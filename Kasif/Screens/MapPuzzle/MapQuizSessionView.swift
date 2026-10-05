import SwiftUI

/// Harita Bilmece etabının tam oturumu — QuizSessionView ile aynı akış (bkz. Harita
/// Bilmece Kural Kitabı böl. 06: can/puan/yıldız mekaniği Bayrak Tahmin ile birebir aynı).
struct MapQuizSessionView: View {
    @State var session: MapQuizSession
    /// Oyuncunun gerçek toplam puanı — bkz. QuizSessionView'daki aynı gerekçe.
    @Binding var points: Int
    var onFinished: (_ pointsEarned: Int) -> Void
    var onExit: () -> Void
    /// Seviye yarıdayken çıkış onayı (bkz. KasifExitConfirmation).
    @State private var confirmingExit = false

    var body: some View {
        switch session.phase {
        case .playing:
            MapQuestionView(
                question: session.currentQuestion,
                questionIndex: session.currentIndex,
                totalQuestions: session.questions.count,
                hearts: session.hearts,
                onAnswer: { isCorrect in
                    session.answer(isCorrect: isCorrect)
                    Task {
                        try? await Task.sleep(for: .milliseconds(isCorrect ? 700 : 1400))
                        session.advance()
                    }
                },
                onBack: {
                    // İlk sorudaysa (ilerleme yok) onaysız çık; değilse onay iste.
                    if session.currentIndex > 0 { confirmingExit = true } else { onExit() }
                }
            )
            .id(session.currentIndex)
            .exitConfirmation(isPresented: $confirmingExit, onExit: onExit)

        case .outOfHearts:
            OutOfHeartsView(
                currentPoints: points,
                onContinueWithPoints: {
                    points -= GameRules.heartRefillCost
                    session.refillHeartsWithPoints()
                },
                onRestartStage: { session.restart() },
                onExit: onExit
            )

        case .completed:
            StageCompleteView(
                stageIndex: session.stageIndex,
                correctCount: session.correctCount,
                pointsEarned: session.pointsEarnedThisSession,
                heartsRemaining: session.hearts,
                onContinue: { onFinished(session.pointsEarnedThisSession) }
            )
        }
    }
}

#Preview {
    MapQuizSessionView(
        session: MapQuizSession(stageIndex: 0, questions: MapQuizGenerator.makeQuestions(stageIndex: 0)),
        points: .constant(340),
        onFinished: { _ in }, onExit: {}
    )
}
