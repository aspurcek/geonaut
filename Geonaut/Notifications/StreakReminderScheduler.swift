import Foundation
import UserNotifications

/// Günlük seri hatırlatması — yerel (cihaz üzerinde) bildirim, sunucu/push altyapısı
/// gerektirmez (bkz. proje kararı: kendi izleme/sunucumuz yok). Kullanıcı Ayarlar'dan
/// açtığında her aktivite sonrası (bkz. AppState.recordStageCompletion) "yarın bu saatte"
/// tek seferlik bir bildirim yeniden planlanır — kullanıcı ertesi gün açılıştan önce
/// oynarsa bu çağrı zaten iptal edip yeniden plana alır, o gün için eski bildirim asla
/// tetiklenmez. Böylece sunucu tarafı "zaten oynadı mı" kontrolüne gerek kalmaz.
enum StreakReminderScheduler {
    /// SettingsView'daki Toggle ile aynı anahtar (@AppStorage) — kullanıcı tercihi.
    static let enabledDefaultsKey = "geonaut.dailyReminderEnabled"
    private static let requestIdentifier = "geonaut.streakReminder"
    /// Hatırlatmanın gönderileceği yerel saat (19:00) — akşam saati.
    private static let reminderHour = 19

    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        @unknown default:
            return false
        }
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
    }

    /// `enabled` false ise sadece bekleyen bildirimi iptal eder. true ise önce iptal edip
    /// "yarın saat 19:00" için tek seferlik (repeats: false) yeni bir bildirim kurar —
    /// tekrarlı (repeats: true) bir tetikleyici kullanmıyoruz, çünkü her gün otomatik
    /// tekrar eden bir bildirim, kullanıcı o gün zaten oynamış olsa da tetiklenirdi.
    static func reschedule(streakDays: Int, enabled: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
        guard enabled else { return }

        let content = UNMutableNotificationContent()
        content.sound = .default
        if streakDays > 0 {
            content.title = String(localized: "\(streakDays) günlük serini kaybetme!")
            content.body = String(localized: "Bugün henüz oynamadın. Serini korumak için bir etap tamamla!")
        } else {
            content.title = String(localized: "Dünya turu seni bekliyor!")
            content.body = String(localized: "Bugün yeni bir bayrak, ülke ya da lezzet öğrenmeye ne dersin?")
        }

        var date = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        date = Calendar.current.date(
            bySettingHour: reminderHour, minute: 0, second: 0, of: date
        ) ?? date
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        center.add(request)
    }
}
