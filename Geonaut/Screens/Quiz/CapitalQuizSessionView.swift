import SwiftUI

/// Başkentler'in tam etap oturumu — LanguageQuizSessionView ile birebir aynı akış, yalnızca
/// CapitalQuestion/CapitalQuizSession kullanır.
struct CapitalQuizSessionView: View {
    @State var session: CapitalQuizSession
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
            CapitalQuestionView(
                question: session.currentQuestion,
                questionIndex: session.currentIndex,
                totalQuestions: session.questions.count,
                hearts: session.hearts,
                onAnswer: { isCorrect in
                    answeredIndex = session.currentIndex
                    // Yazılı soruda doğru yazılış okunabilsin diye geri bildirim biraz daha uzun.
                    let typed = session.currentQuestion.typed
                    session.answer(isCorrect: isCorrect)
                    Task {
                        try? await Task.sleep(for: .milliseconds(isCorrect ? (typed ? 1100 : 700) : (typed ? 2000 : 1400)))
                        session.advance()
                    }
                },
                onBack: {
                    // İlk sorudaysa (ilerleme yok) onaysız çık; değilse onay iste.
                    if session.currentIndex > 0 { confirmingExit = true } else { onExit() }
                },
                revealAnswer: passedIndex == session.currentIndex,
                pass: GeoPassState(
                    passesLeft: session.passesLeft,
                    isRetry: session.isRetryQuestion,
                    canPass: session.canPass && answeredIndex != session.currentIndex && passedIndex != session.currentIndex,
                    hasEnoughPoints: points >= GameRules.passCost,
                    onPass: pass
                )
            )
            .id(session.currentIndex)
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
        let typed = session.currentQuestion.typed
        session.pass()
        Task {
            try? await Task.sleep(for: .milliseconds(typed ? 2000 : 1600))
            session.advance()
        }
    }
}

#Preview {
    CapitalQuizSessionView(
        session: CapitalQuizSession(stageIndex: 0, questions: Capitals.makeQuestions(forContinent: "Avrupa", stageIndex: 0)),
        points: .constant(340),
        onCompleted: { _, _ in }, onFinished: { _, _ in }, onExit: {}
    )
}
