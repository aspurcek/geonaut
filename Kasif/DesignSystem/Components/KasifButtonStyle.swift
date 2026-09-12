import SwiftUI

/// Figma Design System / Bileşenler / Button (node 351:13037).
/// Style=Primary/Secondary × State=Default/Passive. "Passive" burada SwiftUI'nin
/// native `.disabled()` durumuna karşılık gelir (kırmızı/gri değil, %40 opacity).
enum KasifButtonVariant {
    case primary
    case secondary
}

struct KasifButtonStyle: ButtonStyle {
    var variant: KasifButtonVariant = .primary
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(KasifTypography.headingM)
            .foregroundStyle(variant == .primary ? KasifColor.textOnAccent : KasifColor.textPrimary)
            .padding(.horizontal, KasifSpacing.xl)
            .padding(.vertical, KasifSpacing.sm)
            .background {
                Capsule()
                    .fill(variant == .primary ? KasifColor.accentPrimary : KasifColor.bgSurface)
            }
            .overlay {
                if variant == .secondary {
                    Capsule().strokeBorder(KasifColor.borderSubtle, lineWidth: 1.5)
                }
            }
            .shadow(
                color: variant == .primary ? KasifColor.accentPrimary.opacity(0.35) : .clear,
                radius: 9, x: 0, y: 8
            )
            .opacity(isEnabled ? 1 : 0.4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == KasifButtonStyle {
    static var kasifPrimary: KasifButtonStyle { KasifButtonStyle(variant: .primary) }
    static var kasifSecondary: KasifButtonStyle { KasifButtonStyle(variant: .secondary) }
}

#Preview {
    VStack(spacing: KasifSpacing.lg) {
        Button("Başlayalım") {}.buttonStyle(.kasifPrimary)
        Button("Başlayalım") {}.buttonStyle(.kasifPrimary).disabled(true)
        Button("Başlayalım") {}.buttonStyle(.kasifSecondary)
        Button("Başlayalım") {}.buttonStyle(.kasifSecondary).disabled(true)
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
