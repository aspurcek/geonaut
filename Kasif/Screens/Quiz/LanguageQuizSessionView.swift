import SwiftUI

/// Ana Diller'in tam etap oturumu — QuizSessionView ile birebir aynı akış (bkz. o
/// dosyadaki mimari not), yalnızca LanguageQuestion/LanguageQuizSession kullanır.
struct LanguageQuizSessionView: View {
    @State var session: LanguageQuizSession
    @Binding var points: Int
    var onFinished: (_ pointsEarned: Int) -> Void
    var onExit: () -> Void

    var body: some View {
        switch session.phase {
        case .playing:
            LanguageQuestionView(
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
                onBack: onExit
            )
            .id(session.currentIndex)

        case .outOfHearts:
            OutOfHeartsView(
                currentPoints: points,
                onContinueWithPoints: {
                    points -= GameRules.heartRefillCost
                    session.refillHeartsWithPoints()
                },
                onRestartStage: { session.restart() }
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
    LanguageQuizSessionView(
        session: LanguageQuizSession(stageIndex: 0, questions: Languages.makeQuestions(forContinent: "Avrupa", stageIndex: 0)),
        points: .constant(340),
        onFinished: { _ in }, onExit: {}
    )
}
