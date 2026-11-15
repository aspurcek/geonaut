import Foundation

/// Ana Diller'in tek bir etap oturumu — QuizSession ile birebir aynı can/puan
/// mekaniği (bkz. GameRules), yalnızca soru tipi FlagQuestion yerine LanguageQuestion.
@Observable
final class LanguageQuizSession {
    let stageIndex: Int
    private(set) var questions: [LanguageQuestion]
    private(set) var currentIndex = 0
    private(set) var hearts = GameRules.startingHeartsPerSession
    private(set) var correctCount = 0
    private(set) var pointsEarnedThisSession = 0
    /// Pas hakkı — bkz. GameRules.passesPerStage / passCost.
    private(set) var passesLeft = GameRules.passesPerStage
    /// Asıl soru sayısı (pas geçilenler sona eklenince değişmez) — yıldız/sonuç bununla hesaplanır.
    private(set) var baseCount = 0
    /// Pas geçilip seviyenin sonuna eklenen (tekrar sorulan) soruların indeksleri.
    private(set) var retryIndices: Set<Int> = []
    var isRetryQuestion: Bool { retryIndices.contains(currentIndex) }
    var canPass: Bool { phase == .playing && passesLeft > 0 && !isRetryQuestion }

    enum Phase { case playing, outOfHearts, completed }
    private(set) var phase: Phase = .playing

    var currentQuestion: LanguageQuestion { questions[min(currentIndex, questions.count - 1)] }

    init(stageIndex: Int, questions: [LanguageQuestion]) {
        self.stageIndex = stageIndex
        self.questions = questions
        self.baseCount = questions.count
        // Boş soru dizisinde currentQuestion çökmesin diye oturum baştan biter.
        if questions.isEmpty { phase = .completed }
    }

    func answer(isCorrect: Bool) {
        // Pas geçilmiş sorunun tekrarı: doğru cevap zaten gösterildi — puan/günlük hedef/kombo yok,
        // yanlışta can yine gider.
        if isRetryQuestion {
            AnswerFeedback.play(isCorrect: isCorrect, showsReward: false)
            if !isCorrect { hearts -= 1 }
            return
        }
        let combo = DailyEngagement.shared.recordAnswer(isCorrect: isCorrect, isFirstQuestion: currentIndex == 0)
        AnswerFeedback.play(isCorrect: isCorrect, combo: combo)
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

    /// Pas: hak düşer, soru seviyenin sonuna eklenir (puanı çağıran taraf düşer — bkz. SessionView).
    func pass() {
        guard canPass else { return }
        passesLeft -= 1
        questions.append(currentQuestion)
        retryIndices.insert(questions.count - 1)
    }

    func restart() {
        questions = Array(questions.prefix(baseCount))
        retryIndices = []
        passesLeft = GameRules.passesPerStage
        currentIndex = 0
        hearts = GameRules.startingHeartsPerSession
        correctCount = 0
        pointsEarnedThisSession = 0
        phase = .playing
    }
}
