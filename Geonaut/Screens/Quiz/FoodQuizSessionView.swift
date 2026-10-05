import SwiftUI

/// Dünya Yemekleri'nin tam etap oturumu — QuizSessionView/LanguageQuizSessionView ile
/// birebir aynı akış (bkz. o dosyalardaki mimari not), yalnızca FoodQuestion/FoodQuizSession kullanır.
struct FoodQuizSessionView: View {
    @State var session: FoodQuizSession
    @Binding var points: Int
    var onFinished: (_ pointsEarned: Int) -> Void
    var onExit: () -> Void
    /// Seviye yarıdayken çıkış onayı (bkz. GeoExitConfirmation).
    @State private var confirmingExit = false

    var body: some View {
        switch session.phase {
        case .playing:
            FoodQuestionView(
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
    FoodQuizSessionView(
        session: FoodQuizSession(stageIndex: 0, questions: WorldFoods.makeQuestions(forSection: "Yemekler", stageIndex: 0)),
        points: .constant(340),
        onFinished: { _ in }, onExit: {}
    )
}
