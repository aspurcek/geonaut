import SwiftUI

/// Figma "Serini Kaybettin" (node 508:12138) — 50 puanla canlandırma teklifi.
struct StreakLostView: View {
    let streakDays: Int
    let points: Int
    var onRevive: () -> Void
    var onGiveUp: () -> Void

    private var canAffordRevive: Bool { points >= GameRules.streakReviveCost }

    var body: some View {
        VStack(spacing: GeoSpacing.xl) {
            Spacer()

            Text("\(streakDays) Günlük Serin")
                .font(.custom(GeoFontName.balooExtraBold, size: 22))
                .foregroundStyle(GeoColor.accentPrimary)

            GeoAuthIllustration(type: .streak)

            Text("Serini Kaybettin!")
                .font(.custom(GeoFontName.balooBold, size: 24))
                .foregroundStyle(GeoColor.textPrimary)

            Text("\(streakDays) günlük serin sona erdi. \(GameRules.streakReviveCost) puan harcayarak serini kaldığın yerden canlandırabilirsin.")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(GeoColor.textSecondary)
                .multilineTextAlignment(.center)

            GeoStatPill(icon: .points, value: "\(points)")

            VStack(spacing: GeoSpacing.md) {
                Button("\(GameRules.streakReviveCost) Puan ile Canlandır", action: onRevive)
                    .buttonStyle(.kasifPrimary)
                    .frame(maxWidth: .infinity)
                    .disabled(!canAffordRevive)

                Button("Vazgeç", action: onGiveUp)
                    .buttonStyle(.kasifSecondary)
                    .frame(maxWidth: .infinity)
            }

            Spacer()
        }
        .padding(.horizontal, GeoSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
    }
}

#Preview {
    StreakLostView(streakDays: 12, points: 340, onRevive: {}, onGiveUp: {})
}
