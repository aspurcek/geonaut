import SwiftUI

/// Tek bir etap oturumunun durumu — can/puan/soru ilerlemesi. Kurallar GameRules'tan
/// gelir (bkz. Bayrak Tahmin Kural Kitabı böl. 04-06).
@Observable
final class QuizSession {
    let stageIndex: Int
    private(set) var questions: [FlagQuestion]
    private(set) var currentIndex = 0
    private(set) var hearts = GameRules.startingHeartsPerSession
    private(set) var correctCount = 0
    private(set) var pointsEarnedThisSession = 0

    enum Phase { case playing, outOfHearts, completed }
    private(set) var phase: Phase = .playing

    var currentQuestion: FlagQuestion { questions[min(currentIndex, questions.count - 1)] }

    init(stageIndex: Int, questions: [FlagQuestion]) {
        self.stageIndex = stageIndex
        self.questions = questions
        // Boş soru dizisinde currentQuestion çökmesin diye oturum baştan biter.
        if questions.isEmpty { phase = .completed }
    }

    func answer(isCorrect: Bool) {
        AnswerFeedback.play(isCorrect: isCorrect)
        if isCorrect {
            correctCount += 1
            pointsEarnedThisSession += GameRules.pointsPerCorrectAnswer
        } else {
            hearts -= 1
        }
    }

    /// Cevap animasyonu/geri bildirimi gösterildikten sonra bir sonraki soruya geçer.
    func advance() {
        if hearts <= 0 {
            phase = .outOfHearts
        } else if currentIndex + 1 >= questions.count {
            phase = .completed
        } else {
            currentIndex += 1
        }
    }

    /// "Puanla Devam Et" — bkz. Kural Kitabı: 50 puan harcanır, canlar 5'e tamamlanır.
    func refillHeartsWithPoints() {
        hearts = GameRules.maxHearts
        // Az önce yanlış cevaplanan sorunun doğrusu zaten gösterildi — aynı soruyu tekrar
        // sormak mantıksız (puanla "cevabı görüp tekrar yanıtlama") olurdu. Sıradaki soruya
        // geçilir; yanlış cevaplanan soru son soruysa seviye tamamlanır.
        if currentIndex + 1 >= questions.count {
            phase = .completed
        } else {
            currentIndex += 1
            phase = .playing
        }
    }

    /// "Etabı Baştan Başla" — ücretsiz, ilerleme sıfırlanır.
    func restart() {
        currentIndex = 0
        hearts = GameRules.startingHeartsPerSession
        correctCount = 0
        pointsEarnedThisSession = 0
        phase = .playing
    }
}
