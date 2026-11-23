import Foundation

/// Başkentler kategorisinin tek bir sorusu. Seviyeye göre soru biçimi değişir (bkz. Capitals.makeQuestions):
/// 1-2 bayrak + ülke adı, 3 başkent adı (şıklar ülke adı ya da bayrak), 4 yalnızca bayrak, 5-8 karışık.
struct CapitalQuestion {
    enum Format {
        /// Bayrak + ülke adı gösterilir → şıklar başkent adı.
        case flagWithNameToCapital
        /// Yalnızca bayrak gösterilir → şıklar başkent adı.
        case flagToCapital
        /// Harita gösterilir → şıklar başkent adı.
        case mapToCapital
        /// Başkent adı gösterilir → şıklar ülke adı.
        case capitalToCountry
        /// Başkent adı gösterilir → şıklar bayrak (2×2).
        case capitalToFlag
    }

    let format: Format
    let countryCode: String
    /// Ülkenin Türkçe adı (ekranda `D()` ile yerelleştirilir).
    let countryName: String
    /// Ekranda gösterilecek (yerelleştirilmiş) başkent adı.
    let capitalName: String
    /// Şıklar: `.capitalToFlag` için ülke KODLARI, `.capitalToCountry` için ülkelerin Türkçe adları,
    /// diğerlerinde (yerelleştirilmiş) başkent adları.
    let options: [String]
    /// `options` içindeki doğru şık (aynı alanda).
    let correct: String
    /// Yazılı soru ("Karışık" bölümü): bayrak + ülke adı gösterilir, oyuncu başkenti yazar (bkz. TypedAnswer).
    var typed = false
}
