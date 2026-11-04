import UIKit

/// Doğru/yanlış cevapta dokunsal geri bildirim + kısa ses — tüm quiz oturumları buradan çağırır.
/// Ses yalnızca Ayarlar'daki "Ses efektleri" açıksa ve telefon sessizde değilse çalar (bkz. SoundPlayer).
enum AnswerFeedback {
    static func play(isCorrect: Bool) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(isCorrect ? .success : .error)
        SoundPlayer.play(isCorrect ? .correct : .wrong)
    }
}
