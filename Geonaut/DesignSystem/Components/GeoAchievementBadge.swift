import SwiftUI

/// Figma Design System / Bileşenler / Achievement Badge (node 105:420). State=Unlocked/Locked.
/// İkon kategoriye özel bir SF Symbol (bkz. BadgeCatalog, GeoGlyph; 2026-11-13 emojiden geçildi) — Unlocked'ta tam renkli
/// kendi accent rengiyle, Locked'ta aynı emoji gri tonlanıp soluklaştırılmış hâlde
/// (silhouette preview) gösterilir. Bkz. Design System'deki "Rozet Simgeleri" referans
/// paneli (node 536:12128) — bu bileşenin Figma'daki birebir karşılığı.
struct GeoAchievementBadge: View {
    let title: String
    var icon: String = "rosette"
    var accentColor: Color = GeoColor.accentSuccess
    var state: State = .locked
    var size: CGFloat = 56

    enum State { case unlocked, locked }

    var body: some View {
        VStack(spacing: GeoSpacing.sm) {
            GeoMedal(symbol: icon, color: accentColor, size: size, locked: state == .locked)
                .overlay(alignment: .bottomTrailing) {
                    if state == .locked {
                        Image(systemName: "lock.circle.fill")
                            .font(.system(size: size * 0.32))
                            .foregroundStyle(GeoColor.textMuted, GeoColor.bgCanvas)
                            .offset(x: 4, y: 4)
                    }
                }

            Text(LocalizedStringKey(title))
                .font(.custom(GeoFontName.balooBold, size: 14))
                .foregroundStyle(state == .locked ? GeoColor.textMuted : GeoColor.textPrimary)
                .lineLimit(1)
                .fixedSize()
        }
    }
}

#Preview {
    HStack(spacing: GeoSpacing.xl) {
        GeoAchievementBadge(title: "Avrupa", icon: "building.columns.fill", accentColor: GeoColor.accentPrimary, state: .unlocked)
        GeoAchievementBadge(title: "Asya", icon: "mountain.2.fill", state: .locked)
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
