import SwiftUI

/// Figma "Serini Kaybettin" (node 508:12138) — 50 puanla canlandırma teklifi.
struct StreakLostView: View {
    let streakDays: Int
    let points: Int
    var onRevive: () -> Void
    var onGiveUp: () -> Void

    private var canAffordRevive: Bool { points >= GameRules.streakReviveCost }

    var body: some View {
        VStack(spacing: KasifSpacing.xl) {
            Spacer()

            Text("\(streakDays) Günlük Serin")
                .font(.custom(KasifFontName.balooExtraBold, size: 22))
                .foregroundStyle(KasifColor.accentPrimary)

            KasifAuthIllustration(type: .streak)

            Text("Serini Kaybettin!")
                .font(.custom(KasifFontName.balooBold, size: 24))
                .foregroundStyle(KasifColor.textPrimary)

            Text("\(streakDays) günlük serin sona erdi. \(GameRules.streakReviveCost) puan harcayarak serini kaldığın yerden canlandırabilirsin.")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(KasifColor.textSecondary)
                .multilineTextAlignment(.center)

            KasifStatPill(icon: .points, value: "\(points)")

            VStack(spacing: KasifSpacing.md) {
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
        .padding(.horizontal, KasifSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { KasifColor.bgCanvas.ignoresSafeArea() }
    }
}

#Preview {
    StreakLostView(streakDays: 12, points: 340, onRevive: {}, onGiveUp: {})
}
