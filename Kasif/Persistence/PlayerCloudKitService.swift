import CloudKit
import Foundation

/// CloudKit private database'de oyuncu ilerlemesini saklar. Sunucu yok, API key yok —
/// veri kullanıcının kendi iCloud hesabında tutulur (bkz. proje kararı: Apple ile Giriş
/// + CloudKit, üçüncü parti bir kimlik/veri sağlayıcı kullanılmıyor).
enum PlayerCloudKitService {
    private static let recordType = "PlayerProfile"
    private static let container = CKContainer(identifier: "iCloud.com.aspurce.kasif.Kasif")

    private static func recordID(for appleUserIdentifier: String) -> CKRecord.ID {
        CKRecord.ID(recordName: "player-\(appleUserIdentifier)")
    }

    /// Var olan profili getirir; yoksa (ilk giriş) yeni bir profil oluşturup kaydeder.
    /// `email`, Apple'ın yalnızca ilk yetkilendirmede verdiği adres — profil zaten
    /// varsa yok sayılır (kayıtlı olan korunur).
    static func fetchOrCreateProfile(appleUserIdentifier: String, displayName: String, email: String? = nil) async throws -> PlayerProfile {
        let database = container.privateCloudDatabase
        let id = recordID(for: appleUserIdentifier)

        do {
            let record = try await database.record(for: id)
            return profile(from: record)
        } catch let error as CKError where error.code == .unknownItem {
            let newProfile = PlayerProfile.newPlayer(appleUserIdentifier: appleUserIdentifier, displayName: displayName, email: email)
            try await save(newProfile)
            return newProfile
        }
    }

    /// Var olan kaydı önce getirip üzerine yazar — sıfırdan bir CKRecord oluşturup
    /// kaydetmek, kaydın recordChangeTag'ini taşımadığı için ikinci save'den itibaren
    /// sunucudaki kayıtla "değişmemiş" sayılmayıp CKError.serverRecordChanged ile
    /// başarısız olurdu (ve recordStageCompletion/updateProfile gibi çağıranlar bunu
    /// `try?` ile sessizce yutardı — ilerleme hiç kalıcı olmazdı).
    static func save(_ profile: PlayerProfile) async throws {
        let database = container.privateCloudDatabase
        let id = recordID(for: profile.appleUserIdentifier)
        let record: CKRecord
        do {
            record = try await database.record(for: id)
        } catch let error as CKError where error.code == .unknownItem {
            record = CKRecord(recordType: recordType, recordID: id)
        }
        record["displayName"] = profile.displayName
        record["email"] = profile.email
        record["points"] = profile.points
        record["streakDays"] = profile.streakDays
        record["avatarColorHex"] = Int64(profile.avatarColorHex)
        record["skinTone"] = profile.skinTone.rawValue
        record["hairStyle"] = profile.hairStyle.rawValue
        record["hairColorHex"] = Int64(profile.hairColorHex)
        record["accessory"] = profile.accessory?.rawValue
        record["facialFeature"] = profile.facialFeature?.rawValue
        record["lastActiveDate"] = profile.lastActiveDate
        record["completedStageKeys"] = Array(profile.completedStageKeys)
        record["learnedCountryCodes"] = Array(profile.learnedCountryCodes)
        record["bestPointsByStage"] = profile.bestPointsByStage
        _ = try await database.save(record)
    }

    private static func profile(from record: CKRecord) -> PlayerProfile {
        PlayerProfile(
            appleUserIdentifier: record.recordID.recordName.replacingOccurrences(of: "player-", with: ""),
            displayName: record["displayName"] as? String ?? "Kaşif",
            email: record["email"] as? String,
            points: record["points"] as? Int ?? GameRules.newPlayerStartingPoints,
            streakDays: record["streakDays"] as? Int ?? 0,
            avatarColorHex: UInt32((record["avatarColorHex"] as? Int64) ?? 0xFF987E),
            skinTone: (record["skinTone"] as? String).flatMap(SkinTone.init) ?? .acik,
            hairStyle: (record["hairStyle"] as? String).flatMap(HairStyle.init) ?? .kisa,
            hairColorHex: UInt32((record["hairColorHex"] as? Int64) ?? 0x222938),
            accessory: (record["accessory"] as? String).flatMap(AvatarAccessory.init),
            facialFeature: (record["facialFeature"] as? String).flatMap(AvatarFacialFeature.init),
            lastActiveDate: record["lastActiveDate"] as? Date ?? .now,
            completedStageKeys: Set(record["completedStageKeys"] as? [String] ?? []),
            learnedCountryCodes: Set(record["learnedCountryCodes"] as? [String] ?? []),
            bestPointsByStage: record["bestPointsByStage"] as? [String] ?? []
        )
    }
}
