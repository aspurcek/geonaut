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
