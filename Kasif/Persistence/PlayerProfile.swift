import Foundation

/// CloudKit'te saklanan oyuncu profili — bkz. Kaşif Uygulama Kural Kitabı böl. 07-08.
struct PlayerProfile {
    var appleUserIdentifier: String
    var displayName: String
    /// Apple yalnızca hesabın bu uygulamaya İLK yetkilendirilmesinde e-posta verir;
    /// sonraki girişlerde nil gelir. Bu yüzden yalnızca ilk oluşturmada yakalanıp
    /// CloudKit'e yazılır — "Ayarlar"da salt okunur gösterilir (bkz. SettingsView).
    var email: String? = nil
    var points: Int = GameRules.newPlayerStartingPoints
    var streakDays: Int = 0
    var avatarColorHex: UInt32 = 0xFF987E // accentPrimarySoft
    var lastActiveDate: Date = .now
    /// GameProgress'in ham hâli — "kıta|etapIndex" biçiminde (bkz. GameProgress.swift).
    /// Etap Haritası'nın hangi etabın aktif/kilitli/tamamlanmış olduğunu doğru
    /// gösterebilmesi için tek tek etap bazında saklanması gerekiyor; rozet/kupa
    /// kilidi açık/kapalı bilgisi bundan CANLI hesaplanır (bkz. BadgeCatalog), ayrıca saklanmaz.
    var completedStageKeys: Set<String> = []
    /// "Öğrenilen Ülke" istatistiği — bir soruda gösterilip cevaplanan (doğru/yanlış
    /// fark etmez) ülke kodlarının kümesi. Sayı bu kümenin .count'u (bkz. ProfileView).
    var learnedCountryCodes: Set<String> = []
    /// "kıta|etapIndex=puan" biçiminde, o etapta şimdiye kadar kazanılan en yüksek puan
    /// (bkz. GameProgress.bestPointsByStage) — bir etap tekrar oynanınca puan farming'i
    /// önlemek için gerekli.
    var bestPointsByStage: [String] = []

    static func newPlayer(appleUserIdentifier: String, displayName: String, email: String? = nil) -> PlayerProfile {
        PlayerProfile(appleUserIdentifier: appleUserIdentifier, displayName: displayName, email: email)
    }
}
