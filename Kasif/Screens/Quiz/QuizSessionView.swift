import SwiftUI

/// Bir etabın tam oturumu: Soru ekranları → (can biterse) Canların Bitti → (biterse)
/// Etap Tamamlandı. Bkz. GameRules ve QuizSession.
struct QuizSessionView: View {
    @State var session: QuizSession
    var onFinished: (_ pointsEarned: Int) -> Void
    var onExit: () -> Void

    var body: some View {
        switch session.phase {
        case .playing:
            QuestionView(
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
                currentPoints: session.pointsEarnedThisSession,
                onContinueWithPoints: { session.refillHeartsWithPoints() },
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
    QuizSessionView(
        session: QuizSession(stageIndex: 0, questions: Countries.makeQuestions(from: Countries.europe, isRecall: false)),
        onFinished: { _ in }, onExit: {}
    )
}
