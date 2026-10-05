import Foundation

/// Günlük seri (streak) durumu — bkz. Figma "FLOW4- Seri Kaybı Akışı" (node 508:11954).
/// Oyuncunun son aktif olduğu gün ile bugün arasındaki farka göre hesaplanır.
enum StreakStatus {
    /// Bugün zaten oynanmış, ya da hiç serisi yok (streakDays == 0).
    case safe
    /// Dün oynanmış, bugün henüz oynanmamış — seri bugün bitmeden korunmalı
    /// (bkz. Ana Sayfa uyarı toast'ı: "Bugün oyna, seriyi koru").
    case atRisk
    /// Aradan en az bir tam gün geçmiş, oynanmadan — seri koptu.
    case lost

    static func compute(lastActiveDate: Date, streakDays: Int, now: Date = .now, calendar: Calendar = .current) -> StreakStatus {
        guard streakDays > 0 else { return .safe }
        let today = calendar.startOfDay(for: now)
        let last = calendar.startOfDay(for: lastActiveDate)
        let daysSince = calendar.dateComponents([.day], from: last, to: today).day ?? 0
        switch daysSince {
        case ...0: return .safe
        case 1: return .atRisk
        default: return .lost
        }
    }
}

/// Profil'deki "Bu haftaki serin" takviminin bir günü.
enum StreakWeekDay: Equatable {
    /// Seri kapsamındaki (oynanmış) gün.
    case completed
    /// Bugün ve henüz oynanmadı.
    case active
    /// Gelecek ya da seri dışındaki geçmiş gün.
    case upcoming
}

extension StreakStatus {
    /// Pazartesi'den Pazar'a, içinde bulunulan haftanın 7 günü. Günlük geçmişi tutmadığımız
    /// için seri, `lastActiveDate`'te biten ardışık `streakDays` gün olarak yorumlanır;
    /// seri bozulmuşsa (son oynama dünden eski) hiçbir gün "tamamlandı" sayılmaz.
    static func weekDays(lastActiveDate: Date, streakDays: Int, now: Date = .now, calendar: Calendar = .current) -> [StreakWeekDay] {
        var cal = calendar
        cal.firstWeekday = 2 // Pazartesi
        let today = cal.startOfDay(for: now)
        guard let weekStart = cal.dateInterval(of: .weekOfYear, for: today)?.start else {
            return Array(repeating: .upcoming, count: 7)
        }
        let last = cal.startOfDay(for: lastActiveDate)
        let daysSinceLast = cal.dateComponents([.day], from: last, to: today).day ?? 0
        let streakAlive = streakDays > 0 && daysSinceLast >= 0 && daysSinceLast <= 1
        return (0..<7).map { index in
            guard let day = cal.date(byAdding: .day, value: index, to: weekStart) else { return .upcoming }
            if day > today { return .upcoming }
            let daysBeforeLast = cal.dateComponents([.day], from: day, to: last).day ?? -1
            if streakAlive && daysBeforeLast >= 0 && daysBeforeLast < streakDays { return .completed }
            return day == today ? .active : .upcoming
        }
    }
}
