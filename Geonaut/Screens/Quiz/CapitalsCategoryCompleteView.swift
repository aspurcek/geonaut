import SwiftUI

/// Başkentler kategorisinin 3 turu da bitince gösterilen kupa ekranı ("Başkent Ustası") — bkz.
/// GameProgress.isCategoryTrophyEarned(.capitals). Figma FLOW9.
struct CapitalsCategoryCompleteView: View {
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: GeoSpacing.lg) {
                AchievementChip(text: "YENİ KUPA", color: GeoColor.accentHighlight)

                GeoAuthIllustration(type: .trophy)
                    .kasifWinGlow()

                Text("Başkent Ustası!")
                    .font(.custom(GeoFontName.balooBold, size: 26))
                    .foregroundStyle(GeoColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Başkentler kategorisinin 3 turunu da bitirdin! Dünyanın ülkelerinin başkentlerini öğrendin.")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(GeoColor.textSecondary)
                    .multilineTextAlignment(.center)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: GeoSpacing.md) {
                    ForEach(CapitalStructure.continents, id: \.self) { continent in
                        VStack(spacing: GeoSpacing.xs) {
                            Circle()
                                .fill(GeoColor.accentSuccess)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Image(systemName: "building.columns.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.white)
                                }
                            Text(LocalizedStringKey(continent))
                                .font(.custom(GeoFontName.balooBold, size: 10))
                                .foregroundStyle(GeoColor.textPrimary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                    }
                }
                .padding(.top, GeoSpacing.sm)

                Button("Harika!", action: onContinue)
                    .buttonStyle(.kasifPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, GeoSpacing.sm)
            }
            .padding(.horizontal, GeoSpacing.xxl)
            .padding(.top, GeoSpacing.xxxxl)
            .padding(.bottom, GeoSpacing.xxxl)
        }
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
        .achievementCelebration()
    }
}

#Preview {
    CapitalsCategoryCompleteView(onContinue: {})
}
