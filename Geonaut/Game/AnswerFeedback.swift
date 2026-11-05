import UIKit

/// Doğru/yanlış cevapta dokunsal geri bildirim + kısa ses — tüm quiz oturumları buradan çağırır.
/// Ses yalnızca Ayarlar'daki "Ses efektleri" açıksa ve telefon sessizde değilse çalar (bkz. SoundPlayer).
enum AnswerFeedback {
    /// `showsReward`: doğruysa "✓ +10" süzülür (tanıtım ekranı kendi rozetini gösterdiği için orada kapalı).
    static func play(isCorrect: Bool, showsReward: Bool = true) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(isCorrect ? .success : .error)
        SoundPlayer.play(isCorrect ? .correct : .wrong)
        if isCorrect && showsReward { RewardFlash.shared.trigger() }
    }
}
