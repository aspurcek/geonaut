import SwiftUI

/// Harita Bilmece etabının tam oturumu — QuizSessionView ile aynı akış (bkz. Harita
/// Bilmece Kural Kitabı böl. 06: can/puan/yıldız mekaniği Bayrak Tahmin ile birebir aynı).
struct MapQuizSessionView: View {
    @State var session: MapQuizSession
    var onFinished: (_ pointsEarned: Int) -> Void
    var onExit: () -> Void

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
    MapQuizSessionView(
        session: MapQuizSession(stageIndex: 0, questions: MapQuizGenerator.makeQuestions(stageIndex: 0)),
        onFinished: { _ in }, onExit: {}
    )
}
