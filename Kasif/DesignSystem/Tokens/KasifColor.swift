import SwiftUI

/// Semantic color tokens from the Figma "Design System / 1. Renkler" page.
/// Always reference these — never a literal hex — so the app stays in sync with Figma.
enum KasifColor {
    static let bgCanvas = Color(hex: 0xFBF4E6)
    static let bgSurface = Color(hex: 0xFDFCF8)
    static let bgLocked = Color(hex: 0xE4E8EF)

    static let textPrimary = Color(hex: 0x222938)
    static let textSecondary = Color(hex: 0x5E636F)
    static let textMuted = Color(hex: 0x8C8F95)
    static let textOnAccent = Color.white

    static let accentPrimary = Color(hex: 0xEC785B)
    static let accentPrimarySoft = Color(hex: 0xFF987E)

    static let accentSuccess = Color(hex: 0x97E4C2)
    static let accentSuccessStrong = Color(hex: 0x32A67D)
    static let accentSuccessText = Color(hex: 0x238059)

    static let accentInfo = Color(hex: 0x9ED3F2)
    static let accentInfoStrong = Color(hex: 0x2D8AB8)

    static let accentHighlight = Color(hex: 0xF0D777)
    static let accentHighlightStrong = Color(hex: 0xC09910)

    static let accentTertiary = Color(hex: 0xDACCF7)
    static let accentTertiaryStrong = Color(hex: 0x9783BE)

    static let accentDanger = Color(hex: 0xCD5537)

    static let borderSubtle = Color(hex: 0xE4E8EF)
    static let iconInactive = Color(hex: 0xBFC2C8)

    /// Profil avatar arka plan rengi seçenekleri (6 swatch, Profil-Ayarlar ekranı,
    /// node 475:11492) — SVG fill'leri tek tek indirilip hex olarak doğrulandı.
    static let avatarSwatches: [(color: Color, hex: UInt32)] = [
        (accentPrimarySoft, 0xFF987E),
        (accentSuccess, 0x97E4C2),
        (accentInfo, 0x9ED3F2),
        (accentHighlight, 0xF0D777),
        (accentTertiary, 0xDACCF7),
        (accentPrimary, 0xEC785B)
    ]
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
