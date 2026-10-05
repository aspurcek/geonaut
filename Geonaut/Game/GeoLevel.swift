import Foundation

/// Kaşif Seviyesi — bkz. Kaşif Uygulama Kural Kitabı böl. 07: "Kademe eşikleri,
/// kategorilerin toplam puan potansiyeline (bölüm × etap × soru başına puan)
/// orantılı olacak şekilde tasarlanmıştır." Doküman bu kademelerin var olduğunu
/// doğruluyor ama tam tabloyu tasarımcı teyidine bırakıyor — burada dokümanın
/// kendi niyetini (içerik tavanlarına orantılı, her kademe "ne kadarını
/// tamamladığını hissettirir") somut sayılara döken karar bu.
///
/// Puan tavanları — üç kategori de aynı 7 kıta + Karışık / 8 etap / 10 soru
/// iskeletini paylaşıyor (bkz. FlagGuessStructure/MainLanguageStructure):
/// Bayrak Tahmin 640 soru × 10 puan = 6400, Ana Diller aynı şekilde 6400
/// (bkz. Ana Diller Kural Kitabı), Harita Bilmece 160 soru × 10 puan = 1600
/// (Kıtalar + Ülkeler) — toplam tavan 6400+6400+1600 = 14400 + 100 başlangıç
/// puanı ≈ 14500. (Önceki sürüm yalnızca ilk iki kategoriyi, ~8000 tavanı esas
/// alıyordu — Ana Diller eklenince üst kademeler buna göre yeniden ölçeklendi.)
/// Eşikler bu tavana göre: ilk kıtayı bitirmek (≈900p) hâlâ "Gezgin"de kalır,
/// Bayrak Tahmin'in tamamını bitirmek (≈6500p) "Dünya Gezgini"ne taşır, ama
/// Harita Bilmece'yi de bitirmek (≈8100p) artık "Efsanevi Geonaut" için yetmez —
/// oraya ulaşmak Ana Diller'e de gerçek anlamda ilerlemeyi gerektirir.
enum GeoLevel: CaseIterable {
    case caylak, gezgin, maceraci, yolUstasi, dunyaGezgini, efsanevi

    static func level(forPoints points: Int) -> GeoLevel {
        switch points {
        case ..<300: .caylak
        case 300..<1000: .gezgin
        case 1000..<2500: .maceraci
        case 2500..<5500: .yolUstasi
        case 5500..<9000: .dunyaGezgini
        default: .efsanevi
        }
    }

    var title: String {
        switch self {
        case .caylak: "Çaylak Geonaut"
        case .gezgin: "Gezgin"
        case .maceraci: "Maceracı"
        case .yolUstasi: "Yol Ustası"
        case .dunyaGezgini: "Dünya Gezgini"
        case .efsanevi: "Efsanevi Geonaut"
        }
    }

    /// Kademe yükseldikçe GeoBadge tonu da güçlenir: nötr → yeşil → mavi →
    /// en üstte "highlight" (koyu/prestijli) — yeni bir renk icat etmeden,
    /// var olan Badge tonlarıyla bir ilerleme hissi.
    var badgeTone: GeoBadgeTone {
        switch self {
        case .caylak: .neutral
        case .gezgin, .maceraci: .success
        case .yolUstasi, .dunyaGezgini: .info
        case .efsanevi: .highlight
        }
    }
}
