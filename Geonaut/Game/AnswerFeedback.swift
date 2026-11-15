import UIKit

/// Doğru/yanlış cevapta dokunsal geri bildirim + kısa ses — tüm quiz oturumları buradan çağırır.
/// Ses yalnızca Ayarlar'daki "Ses efektleri" açıksa ve telefon sessizde değilse çalar (bkz. SoundPlayer).
enum AnswerFeedback {
    /// `showsReward`: doğruysa "✓ +10" süzülür (tanıtım ekranı kendi rozetini gösterdiği için orada kapalı).
    /// `combo`: bu seviyedeki üst üste doğru sayısı (bkz. DailyEngagement) — 3 ve üstünde rozette gösterilir.
    static func play(isCorrect: Bool, showsReward: Bool = true, combo: Int = 0) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(isCorrect ? .success : .error)
        SoundPlayer.play(isCorrect ? .correct : .wrong)
        if isCorrect && showsReward { RewardFlash.shared.trigger(combo: combo) }
    }
}
