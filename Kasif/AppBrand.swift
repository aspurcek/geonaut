import Foundation

/// Uygulamanın marka adının TEK kaynağı — ad değişirse (App Store adı kararı) uygulama
/// içindeki görünümler buradan okunur. Ekran-dışı iki yer ayrıca elle güncellenir:
/// ana ekran adı (Xcode proje ayarı `CFBundleDisplayName`) ve App Store Connect adı.
/// Not: "Kaşif" (kaşif/gezgin) oyun içi bir KAVRAM olarak kalır ("Kaşif seviyesi",
/// "Kaşif Şapkası" gibi), marka adı değildir.
enum AppBrand {
    static let name = "Geopal"
}
