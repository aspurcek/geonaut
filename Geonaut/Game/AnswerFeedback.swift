import UIKit

/// Doğru/yanlış cevapta dokunsal geri bildirim — tüm quiz oturumları buradan çağırır.
/// Ses bilinçli olarak yok (sessiz modda/sınıfta rahatsız etmesin); titreşim yeterli.
enum AnswerFeedback {
    static func play(isCorrect: Bool) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(isCorrect ? .success : .error)
    }
}
