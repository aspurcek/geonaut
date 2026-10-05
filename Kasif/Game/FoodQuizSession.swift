import Foundation

/// Dünya Yemekleri'nin tek bir etap oturumu — QuizSession/LanguageQuizSession ile
/// birebir aynı can/puan mekaniği (bkz. GameRules), yalnızca soru tipi FoodQuestion.
@Observable
final class FoodQuizSession {
    let stageIndex: Int
    private(set) var questions: [FoodQuestion]
    private(set) var currentIndex = 0
    private(set) var hearts = GameRules.startingHeartsPerSession
    private(set) var correctCount = 0
    private(set) var pointsEarnedThisSession = 0

    enum Phase { case playing, outOfHearts, completed }
    private(set) var phase: Phase = .playing

    var currentQuestion: FoodQuestion { questions[min(currentIndex, questions.count - 1)] }

    init(stageIndex: Int, questions: [FoodQuestion]) {
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

    func advance() {
        if hearts <= 0 {
            phase = .outOfHearts
        } else if currentIndex + 1 >= questions.count {
            phase = .completed
        } else {
            currentIndex += 1
        }
    }

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

    func restart() {
        currentIndex = 0
        hearts = GameRules.startingHeartsPerSession
        correctCount = 0
        pointsEarnedThisSession = 0
        phase = .playing
    }
}
