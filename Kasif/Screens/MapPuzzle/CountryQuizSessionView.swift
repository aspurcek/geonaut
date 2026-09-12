import SwiftUI

/// Harita Bilmece "Ülkeler" etabının tam oturumu — MapQuizSessionView ile aynı akış
/// (bkz. Harita Bilmece Kural Kitabı böl. 06: can/puan/yıldız mekaniği tüm oturumlarda birebir aynı).
struct CountryQuizSessionView: View {
    @State var session: CountryQuizSession
    var onFinished: (_ pointsEarned: Int) -> Void
    var onExit: () -> Void

    var body: some View {
        switch session.phase {
        case .playing:
            CountryQuestionView(
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
    CountryQuizSessionView(
        session: CountryQuizSession(stageIndex: 0, questions: CountryQuizGenerator.makeQuestions(stageIndex: 0)),
        onFinished: { _ in }, onExit: {}
    )
}
