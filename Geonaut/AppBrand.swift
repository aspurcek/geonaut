import Foundation

/// Uygulamanın marka adının TEK kaynağı — ad değişirse (App Store adı kararı) uygulama
/// içindeki görünümler buradan okunur. Ekran-dışı iki yer ayrıca elle güncellenir:
/// ana ekran adı (Xcode proje ayarı `CFBundleDisplayName`) ve App Store Connect adı.
/// Not: Oyun içi seviye adları, avatar eşyaları ve varsayılan oyuncu adı da artık
/// "Geonaut" (kaşif/gezgin) adını taşır; eski "Kaşif" adı hiçbir yerde kullanılmıyor.
enum AppBrand {
    static let name = "Geonaut"
}
