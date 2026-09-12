import SwiftUI

/// Figma Design System / Bileşenler / Toast (node 105:340). Tone=Info/Danger/Success,
/// artı Seri Kaybı Akışı'ndaki (node 508:11954) "seri riskte" uyarısı için Warning.
enum KasifToastTone { case info, danger, success, warning }

struct KasifToast: View {
    let message: String
    var tone: KasifToastTone = .info

    private var background: Color {
        switch tone {
        case .info: KasifColor.bgSurface
        case .danger: KasifColor.accentDanger
        case .success: KasifColor.accentSuccess
        case .warning: KasifColor.accentHighlightStrong
        }
    }

    private var foreground: Color {
        switch tone {
        case .info: KasifColor.textMuted
        case .danger: KasifColor.textOnAccent
        case .success: KasifColor.accentSuccessText
        case .warning: KasifColor.textOnAccent
        }
    }

    private var systemImage: String {
        switch tone {
        case .info: "info.circle.fill"
        case .danger: "exclamationmark.triangle.fill"
        case .success: "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 20))
                .foregroundStyle(foreground)
            Text(message)
                .font(KasifTypography.bodySemibold)
                .foregroundStyle(foreground)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, KasifSpacing.lg)
        .padding(.vertical, KasifSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background, in: RoundedRectangle(cornerRadius: KasifRadius.md))
        .overlay {
            if tone == .info {
                RoundedRectangle(cornerRadius: KasifRadius.md)
                    .strokeBorder(KasifColor.borderSubtle, lineWidth: 1.5)
            }
        }
    }
}

#Preview {
    VStack(spacing: KasifSpacing.lg) {
        KasifToast(message: "E-posta gelmedi mi? Spam klasörünü kontrol et ya da tekrar gönder.", tone: .info)
        KasifToast(message: "E-posta ya da şifre yanlış. Tekrar dene.", tone: .danger)
        KasifToast(message: "Harika! Bu İtalya", tone: .success)
        KasifToast(message: "Serini kaybetmek üzeresin! Bugün oyna, seriyi koru. 🔥", tone: .warning)
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
