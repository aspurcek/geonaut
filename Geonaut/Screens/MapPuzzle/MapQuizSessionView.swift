import SwiftUI

/// Harita Bilmece etabının tam oturumu — QuizSessionView ile aynı akış (bkz. Harita
/// Bilmece Kural Kitabı böl. 06: can/puan/yıldız mekaniği Bayrak Tahmin ile birebir aynı).
struct MapQuizSessionView: View {
    @State var session: MapQuizSession
    /// Oyuncunun gerçek toplam puanı — bkz. QuizSessionView'daki aynı gerekçe.
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
            .onAppear(perform: onFailed)

        case .completed:
            StageCompleteView(
                stageIndex: session.stageIndex,
                correctCount: session.correctCount,
                pointsEarned: session.pointsEarnedThisSession,
                heartsRemaining: session.hearts,
                onContinue: { onFinished(session.pointsEarnedThisSession, session.questions.map { $0.country.code }) }
            )
            .onAppear {
                guard !didReportCompletion else { return }
                didReportCompletion = true
                onCompleted(session.pointsEarnedThisSession, session.questions.map { $0.country.code })
            }
        }
    }
}

#Preview {
    MapQuizSessionView(
        session: MapQuizSession(stageIndex: 0, questions: MapQuizGenerator.makeQuestions(stageIndex: 0)),
        points: .constant(340),
        onCompleted: { _, _ in }, onFinished: { _, _ in }, onExit: {}
    )
}
