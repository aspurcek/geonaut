import SwiftUI

/// Figma "Rozet Kazanıldı" (FLOW7- Tebrik Ekranları). Kıta rozeti olmayan rozetler için: Haritalar'ın
/// Kıtalar / Ülkeler rozeti ve her kategorinin "Karışık" bölümü rozeti.
struct BadgeEarnedView: View {
    let title: String
    let icon: String
    let accentColor: Color
    let headline: LocalizedStringKey
    let message: LocalizedStringKey
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: GeoSpacing.lg) {
            Spacer()

            AchievementChip(text: "YENİ ROZET", color: accentColor)

            GeoAchievementBadge(title: title, icon: icon, accentColor: accentColor, state: .unlocked)
                .scaleEffect(1.1)
                .kasifWinGlow(color: accentColor)

            Text(headline)
                .font(.custom(GeoFontName.balooBold, size: 24))
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(GeoColor.textSecondary)
                .multilineTextAlignment(.center)

            Button("Harika!", action: onContinue)
                .buttonStyle(.kasifPrimary)
                .frame(maxWidth: .infinity)
                .padding(.top, GeoSpacing.sm)

            Spacer()
        }
        .padding(.horizontal, GeoSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
        .achievementCelebration(confetti: true)
    }
}

#Preview {
    BadgeEarnedView(title: "Kıtalar Rozeti", icon: "🌍", accentColor: GeoColor.accentInfo,
                    headline: "Yeni rozet kazandın!", message: "Haritalar'da Kıtalar bölümünün 8 seviyesini tamamladın.", onContinue: {})
}
