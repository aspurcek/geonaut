import Foundation

/// Yayınlanan yasal sayfaların adresleri. Adres `nil` iken uygulamada link GÖSTERİLMEZ
/// (ölü link App Store incelemesinde sorun çıkarır) — gizlilik politikası yayınlanınca
/// buraya URL'yi yazmak yeterli; Onboarding ve Ayarlar'da link kendiliğinden görünür.
enum LegalLinks {
    static let privacyPolicy: URL? = nil
}
