import SwiftUI

/// Figma Design System / Bileşenler / Achievement Badge (node 105:420). State=Unlocked/Locked.
/// İkon artık kategoriye özel bir emoji (bkz. BadgeCatalog) — Unlocked'ta tam renkli
/// kendi accent rengiyle, Locked'ta aynı emoji gri tonlanıp soluklaştırılmış hâlde
/// (silhouette preview) gösterilir. Bkz. Design System'deki "Rozet Simgeleri" referans
/// paneli (node 536:12128) — bu bileşenin Figma'daki birebir karşılığı.
struct KasifAchievementBadge: View {
    let title: String
    var icon: String = "🏅"
    var accentColor: Color = KasifColor.accentSuccess
    var state: State = .locked

    enum State { case unlocked, locked }

    var body: some View {
        VStack(spacing: KasifSpacing.sm) {
            Circle()
                .fill(state == .unlocked ? accentColor : KasifColor.bgLocked)
                .strokeBorder(state == .locked ? KasifColor.borderSubtle : .clear, lineWidth: 1.5)
                .frame(width: 56, height: 56)
                .overlay {
                    Text(icon)
                        .font(.system(size: 26))
                        .grayscale(state == .locked ? 1 : 0)
                        .opacity(state == .locked ? 0.35 : 1)
                }
                .overlay(alignment: .bottomTrailing) {
                    if state == .locked {
                        Image(systemName: "lock.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(KasifColor.textMuted, KasifColor.bgCanvas)
                            .offset(x: 4, y: 4)
                    }
                }

            Text(LocalizedStringKey(title))
                .font(.custom(KasifFontName.balooBold, size: 14))
                .foregroundStyle(state == .locked ? KasifColor.textMuted : KasifColor.textPrimary)
                .lineLimit(1)
                .fixedSize()
        }
    }
}

#Preview {
    HStack(spacing: KasifSpacing.xl) {
        KasifAchievementBadge(title: "Avrupa", icon: "🗼", accentColor: KasifColor.accentPrimary, state: .unlocked)
        KasifAchievementBadge(title: "Asya", icon: "🐼", state: .locked)
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
