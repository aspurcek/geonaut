import Foundation

/// Yayınlanan yasal sayfaların adresleri. Adres `nil` iken uygulamada link GÖSTERİLMEZ
/// (ölü link App Store incelemesinde sorun çıkarır) — gizlilik politikası yayınlanınca
/// buraya URL'yi yazmak yeterli; Onboarding ve Ayarlar'da link kendiliğinden görünür.
enum LegalLinks {
    /// Notion'da herkese açık yayınlanan Gizlilik Politikası + Destek sayfası (TR/EN/DE/ES).
    /// App Store Connect'teki "Gizlilik Politikası URL" ve "Destek URL" alanlarına da AYNI adres yazılır.
    static let privacyPolicy: URL? = URL(string: "https://app.notion.com/p/Geonaut-Gizlilik-Politikas-Privacy-Policy-3f06c453bada81609b09d9348a95850b")
}
