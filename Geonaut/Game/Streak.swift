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
    /// Geçmişte oynanmış, seri kapsamındaki gün (pasif yeşil).
    case completed
    /// Bugün ve oynanmış (canlı yeşil).
    case playedToday
    /// Bugün, henüz oynanmadı (mercan halka — "bugün sıra sende").
    case active
    /// Seri koptuktan sonra oynanmadan geçen gün (sakin gri ✕).
    case missed
    /// Gelecek ya da seriyle ilgisi olmayan geçmiş gün.
    case upcoming
}

extension StreakStatus {
    /// Pazartesi'den Pazar'a, içinde bulunulan haftanın 7 günü. Günlük geçmişi tutmadığımız
    /// için seri, `lastActiveDate`'te biten ardışık `streakDays` gün olarak yorumlanır.
    /// Seri bozulsa bile koptuğu güne kadarki oynanmış günler pasif yeşil kalır; sonrasında
    /// oynanmadan geçen günler "kaçırıldı" olarak işaretlenir.
    static func weekDays(lastActiveDate: Date, streakDays: Int, now: Date = .now, calendar: Calendar = .current) -> [StreakWeekDay] {
        var cal = calendar
        cal.firstWeekday = 2 // Pazartesi
        let today = cal.startOfDay(for: now)
        guard let weekStart = cal.dateInterval(of: .weekOfYear, for: today)?.start else {
            return Array(repeating: .upcoming, count: 7)
        }
        let last = cal.startOfDay(for: lastActiveDate)
        let hasRun = streakDays > 0
        let runStart = cal.date(byAdding: .day, value: -(max(streakDays, 1) - 1), to: last) ?? last
        return (0..<7).map { index in
            guard let day = cal.date(byAdding: .day, value: index, to: weekStart) else { return .upcoming }
            if day > today { return .upcoming }
            if hasRun && day >= runStart && day <= last { return day == today ? .playedToday : .completed }
            if day == today { return .active }
            if hasRun && day > last { return .missed }
            return .upcoming
        }
    }
}
