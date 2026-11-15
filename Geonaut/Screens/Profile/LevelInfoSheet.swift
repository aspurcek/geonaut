import SwiftUI

/// Bir toplam puanın ünvan durumu — profil rozeti, ince çubuk ve bilgi sayfası aynı hesabı kullanır.
struct LevelStanding {
    let level: GeoLevel
    let next: GeoLevel?
    let points: Int
    /// Sıradaki ünvanın puan eşiği (en üst ünvanda nil).
    let upper: Int?
    /// Bulunulan ünvandan sıradakine 0...1 ilerleme (en üst ünvanda 1).
    let fraction: Double

    init(points: Int) {
        let thresholds = GameRules.levelThresholds
        let level = GeoLevel.level(forPoints: points)
        let index = level.rank
        self.level = level
        self.points = points
        if index < thresholds.count {
            let lower = index == 0 ? 0 : thresholds[index - 1]
            let upper = thresholds[index]
            self.next = GeoLevel.allCases[index + 1]
            self.upper = upper
            self.fraction = min(1, max(0, Double(points - lower) / Double(upper - lower)))
        } else {
            self.next = nil
            self.upper = nil
            self.fraction = 1
        }
    }

    /// Ünvanın başladığı puan (merdiven listesi için).
    static func threshold(of level: GeoLevel) -> Int {
        level.rank == 0 ? 0 : GameRules.levelThresholds[level.rank - 1]
    }
}

/// Profildeki ünvan rozetine dokununca açılan alt sayfa: şu anki ünvan, sıradaki ünvana ilerleme ve
/// tüm ünvanların merdiveni.
struct LevelInfoSheet: View {
    let standing: LevelStanding
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            VStack(spacing: GeoSpacing.lg) {
                Circle()
                    .fill(standing.level.accentColor)
                    .frame(width: 80, height: 80)
                    .overlay {
                        Image(systemName: standing.level.symbol)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(GeoGlyph.ink(on: standing.level.accentColor))
                    }

                Text(L(standing.level.title))
                    .font(.custom(GeoFontName.balooExtraBold, size: 24))
                    .foregroundStyle(GeoColor.textPrimary)

                VStack(spacing: 6) {
                    if let next = standing.next, let upper = standing.upper {
                        Text("Sıradaki ünvan: \(L(next.title))")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(GeoColor.textMuted)
                        GlitterBar(progress: standing.fraction, color: standing.level.accentColor, animated: !reduceMotion)
                            .frame(width: 220, height: 10)
                        Text("\(standing.points) / \(upper) puan")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(GeoColor.textSecondary)
                            .monospacedDigit()
                    } else {
                        Text("En yüksek ünvandasın")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(GeoColor.textMuted)
                        GlitterBar(progress: 1, color: standing.level.accentColor, animated: !reduceMotion)
                            .frame(width: 220, height: 10)
                        Text("\(standing.points) puan")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(GeoColor.textSecondary)
                            .monospacedDigit()
                    }
                }

                Text("Ünvanlar, toplam kazandığın puana göre yükselir.")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(GeoColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, GeoSpacing.xs)

                VStack(spacing: 0) {
                    ForEach(GeoLevel.allCases.reversed(), id: \.self) { level in
                        ladderRow(level)
                    }
                }
            }
            .padding(.horizontal, GeoSpacing.xl)
            .padding(.top, GeoSpacing.xl)
            .padding(.bottom, GeoSpacing.xxxl)
        }
        .background(Color.white)
        .presentationDetents([.fraction(0.78), .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.white)
    }

    private func ladderRow(_ level: GeoLevel) -> some View {
        let reached = level.rank <= standing.level.rank
        let isCurrent = level == standing.level
        return HStack(spacing: GeoSpacing.md) {
            GeoGlyphCircle(symbol: level.symbol, background: level.accentColor, size: 34, locked: !reached)
            Text(L(level.title))
                .font(.custom(GeoFontName.balooBold, size: 16))
                .foregroundStyle(reached ? GeoColor.textPrimary : GeoColor.textMuted)
            Spacer()
            Text("\(LevelStanding.threshold(of: level)) puan")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(GeoColor.textMuted)
                .monospacedDigit()
            if reached {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(GeoColor.accentSuccessStrong)
            }
        }
        .padding(.vertical, 9)
        .padding(.horizontal, GeoSpacing.md)
        .background(isCurrent ? level.accentColor.opacity(0.22) : .clear, in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    LevelInfoSheet(standing: LevelStanding(points: 340))
}
