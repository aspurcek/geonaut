import Foundation

/// CloudKit'te saklanan oyuncu profili — bkz. Kaşif Uygulama Kural Kitabı böl. 07-08.
struct PlayerProfile: Codable {
    var appleUserIdentifier: String
    var displayName: String
    /// Apple yalnızca hesabın bu uygulamaya İLK yetkilendirilmesinde e-posta verir;
    /// sonraki girişlerde nil gelir. Bu yüzden yalnızca ilk oluşturmada yakalanıp
    /// CloudKit'e yazılır — "Ayarlar"da salt okunur gösterilir (bkz. SettingsView).
    var email: String? = nil
    var points: Int = GameRules.newPlayerStartingPoints
    var streakDays: Int = 0
    static let defaultAvatarColorHex: UInt32 = 0xFF987E // accentPrimarySoft
    var avatarColorHex: UInt32 = PlayerProfile.defaultAvatarColorHex
    /// "Avatarını Oluştur"da en az bir kez kaydetti mi — Ana Sayfa header'ındaki
    /// profil ikonunun gerçek avatarı mı yoksa varsayılan (mor + profil ikonu)
    /// halini mi göstereceğini belirler (bkz. HomeView.headerAvatarButton). Renk/
    /// karakter alanlarının kendi varsayılan değerleriyle karşılaştırmak yerine ayrı
    /// bir bayrak tutuyoruz — kullanıcı bilerek varsayılanla birebir aynı kombinasyonu
    /// seçmiş olabilir, o durumda da "avatar yaptı" sayılmalı.
    var hasCustomAvatar: Bool = false
    /// Avatar karakter sistemi — bkz. AvatarCharacter/KasifAvatarCharacterView ve
    /// "Avatarını Oluştur" ekranı (Figma node 566:12128).
    var skinTone: SkinTone = .acik
    var hairStyle: HairStyle = .kisa
    var hairColorHex: UInt32 = 0x222938
    /// Kullanıcı kararı: aynı anda yalnızca BİR aksesuar / BİR yüz detayı.
    var accessory: AvatarAccessory? = nil
    var facialFeature: AvatarFacialFeature? = nil
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

    /// Özel `init(from:)` eklenince Swift'in normalde ürettiği memberwise init artık
    /// üretilmez — `newPlayer` ve önizlemelerin kullandığı bu init'i elle geri koyuyoruz.
    init(
        appleUserIdentifier: String, displayName: String, email: String? = nil,
        points: Int = GameRules.newPlayerStartingPoints, streakDays: Int = 0,
        avatarColorHex: UInt32 = PlayerProfile.defaultAvatarColorHex, hasCustomAvatar: Bool = false,
        skinTone: SkinTone = .acik, hairStyle: HairStyle = .kisa, hairColorHex: UInt32 = 0x222938,
        accessory: AvatarAccessory? = nil, facialFeature: AvatarFacialFeature? = nil,
        lastActiveDate: Date = .now, completedStageKeys: Set<String> = [],
        learnedCountryCodes: Set<String> = [], bestPointsByStage: [String] = []
    ) {
        self.appleUserIdentifier = appleUserIdentifier
        self.displayName = displayName
        self.email = email
        self.points = points
        self.streakDays = streakDays
        self.avatarColorHex = avatarColorHex
        self.hasCustomAvatar = hasCustomAvatar
        self.skinTone = skinTone
        self.hairStyle = hairStyle
        self.hairColorHex = hairColorHex
        self.accessory = accessory
        self.facialFeature = facialFeature
        self.lastActiveDate = lastActiveDate
        self.completedStageKeys = completedStageKeys
        self.learnedCountryCodes = learnedCountryCodes
        self.bestPointsByStage = bestPointsByStage
    }

