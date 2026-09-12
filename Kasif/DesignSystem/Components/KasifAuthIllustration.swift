import SwiftUI

/// Figma Design System / Bileşenler / Auth Illustration (node 176:1036).
/// Type=Hearts/Trophy/Lock/Success — 120pt renkli daire + ikon. Onboarding, şifremi
/// unuttum, canlar bitti gibi durum ekranlarında kullanılır.
enum KasifAuthIllustrationType {
    case hearts, trophy, lock, success, streak

    var background: Color {
        switch self {
        case .hearts: KasifColor.accentDanger
        case .trophy: KasifColor.accentHighlight
        case .lock: KasifColor.accentTertiary
        case .success: KasifColor.accentSuccess
        case .streak: KasifColor.accentPrimary
        }
    }

    var systemImage: String {
        switch self {
        case .hearts: "heart.slash.fill" // Figma'daki üzgün yüz yerine "canlar bitti" temasına uyan sembol
        case .trophy: "trophy.fill"
        case .lock: "lock.fill"
        case .success: "checkmark"
        case .streak: "flame.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .trophy: KasifColor.textOnAccent.opacity(0.9)
        default: .white
        }
    }
}

struct KasifAuthIllustration: View {
    var type: KasifAuthIllustrationType

    var body: some View {
        Circle()
            .fill(type.background)
            .frame(width: 120, height: 120)
            .overlay {
                Image(systemName: type.systemImage)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(type.iconColor)
            }
    }
}

/// Figma "Auth Illustration / Type=Sad" (node 508:11942) — üzgün yüz kurgu bir SF
/// Symbol'e denk düşmediği için, uygulamada zaten kurulu olan emoji-ikon
/// yaklaşımıyla (bkz. KasifFlagAnswerOption) tutarlı şekilde emoji kullanıldı.
struct KasifSadIllustration: View {
    var body: some View {
        Circle()
            .fill(KasifColor.accentTertiary)
            .frame(width: 120, height: 120)
            .overlay {
                Text("🙁").font(.system(size: 48))
            }
    }
}

#Preview {
    HStack(spacing: KasifSpacing.lg) {
        KasifAuthIllustration(type: .hearts)
        KasifAuthIllustration(type: .trophy)
        KasifAuthIllustration(type: .lock)
        KasifAuthIllustration(type: .success)
        KasifAuthIllustration(type: .streak)
        KasifSadIllustration()
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
