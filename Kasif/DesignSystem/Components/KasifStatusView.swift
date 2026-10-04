import SwiftUI

/// Boş sonuç / hata / yükleniyor durumları için ortak görünüm — Figma'da "Durum -
/// Boş Sonuç", "Durum - Hata", "Durum - Yükleniyor" (30 Eyl 2026) olarak tasarlandı.
/// KasifAuthIllustration'daki "renkli daire + ikon" dilini paylaşıyor, ayrı bir
/// bileşen olmasının sebebi: burada başlık/alt başlık/opsiyonel buton da var.
struct KasifStatusView: View {
    enum Style {
        case empty, error, loading

        var background: Color {
            switch self {
            case .empty: KasifColor.bgLocked
            case .error: KasifColor.accentDanger
            case .loading: KasifColor.accentTertiary
            }
        }

        var systemImage: String {
            switch self {
            case .empty: "magnifyingglass"
            case .error: "exclamationmark.triangle.fill"
            case .loading: "" // ProgressView kullanılıyor, ikon yok
            }
        }
    }

    var style: Style
    var title: String
    var subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: KasifSpacing.lg) {
            Circle()
                .fill(style.background)
                .frame(width: 120, height: 120)
                .overlay {
                    if style == .loading {
                        ProgressView().tint(.white).scaleEffect(1.3)
                    } else {
                        Image(systemName: style.systemImage)
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundStyle(style == .empty ? KasifColor.iconInactive : .white)
                    }
                }

            VStack(spacing: KasifSpacing.xs) {
                Text(LocalizedStringKey(title))
                    .font(.custom(KasifFontName.balooBold, size: 20))
                    .foregroundStyle(KasifColor.textPrimary)
                    .multilineTextAlignment(.center)
                Text(LocalizedStringKey(subtitle))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(KasifColor.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.kasifPrimary)
                    .padding(.horizontal, KasifSpacing.xxxl)
            }
        }
        .padding(KasifSpacing.xxxl)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack(spacing: 0) {
        KasifStatusView(style: .empty, title: "Sonuç bulunamadı", subtitle: "Farklı bir ülke veya kelime denemeyi dene.")
        KasifStatusView(style: .error, title: "Bir şeyler ters gitti", subtitle: "İnternet bağlantını kontrol edip tekrar dene.", actionTitle: "Tekrar Dene", action: {})
        KasifStatusView(style: .loading, title: "Yükleniyor…", subtitle: "Dünyanı hazırlıyoruz.")
    }
    .background(KasifColor.bgCanvas)
}
