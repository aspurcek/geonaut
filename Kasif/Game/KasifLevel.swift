import Foundation

/// Kaşif Seviyesi — bkz. Kaşif Uygulama Kural Kitabı böl. 07: "Kademe eşikleri,
/// kategorilerin toplam puan potansiyeline (bölüm × etap × soru başına puan)
/// orantılı olacak şekilde tasarlanmıştır." Doküman bu kademelerin var olduğunu
/// doğruluyor ama tam tabloyu tasarımcı teyidine bırakıyor — burada dokümanın
/// kendi niyetini (içerik tavanlarına orantılı, her kademe "ne kadarını
/// tamamladığını hissettirir") somut sayılara döken karar bu.
///
/// Puan tavanları: Bayrak Tahmin 640 soru × 10 puan = 6400 (bkz. Bayrak Tahmin
/// Kural Kitabı böl. 01), Harita Bilmece 160 soru × 10 puan = 1600 (Kıtalar +
/// Ülkeler, böl. 05) — toplam MVP tavanı ~8000 + 100 başlangıç puanı.
/// Eşikler bu tavana göre: ilk kıtayı bitirmek (≈900p) hâlâ "Gezgin"de kalır,
/// Bayrak Tahmin'in tamamını bitirmek (≈6500p) "Dünya Gezgini"ne taşır, Harita
/// Bilmece'yi de bitirmek (≈8000+) "Efsanevi Kaşif"e ulaştırır.
enum KasifLevel: CaseIterable {
    case caylak, gezgin, maceraci, yolUstasi, dunyaGezgini, efsanevi

    static func level(forPoints points: Int) -> KasifLevel {
        switch points {
        case ..<300: .caylak
        case 300..<1000: .gezgin
        case 1000..<2500: .maceraci
        case 2500..<4500: .yolUstasi
        case 4500..<7000: .dunyaGezgini
        default: .efsanevi
        }
    }

    var title: String {
        switch self {
        case .caylak: "Çaylak Kaşif"
        case .gezgin: "Gezgin"
        case .maceraci: "Maceracı"
        case .yolUstasi: "Yol Ustası"
        case .dunyaGezgini: "Dünya Gezgini"
        case .efsanevi: "Efsanevi Kaşif"
        }
    }

    /// Kademe yükseldikçe KasifBadge tonu da güçlenir: nötr → yeşil → mavi →
    /// en üstte "highlight" (koyu/prestijli) — yeni bir renk icat etmeden,
    /// var olan Badge tonlarıyla bir ilerleme hissi.
    var badgeTone: KasifBadgeTone {
        switch self {
        case .caylak: .neutral
        case .gezgin, .maceraci: .success
        case .yolUstasi, .dunyaGezgini: .info
        case .efsanevi: .highlight
        }
    }
}