    /// Elle yazılmış decode: sonradan eklenen her alan `decodeIfPresent` ile okunuyor,
    /// böylece yerel önbellekteki (LocalProfileCache) eski bir profil JSON'ı — yeni alan
    /// eklenmeden ÖNCE kaydedilmiş olsa bile — üstteki varsayılan değerlerle sorunsuz
    /// decode olur. Sentezlenmiş Codable bunu YAPMAZ: property'nin varsayılan değeri
    /// yalnızca kod içi init'te geçerlidir, decode sırasında alan JSON'da yoksa hata fırlatır.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        appleUserIdentifier = try c.decode(String.self, forKey: .appleUserIdentifier)
        displayName = try c.decode(String.self, forKey: .displayName)
        email = try c.decodeIfPresent(String.self, forKey: .email)
        points = try c.decodeIfPresent(Int.self, forKey: .points) ?? GameRules.newPlayerStartingPoints
        streakDays = try c.decodeIfPresent(Int.self, forKey: .streakDays) ?? 0
        avatarColorHex = try c.decodeIfPresent(UInt32.self, forKey: .avatarColorHex) ?? PlayerProfile.defaultAvatarColorHex
        hasCustomAvatar = try c.decodeIfPresent(Bool.self, forKey: .hasCustomAvatar) ?? false
        skinTone = try c.decodeIfPresent(SkinTone.self, forKey: .skinTone) ?? .acik
        hairStyle = try c.decodeIfPresent(HairStyle.self, forKey: .hairStyle) ?? .kisa
        hairColorHex = try c.decodeIfPresent(UInt32.self, forKey: .hairColorHex) ?? 0x222938
        accessory = try c.decodeIfPresent(AvatarAccessory.self, forKey: .accessory)
        facialFeature = try c.decodeIfPresent(AvatarFacialFeature.self, forKey: .facialFeature)
        lastActiveDate = try c.decodeIfPresent(Date.self, forKey: .lastActiveDate) ?? .now
        completedStageKeys = try c.decodeIfPresent(Set<String>.self, forKey: .completedStageKeys) ?? []
        learnedCountryCodes = try c.decodeIfPresent(Set<String>.self, forKey: .learnedCountryCodes) ?? []
        bestPointsByStage = try c.decodeIfPresent([String].self, forKey: .bestPointsByStage) ?? []
    }

    /// Cihazdaki gönderilmemiş (dirty) yedek ile buluttaki kaydı BİRLEŞTİRİR — biri diğerini
    /// komple ezmez. Örnek tehlikeli durum: uygulama silinip yeniden kurulur, internet yokken
    /// yeni (boş) profille oynanır, bağlantı gelince bulutta eski gerçek ilerleme vardır;
    /// eskiden yerel boş profil bulutu ezerdi. Kural: etap anahtarları ve öğrenilen ülkeler
    /// birleşim, etap başına en iyi puan maksimum, puan maksimum, seri son aktif günü daha
    /// yeni olan tarafınki; özel avatar/ad bulutta varsa yerelin varsayılanı onu ezmez.
    func merging(cloud: PlayerProfile) -> PlayerProfile {
        var result = self
        result.completedStageKeys = completedStageKeys.union(cloud.completedStageKeys)
        result.learnedCountryCodes = learnedCountryCodes.union(cloud.learnedCountryCodes)

        var best: [String: Int] = [:]
        for entry in cloud.bestPointsByStage + bestPointsByStage {
            let parts = entry.components(separatedBy: "=")
            guard parts.count == 2, let value = Int(parts[1]) else { continue }
            best[parts[0]] = max(best[parts[0]] ?? 0, value)
        }
        result.bestPointsByStage = best.map { "\($0.key)=\($0.value)" }.sorted()

        result.points = max(points, cloud.points)
        if cloud.lastActiveDate > lastActiveDate {
            result.streakDays = cloud.streakDays
            result.lastActiveDate = cloud.lastActiveDate
        }
        if result.email == nil { result.email = cloud.email }
        if !hasCustomAvatar && cloud.hasCustomAvatar {
            result.avatarColorHex = cloud.avatarColorHex
            result.avatarCharacter = cloud.avatarCharacter
            result.hasCustomAvatar = true
        }
        if displayName.trimmingCharacters(in: .whitespaces).isEmpty
            || (displayName == String(localized: "Kaşif") && cloud.displayName != displayName) {
            result.displayName = cloud.displayName
        }
        return result
    }

    /// AvatarBuilderView'ın taslak (draft) düzenlemesi için tek bir değer olarak
    /// okuma/yazma — profildeki 10 ayrı alanı tek tek taşımak yerine.
    var avatarCharacter: AvatarCharacter {
        get {
            AvatarCharacter(
                skinTone: skinTone, hairStyle: hairStyle, hairColorHex: hairColorHex,
                accessory: accessory, facialFeature: facialFeature
            )
        }
        set {
            skinTone = newValue.skinTone
            hairStyle = newValue.hairStyle
            hairColorHex = newValue.hairColorHex
            accessory = newValue.accessory
            facialFeature = newValue.facialFeature
        }
    }
}
