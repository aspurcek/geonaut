import SwiftUI

/// Ana Diller'in tam etap oturumu — QuizSessionView ile birebir aynı akış (bkz. o
/// dosyadaki mimari not), yalnızca LanguageQuestion/LanguageQuizSession kullanır.
struct LanguageQuizSessionView: View {
    @State var session: LanguageQuizSession
    @Binding var points: Int
    /// Seviye bitince: kazanılan puan + bu oturumda GERÇEKTEN sorulan ülke kodları (öğrenilen ülke
    /// istatistiği için — ebeveynin yeniden ürettiği ayrı bir soru listesi değil).
    var onFinished: (_ pointsEarned: Int, _ countryCodes: [String]) -> Void
    var onExit: () -> Void
    /// Seviye yarıdayken çıkış onayı (bkz. GeoExitConfirmation).
    @State private var confirmingExit = false

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
                onContinue: { onFinished(session.pointsEarnedThisSession, session.questions.map(\.countryCode)) }
            )
        }
    }
}

#Preview {
    LanguageQuizSessionView(
        session: LanguageQuizSession(stageIndex: 0, questions: Languages.makeQuestions(forContinent: "Avrupa", stageIndex: 0)),
        points: .constant(340),
        onFinished: { _, _ in }, onExit: {}
    )
}
