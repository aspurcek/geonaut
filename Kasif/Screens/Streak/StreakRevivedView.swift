import SwiftUI

/// Figma "Serini Canlandırdın" (node 508:12174).
struct StreakRevivedView: View {
    let streakDays: Int
    let pointsSpent: Int
    let pointsRemaining: Int
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: KasifSpacing.lg) {
            Spacer()

            KasifAuthIllustration(type: .success)

            Text("Serin Canlandırıldı! 🎉")
                .font(.custom(KasifFontName.balooBold, size: 26))
                .foregroundStyle(KasifColor.textPrimary)

            confetti

            Text("\(streakDays) günlük serin kaldığı yerden devam ediyor. Yarın da unutma!")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(KasifColor.textSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: KasifSpacing.md) {
                KasifStatPill(icon: .points, value: "-\(pointsSpent)")
                KasifStatPill(icon: .points, value: "\(pointsRemaining)")
            }
            .padding(.top, KasifSpacing.sm)

            Text("Harcanan puan  ·  kalan puanın")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(KasifColor.textMuted)

            Button("Devam Et", action: onContinue)
                .buttonStyle(.kasifPrimary)
                .frame(maxWidth: .infinity)

            Spacer()
        }
        .padding(.horizontal, KasifSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { KasifColor.bgCanvas.ignoresSafeArea() }
    }

    /// Figma'daki 5 yıldızlı konfeti şeridinin (node 508:12179) sabit renk/boyut
    /// dizilimine yakın basit bir SF Symbol yaklaşımı.
    private var confetti: some View {
        HStack(spacing: KasifSpacing.md) {
            Image(systemName: "star.fill").font(.system(size: 22)).foregroundStyle(KasifColor.accentHighlight)
            Image(systemName: "star.fill").font(.system(size: 18)).foregroundStyle(KasifColor.accentSuccess)
            Image(systemName: "star.fill").font(.system(size: 22)).foregroundStyle(KasifColor.accentPrimary)
            Image(systemName: "star.fill").font(.system(size: 12)).foregroundStyle(KasifColor.accentTertiary)
            Image(systemName: "star.fill").font(.system(size: 12)).foregroundStyle(KasifColor.accentInfo)
        }
    }
}

#Preview {
    StreakRevivedView(streakDays: 12, pointsSpent: 50, pointsRemaining: 290, onContinue: {})
}
