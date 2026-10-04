import SwiftUI

/// Figma Design System / Bileşenler / Social Button (node 31:44). Provider=Email/Google/Apple.
/// Not: Ürün kararı gereği uygulamada yalnızca **Apple ile Devam Et** kullanılacak
/// (Email/Google tasarımda var ama auth akışına bağlanmayacak) — bkz. proje kararları.
enum KasifSocialProvider {
    case email, google, apple
}

struct KasifSocialButton: View {
    let provider: KasifSocialProvider
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: KasifSpacing.sm) {
                icon
                Text(LocalizedStringKey(title))
                    .font(.custom(KasifFontName.balooBold, size: 14))
                    .foregroundStyle(provider == .apple ? .white : KasifColor.textPrimary)
            }
            .padding(.vertical, KasifSpacing.lg)
            .frame(maxWidth: .infinity)
            .background(background, in: Capsule())
            .overlay {
                if provider != .apple {
                    Capsule().strokeBorder(KasifColor.borderSubtle, lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var title: String {
        switch provider {
        case .email: "E-posta ile devam et"
        case .google: "Google ile devam et"
        case .apple: "Apple ile Devam Et"
        }
    }

    private var background: Color {
        switch provider {
        case .apple: Color(hex: 0x0F0F12)
        default: KasifColor.bgSurface
        }
    }

    @ViewBuilder private var icon: some View {
        switch provider {
        case .email:
            Image(systemName: "envelope.fill").foregroundStyle(KasifColor.textPrimary)
        case .google:
            Text("G").font(.system(size: 14, weight: .bold)).foregroundStyle(KasifColor.textSecondary)
        case .apple:
            Image(systemName: "apple.logo").foregroundStyle(.white)
        }
    }
}

#Preview {
    VStack(spacing: KasifSpacing.lg) {
        KasifSocialButton(provider: .email) {}
        KasifSocialButton(provider: .google) {}
        KasifSocialButton(provider: .apple) {}
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
