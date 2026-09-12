import SwiftUI

/// Figma Design System / Bileşenler / Achievement Badge (node 105:420). State=Unlocked/Locked.
struct KasifAchievementBadge: View {
    let title: String
    var systemImage: String = "checkmark"
    var state: State = .locked

    enum State { case unlocked, locked }

    var body: some View {
        VStack(spacing: KasifSpacing.sm) {
            Circle()
                .fill(state == .unlocked ? KasifColor.accentSuccess : Color.clear)
                .strokeBorder(state == .locked ? KasifColor.borderSubtle : .clear, lineWidth: 1.5)
                .frame(width: 56, height: 56)
                .overlay {
                    if state == .unlocked {
                        Image(systemName: systemImage)
                            .font(.system(size: 22))
                            .foregroundStyle(KasifColor.textOnAccent)
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    if state == .locked {
                        Image(systemName: "lock.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(KasifColor.textMuted, KasifColor.bgCanvas)
                            .offset(x: 4, y: 4)
                    }
                }

            Text(title)
                .font(.custom(KasifFontName.balooBold, size: 14))
                .foregroundStyle(state == .locked ? KasifColor.textMuted : KasifColor.textPrimary)
                .lineLimit(1)
                .fixedSize()
        }
    }
}

#Preview {
    HStack(spacing: KasifSpacing.xl) {
        KasifAchievementBadge(title: "Avrupa", systemImage: "globe.europe.africa.fill", state: .unlocked)
        KasifAchievementBadge(title: "Asya", state: .locked)
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
