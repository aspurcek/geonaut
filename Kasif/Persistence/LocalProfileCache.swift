import Foundation

/// Profilin cihazdaki yedeği. İki işe yarar: (1) iCloud/ağ yokken oyuncu ilerlemesini
/// kaybetmeden devam eder, (2) CloudKit'e yazılamayan değişiklikler `dirty` işaretlenir ve
/// bir sonraki başarılı bağlantıda buluta gönderilir — böylece boş varsayılan profil
/// asla buluttaki gerçek ilerlemenin üzerine yazılmaz.
enum LocalProfileCache {
    struct Entry: Codable {
        var profile: PlayerProfile
        var dirty: Bool
    }

    private static func url(for userIdentifier: String) -> URL? {
        guard let dir = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return nil }
        let safe = userIdentifier.filter { $0.isLetter || $0.isNumber || $0 == "." || $0 == "-" || $0 == "_" }
        return dir.appendingPathComponent("profile-\(safe).json")
    }

    static func load(userIdentifier: String) -> Entry? {
        guard let url = url(for: userIdentifier), let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(Entry.self, from: data)
    }

    static func save(_ profile: PlayerProfile, dirty: Bool) {
        guard let url = url(for: profile.appleUserIdentifier),
              let data = try? JSONEncoder().encode(Entry(profile: profile, dirty: dirty)) else { return }
        try? data.write(to: url, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
    }

    /// Çıkış yaparken: bulutla senkron (dirty değil) yedeği sil — paylaşılan cihazda
    /// bir sonraki kişi eski profil verisini görmesin. Gönderilmemiş değişiklik varsa korunur.
    static func deleteIfSynced(userIdentifier: String) {
        if let entry = load(userIdentifier: userIdentifier), !entry.dirty {
            delete(userIdentifier: userIdentifier)
        }
    }

    static func delete(userIdentifier: String) {
        guard let url = url(for: userIdentifier) else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
