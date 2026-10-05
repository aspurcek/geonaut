import SwiftUI

/// Figma Design System / Bileşenler / Badge (node 23:14). Tone=Success/Info/Neutral/Highlight.
enum GeoBadgeTone {
    case success, info, neutral, highlight
}

struct GeoBadge: View {
    let text: String
    var tone: GeoBadgeTone = .success

    private var background: Color {
        switch tone {
        case .success: GeoColor.accentSuccess
        case .info: GeoColor.accentInfo
        case .neutral: GeoColor.bgLocked
        case .highlight: GeoColor.textPrimary // ink/900
        }
    }

    private var foreground: Color {
        switch tone {
        case .success: GeoColor.accentSuccessText
        case .info, .neutral: GeoColor.textSecondary
        case .highlight: GeoColor.textOnAccent
        }
    }

    var body: some View {
        Text(LocalizedStringKey(text))
            .font(GeoTypography.caption)
            .foregroundStyle(foreground)
            .padding(.horizontal, GeoSpacing.md)
            .padding(.vertical, GeoSpacing.sm)
            .background(background, in: Capsule())
    }
}

#Preview {
    VStack(spacing: GeoSpacing.md) {
        GeoBadge(text: "Geonaut seviyesi: Gezgin", tone: .success)
        GeoBadge(text: "Yeni", tone: .info)
        GeoBadge(text: "Kilitli", tone: .neutral)
        GeoBadge(text: "BAŞLA", tone: .highlight)
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
