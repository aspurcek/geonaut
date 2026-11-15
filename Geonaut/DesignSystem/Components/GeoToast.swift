import SwiftUI

/// Figma Design System / Bileşenler / Toast (node 105:340). Tone=Info/Danger/Success,
/// artı Seri Kaybı Akışı'ndaki (node 508:11954) "seri riskte" uyarısı için Warning.
enum GeoToastTone { case info, danger, success, warning }

struct GeoToast: View {
    let message: String
    var tone: GeoToastTone = .info

    private var background: Color {
        switch tone {
        case .info: GeoColor.bgSurface
        case .danger: GeoColor.accentDanger
        case .success: GeoColor.accentSuccess
        case .warning: GeoColor.accentHighlightStrong
        }
    }

    private var foreground: Color {
        switch tone {
        case .info: GeoColor.textMuted
        case .danger: GeoColor.textOnAccent
        case .success: GeoColor.accentSuccessText
        case .warning: GeoColor.textOnAccent
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
            Text(LocalizedStringKey(message))
                .font(GeoTypography.bodySemibold)
                .foregroundStyle(foreground)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, GeoSpacing.lg)
        .padding(.vertical, GeoSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background, in: RoundedRectangle(cornerRadius: GeoRadius.md))
        .overlay {
            if tone == .info {
                RoundedRectangle(cornerRadius: GeoRadius.md)
                    .strokeBorder(GeoColor.borderSubtle, lineWidth: 1.5)
            }
        }
    }
}

#Preview {
    VStack(spacing: GeoSpacing.lg) {
        GeoToast(message: "E-posta gelmedi mi? Spam klasörünü kontrol et ya da tekrar gönder.", tone: .info)
        GeoToast(message: "E-posta ya da şifre yanlış. Tekrar dene.", tone: .danger)
        GeoToast(message: "Harika! Bu İtalya", tone: .success)
        GeoToast(message: "Serini kaybetmek üzeresin! Bugün oyna, seriyi koru.", tone: .warning)
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
