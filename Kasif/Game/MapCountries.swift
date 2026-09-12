import Foundation
import CoreGraphics

/// Harita Bilmece "Ülkeler" bölümünde kullanılan ülke+kıta eşleşmeleri — bkz.
/// CLAUDE_CODE_HANDOFF.md böl. 3.2: "Ülkeler bölümünde kullanılan 17 ülke."
struct MapCountry {
    let code: String
    let name: String
    let continent: String
    /// Figma'nın "ContinentMap" dünya haritası SVG'sindeki (aynı veri, node 330:14385
    /// vb.) gerçek ülke sınırlarından hesaplanmış konum/boyut — Tip C'nin "haritadan
    /// doğru kıtaya dokun" hedefini oluşturmak için. Normalize (0...1) kesir, harita
    /// görselinin kendi genişlik/yüksekliğine göre. Kıyı şeridi bezier verisini tam
    /// hassasiyetle SwiftUI Shape'e çevirmek yerine — ki bu, gerçek fayda/efor oranı
    /// düşük bir iş olurdu — bu ülkenin sınır kutusundan (bounding box) türetilen,
    /// çocuklar için bilinçli olarak cömert/geniş dokunma alanları kullanılıyor.
    let mapCenter: CGPoint
    let mapHalfSize: CGSize

    /// "Avrupa / Asya" gibi kıta arası ülkeler için kabul edilen tüm kıta adları.
    var acceptedContinents: Set<String> {
        Set(continent.components(separatedBy: " / "))
    }
}

enum MapCountries {
    static let all: [MapCountry] = [
        .init(code: "DE", name: "Almanya", continent: "Avrupa", mapCenter: CGPoint(x: 0.5024, y: 0.3379), mapHalfSize: CGSize(width: 0.05, height: 0.05)),
        .init(code: "US", name: "Amerika Birleşik Devletleri", continent: "Kuzey Amerika", mapCenter: CGPoint(x: 0.1477, y: 0.333), mapHalfSize: CGSize(width: 0.2113, height: 0.2023)),
        .init(code: "AR", name: "Arjantin", continent: "Güney Amerika", mapCenter: CGPoint(x: 0.2979, y: 0.6706), mapHalfSize: CGSize(width: 0.05, height: 0.105)),
        .init(code: "AU", name: "Avustralya", continent: "Okyanusya", mapCenter: CGPoint(x: 0.8488, y: 0.6503), mapHalfSize: CGSize(width: 0.0954, height: 0.1331)),
        .init(code: "BE", name: "Belçika", continent: "Avrupa", mapCenter: CGPoint(x: 0.4858, y: 0.3421), mapHalfSize: CGSize(width: 0.05, height: 0.05)),
        .init(code: "BR", name: "Brezilya", continent: "Güney Amerika", mapCenter: CGPoint(x: 0.3234, y: 0.5781), mapHalfSize: CGSize(width: 0.0811, height: 0.0984)),
        .init(code: "CN", name: "Çin", continent: "Asya", mapCenter: CGPoint(x: 0.7611, y: 0.3983), mapHalfSize: CGSize(width: 0.1266, height: 0.108)),
        .init(code: "FR", name: "Fransa", continent: "Avrupa", mapCenter: CGPoint(x: 0.4802, y: 0.3617), mapHalfSize: CGSize(width: 0.05, height: 0.05)),
        .init(code: "IN", name: "Hindistan", continent: "Asya", mapCenter: CGPoint(x: 0.702, y: 0.458), mapHalfSize: CGSize(width: 0.0605, height: 0.0747)),
        .init(code: "GB", name: "İngiltere", continent: "Avrupa", mapCenter: CGPoint(x: 0.4647, y: 0.3138), mapHalfSize: CGSize(width: 0.05, height: 0.05)),
        .init(code: "ES", name: "İspanya", continent: "Avrupa", mapCenter: CGPoint(x: 0.4545, y: 0.4058), mapHalfSize: CGSize(width: 0.05, height: 0.05)),
        .init(code: "IT", name: "İtalya", continent: "Avrupa", mapCenter: CGPoint(x: 0.5082, y: 0.3811), mapHalfSize: CGSize(width: 0.05, height: 0.05)),
        .init(code: "JP", name: "Japonya", continent: "Asya", mapCenter: CGPoint(x: 0.8455, y: 0.4078), mapHalfSize: CGSize(width: 0.05, height: 0.0627)),
        .init(code: "CA", name: "Kanada", continent: "Kuzey Amerika", mapCenter: CGPoint(x: 0.2063, y: 0.1985), mapHalfSize: CGSize(width: 0.1828, height: 0.2763)),
        .init(code: "EG", name: "Mısır", continent: "Afrika", mapCenter: CGPoint(x: 0.5585, y: 0.4402), mapHalfSize: CGSize(width: 0.05, height: 0.05)),
        .init(code: "RU", name: "Rusya", continent: "Avrupa / Asya", mapCenter: CGPoint(x: 0.763, y: 0.2151), mapHalfSize: CGSize(width: 0.3548, height: 0.256)),
        .init(code: "TR", name: "Türkiye", continent: "Avrupa / Asya", mapCenter: CGPoint(x: 0.5708, y: 0.394), mapHalfSize: CGSize(width: 0.05, height: 0.05))
    ]
}
