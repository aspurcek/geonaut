import SwiftUI

/// Avatar karakter sistemi seçenekleri — Figma "Design System / 6. Avatar Karakter
/// Sistemi" (node 555:12299) ve "Avatar Oluştur" ekranıyla (node 566:12128) birebir.
enum SkinTone: String, Codable, CaseIterable {
    case acik, bugday, esmer, siyahi

    var color: Color {
        switch self {
        case .acik: Color(hex: 0xFBDCC4)
        case .bugday: Color(hex: 0xE8B788)
        case .esmer: Color(hex: 0xB67C4E)
        case .siyahi: Color(hex: 0x6B4226)
        }
    }
}

enum HairStyle: String, Codable, CaseIterable {
    case kisa, uzun, kivircik, atKuyrugu, topuz

    var title: String {
        switch self {
        case .kisa: "Kısa"
        case .uzun: "Uzun"
        case .kivircik: "Kıvırcık"
        case .atKuyrugu: "At Kuyruğu"
        case .topuz: "Topuz"
        }
    }
}

/// Aksesuar tekli seçim — kullanıcı kararı: aynı anda yalnızca BİR aksesuar takılabilir
/// (şapka VE gözlük birlikte değil).
enum AvatarAccessory: String, Codable, CaseIterable {
    case sapka, gozluk, kupe, piercing

    var title: String {
        switch self {
        case .sapka: "Geonaut Şapkası"
        case .gozluk: "Geonaut Gözlüğü"
        case .kupe: "Küpe"
        case .piercing: "Burun Piercingi"
        }
    }
}

/// Yüz detayı tekli seçim — kullanıcı kararı: aynı anda yalnızca BİR yüz detayı.
enum AvatarFacialFeature: String, Codable, CaseIterable {
    case cil, biyik, sakal

    var title: String {
        switch self {
        case .cil: "Çil"
        case .biyik: "Bıyık"
        case .sakal: "Sakal"
        }
    }
}

/// Saç rengi seçenekleri bilinçli olarak "Zemin rengi" (GeoColor.avatarSwatches)
/// ile ÇAKIŞMAYAN, aynı ailenin "Strong" (koyu) tonlarından oluşuyor — kullanıcı
/// isteği: iki picker aynı renkleri göstermesin. Yine de GeoColor'dan (design
/// system) çekiliyor, yeni hex icat edilmedi.
enum GeoHairColor {
    static let options: [(color: Color, hex: UInt32)] = [
        (GeoColor.textPrimary, 0x222938),
        (GeoColor.accentHighlightStrong, 0xC09910),
        (GeoColor.accentSuccessStrong, 0x32A67D),
        (GeoColor.accentInfoStrong, 0x2D8AB8),
        (GeoColor.accentTertiaryStrong, 0x9783BE),
        (GeoColor.accentDanger, 0xCD5537),
    ]
}
