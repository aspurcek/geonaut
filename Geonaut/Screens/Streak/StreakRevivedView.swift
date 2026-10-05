import SwiftUI

/// Figma "Serini Canlandırdın" (node 508:12174).
struct StreakRevivedView: View {
    let streakDays: Int
    let pointsSpent: Int
    let pointsRemaining: Int
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: GeoSpacing.lg) {
            Spacer()

            GeoAuthIllustration(type: .success)

            Text("Serin Canlandırıldı! 🎉")
                .font(.custom(GeoFontName.balooBold, size: 26))
                .foregroundStyle(GeoColor.textPrimary)

            confetti

            Text("\(streakDays) günlük serin kaldığı yerden devam ediyor. Yarın da unutma!")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(GeoColor.textSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: GeoSpacing.md) {
                GeoStatPill(icon: .points, value: "-\(pointsSpent)")
                GeoStatPill(icon: .points, value: "\(pointsRemaining)")
            }
            .padding(.top, GeoSpacing.sm)

            Text("Harcanan puan  ·  kalan puanın")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(GeoColor.textMuted)

            Button("Devam Et", action: onContinue)
                .buttonStyle(.kasifPrimary)
                .frame(maxWidth: .infinity)

            Spacer()
        }
        .padding(.horizontal, GeoSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
    }

    /// Figma'daki 5 yıldızlı konfeti şeridinin (node 508:12179) sabit renk/boyut
    /// dizilimine yakın basit bir SF Symbol yaklaşımı.
    private var confetti: some View {
        HStack(spacing: GeoSpacing.md) {
            Image(systemName: "star.fill").font(.system(size: 22)).foregroundStyle(GeoColor.accentHighlight)
            Image(systemName: "star.fill").font(.system(size: 18)).foregroundStyle(GeoColor.accentSuccess)
            Image(systemName: "star.fill").font(.system(size: 22)).foregroundStyle(GeoColor.accentPrimary)
            Image(systemName: "star.fill").font(.system(size: 12)).foregroundStyle(GeoColor.accentTertiary)
            Image(systemName: "star.fill").font(.system(size: 12)).foregroundStyle(GeoColor.accentInfo)
        }
    }
}

#Preview {
    StreakRevivedView(streakDays: 12, pointsSpent: 50, pointsRemaining: 290, onContinue: {})
}
