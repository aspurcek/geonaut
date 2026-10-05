import SwiftUI

/// Figma "Etap Tamamlandı" (node 174:1066). Yıldız eşikleri GameRules.stars(correctCount:)
/// ile birebir uyumlu (bkz. Bayrak Tahmin Kural Kitabı böl. 06).
struct StageCompleteView: View {
    let stageIndex: Int // 0-based
    let correctCount: Int
    let pointsEarned: Int
    let heartsRemaining: Int
    var onContinue: () -> Void

    private var stars: Int { GameRules.stars(correctCount: correctCount) }

    var body: some View {
        VStack(spacing: GeoSpacing.lg) {
            Spacer()

            GeoAuthIllustration(type: .trophy)
                .kasifWinGlow()

            Text("Seviye \(stageIndex + 1) Tamamlandı!")
                .font(.custom(GeoFontName.balooBold, size: 26))
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)

            HStack(spacing: GeoSpacing.sm) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: index < stars ? "star.fill" : "star")
                        .font(.system(size: 26))
                        .foregroundStyle(GeoColor.accentHighlight)
                }
            }

            Text("\(GameRules.questionsPerStage) sorunun \(correctCount)'ünü doğru bildin!")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(GeoColor.textSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: GeoSpacing.md) {
                GeoStatPill(icon: .points, value: "+\(pointsEarned)")
                GeoStatPill(icon: .hearts, value: "\(heartsRemaining)")
            }
            .padding(.top, GeoSpacing.sm)

            Text("Kazandığın puan  ·  kalan canların")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(GeoColor.textMuted)

            Button("Başlayalım", action: onContinue)
                .buttonStyle(.kasifPrimary)
                .frame(maxWidth: .infinity)
                .padding(.top, GeoSpacing.sm)

            Spacer()
        }
        .padding(.horizontal, GeoSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
    }
}

#Preview {
    StageCompleteView(stageIndex: 0, correctCount: 9, pointsEarned: 90, heartsRemaining: 5, onContinue: {})
}
