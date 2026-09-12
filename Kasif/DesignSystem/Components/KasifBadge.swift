import SwiftUI

/// Figma Design System / Bileşenler / Badge (node 23:14). Tone=Success/Info/Neutral/Highlight.
enum KasifBadgeTone {
    case success, info, neutral, highlight
}

struct KasifBadge: View {
    let text: String
    var tone: KasifBadgeTone = .success

    private var background: Color {
        switch tone {
        case .success: KasifColor.accentSuccess
        case .info: KasifColor.accentInfo
        case .neutral: KasifColor.bgLocked
        case .highlight: KasifColor.textPrimary // ink/900
        }
    }

    private var foreground: Color {
        switch tone {
        case .success: KasifColor.accentSuccessText
        case .info, .neutral: KasifColor.textSecondary
        case .highlight: KasifColor.textOnAccent
        }
    }

    var body: some View {
        Text(text)
            .font(KasifTypography.caption)
            .foregroundStyle(foreground)
            .padding(.horizontal, KasifSpacing.md)
            .padding(.vertical, KasifSpacing.sm)
            .background(background, in: Capsule())
    }
}

#Preview {
    VStack(spacing: KasifSpacing.md) {
        KasifBadge(text: "Kaşif seviyesi: Gezgin", tone: .success)
        KasifBadge(text: "Yeni", tone: .info)
        KasifBadge(text: "Kilitli", tone: .neutral)
        KasifBadge(text: "BAŞLA", tone: .highlight)
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
