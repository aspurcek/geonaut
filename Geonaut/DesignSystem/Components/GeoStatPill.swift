import SwiftUI

/// Figma Design System / Bileşenler / Stat Pill (node 105:365). Icon=Streak/Points/Hearts.
/// Oyun ekranlarının üst çubuğunda can/puan/seri göstergesi olarak kullanılır.
enum GeoStatPillIcon {
    case streak, points, hearts

    var systemImage: String {
        switch self {
        case .streak: "flame.fill"
        case .points: "diamond.fill"
        case .hearts: "heart.fill"
        }
    }

    var tint: Color {
        switch self {
        case .streak: GeoColor.accentPrimary
        case .points: GeoColor.accentInfoStrong
        case .hearts: GeoColor.accentDanger
        }
    }
}

struct GeoStatPill: View {
    let icon: GeoStatPillIcon
    let value: String

    var body: some View {
        HStack(spacing: GeoSpacing.sm) {
            Image(systemName: icon.systemImage)
                .font(.system(size: 18))
                .foregroundStyle(icon.tint)
                .symbolEffect(.bounce, options: .nonRepeating, value: icon == .hearts ? value : "")
                .overlay { fallingHeart }
            Text(value)
                .font(GeoTypography.bodyBoldL)
                .foregroundStyle(GeoColor.textPrimary)
        }
        .padding(.leading, GeoSpacing.md)
        .padding(.trailing, GeoSpacing.lg)
        .padding(.vertical, GeoSpacing.sm)
        .background(GeoColor.bgSurface, in: Capsule())
        .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dropped = false
    @State private var dropTrigger = 0

    /// Can azalınca kalbin bir kopyası aşağı düşüp sönerek kaybolur.
    @ViewBuilder private var fallingHeart: some View {
        if icon == .hearts {
            Image(systemName: "heart.slash.fill")
                .font(.system(size: 18))
                .foregroundStyle(icon.tint)
                .offset(y: dropped ? 30 : 0)
                .opacity(dropped ? 0 : (dropTrigger > 0 ? 1 : 0))
                .rotationEffect(.degrees(dropped ? 25 : 0))
                .onChange(of: value) { old, new in
                    guard !reduceMotion, let o = Int(old), let n = Int(new), n < o else { return }
                    dropTrigger += 1
                    dropped = false
                    withAnimation(.easeIn(duration: 0.6)) { dropped = true }
                }
        }
    }

    private var accessibilityText: String {
        switch icon {
        case .streak: return String(localized: "Seri: \(value) gün")
        case .points: return String(localized: "\(value) puan")
        case .hearts: return String(localized: "\(value) can")
        }
    }
}

#Preview {
    HStack(spacing: GeoSpacing.md) {
        GeoStatPill(icon: .streak, value: "12")
        GeoStatPill(icon: .points, value: "340")
        GeoStatPill(icon: .hearts, value: "3")
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
