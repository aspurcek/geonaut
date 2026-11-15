import SwiftUI

/// Ana Diller'in tam etap oturumu — QuizSessionView ile birebir aynı akış (bkz. o
/// dosyadaki mimari not), yalnızca LanguageQuestion/LanguageQuizSession kullanır.
struct LanguageQuizSessionView: View {
    @State var session: LanguageQuizSession
    @Binding var points: Int
    /// Seviye bitince: kazanılan puan + bu oturumda GERÇEKTEN sorulan ülke kodları (öğrenilen ülke
    /// istatistiği için — ebeveynin yeniden ürettiği ayrı bir soru listesi değil).
    /// Seviye BİTTİĞİ AN (tamamlanma ekranı açılınca) bir kez çağrılır: puan/ilerleme burada kaydedilir,
    /// böylece oyuncu \"Devam\"a basmadan uygulamayı kapatsa da kayıt kaybolmaz. `onFinished` yalnızca yönlendirir.
    var onCompleted: (_ pointsEarned: Int, _ countryCodes: [String]) -> Void
    var onFinished: (_ pointsEarned: Int, _ countryCodes: [String]) -> Void
    var onExit: () -> Void
    /// Canlar bitince (seviye başarısız) çağrılır — o gün yine de "oynandı" sayılsın, seri bozulmasın.
    var onFailed: () -> Void = {}
    /// Seviye yarıdayken çıkış onayı (bkz. GeoExitConfirmation).
    @State private var confirmingExit = false
    @State private var didReportCompletion = false
    /// Pas: hangi soruda pas geçildi / cevaplandı (pas düğmesini kapatmak için).
    @State private var passedIndex: Int?
    @State private var answeredIndex: Int?

    var body: some View {
        switch session.phase {
        case .playing:
            LanguageQuestionView(
                question: session.currentQuestion,
                questionIndex: session.currentIndex,
                totalQuestions: session.questions.count,
                hearts: session.hearts,
                onAnswer: { isCorrect in
                    answeredIndex = session.currentIndex
                    session.answer(isCorrect: isCorrect)
                    Task {
                        try? await Task.sleep(for: .milliseconds(isCorrect ? 700 : 1400))
                        session.advance()
                    }
                },
                onBack: {
                    // İlk sorudaysa (ilerleme yok) onaysız çık; değilse onay iste.
                    if session.currentIndex > 0 { confirmingExit = true } else { onExit() }
                },
                revealAnswer: passedIndex == session.currentIndex
            )
            .id(session.currentIndex)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                GeoPassBar(
                    passesLeft: session.passesLeft,
                    isRetry: session.isRetryQuestion,
                    canPass: session.canPass && answeredIndex != session.currentIndex && passedIndex != session.currentIndex,
                    hasEnoughPoints: points >= GameRules.passCost,
                    onPass: pass
                )
            }
            .exitConfirmation(isPresented: $confirmingExit, onExit: onExit)

        case .outOfHearts:
            OutOfHeartsView(
                currentPoints: points,
                correctCount: session.correctCount,
                totalQuestions: session.baseCount,
                onContinueWithPoints: {
                    points -= GameRules.heartRefillCost
                    session.refillHeartsWithPoints()
                },
                onRestartStage: { session.restart() },
                onExit: onExit
            )
            .onAppear(perform: onFailed)

        case .completed:
            StageCompleteView(
                stageIndex: session.stageIndex,
                correctCount: session.correctCount,
                totalQuestions: session.baseCount,
                pointsEarned: session.pointsEarnedThisSession,
                heartsRemaining: session.hearts,
                onContinue: { onFinished(session.pointsEarnedThisSession, session.questions.prefix(session.baseCount).map(\.countryCode)) }
            )
            .onAppear {
                guard !didReportCompletion else { return }
                didReportCompletion = true
                onCompleted(session.pointsEarnedThisSession, session.questions.prefix(session.baseCount).map(\.countryCode))
            }
        }
    }

    /// Pas geç: puan düşer, doğru cevap gösterilir, kısa süre sonra sıradaki soruya geçilir.
    private func pass() {
        guard session.canPass, points >= GameRules.passCost,
              answeredIndex != session.currentIndex, passedIndex != session.currentIndex else { return }
        points -= GameRules.passCost
        passedIndex = session.currentIndex
        session.pass()
        Task {
            try? await Task.sleep(for: .milliseconds(1600))
            session.advance()
        }
    }
}

#Preview {
    LanguageQuizSessionView(
        session: LanguageQuizSession(stageIndex: 0, questions: Languages.makeQuestions(forContinent: "Avrupa", stageIndex: 0)),
        points: .constant(340),
        onCompleted: { _, _ in }, onFinished: { _, _ in }, onExit: {}
    )
}
