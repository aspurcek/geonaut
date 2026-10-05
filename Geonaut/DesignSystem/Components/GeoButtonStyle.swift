import SwiftUI

/// Figma Design System / Bileşenler / Button (node 351:13037).
/// Style=Primary/Secondary × State=Default/Passive. "Passive" burada SwiftUI'nin
/// native `.disabled()` durumuna karşılık gelir (kırmızı/gri değil, %40 opacity).
enum GeoButtonVariant {
    case primary
    case secondary
}

struct GeoButtonStyle: ButtonStyle {
    var variant: GeoButtonVariant = .primary
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(GeoTypography.headingM)
            .foregroundStyle(variant == .primary ? GeoColor.textOnAccent : GeoColor.textPrimary)
            .padding(.horizontal, GeoSpacing.xl)
            .padding(.vertical, GeoSpacing.sm)
            .background {
                Capsule()
                    .fill(variant == .primary ? GeoColor.accentPrimary : GeoColor.bgSurface)
            }
            .overlay {
                if variant == .secondary {
                    Capsule().strokeBorder(GeoColor.borderSubtle, lineWidth: 1.5)
                }
            }
            .shadow(
                color: variant == .primary ? GeoColor.accentPrimary.opacity(0.35) : .clear,
                radius: 9, x: 0, y: 8
            )
            .opacity(isEnabled ? 1 : 0.4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GeoButtonStyle {
    static var kasifPrimary: GeoButtonStyle { GeoButtonStyle(variant: .primary) }
    static var kasifSecondary: GeoButtonStyle { GeoButtonStyle(variant: .secondary) }
}

#Preview {
    VStack(spacing: GeoSpacing.lg) {
        Button("Başlayalım") {}.buttonStyle(.kasifPrimary)
        Button("Başlayalım") {}.buttonStyle(.kasifPrimary).disabled(true)
        Button("Başlayalım") {}.buttonStyle(.kasifSecondary)
        Button("Başlayalım") {}.buttonStyle(.kasifSecondary).disabled(true)
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
