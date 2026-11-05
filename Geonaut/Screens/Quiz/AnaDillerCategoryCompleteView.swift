import SwiftUI

/// Ana Diller kategorisinin tamamı (7 kıta + Karışık) bitince gösterilir — bkz.
/// GameProgress.isMainLanguageCategoryCompleted. MapCategoryCompleteView'daki zincir
/// deseniyle aynı: Dünya Yemekleri kategorisinin kilidini açar (bkz.
/// WorldFoodsCategoryCompleteView — Kaşif'in artık son kategorisi orası).
struct AnaDillerCategoryCompleteView: View {
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: GeoSpacing.lg) {
                AchievementChip(text: "YENİ KUPA", color: GeoColor.accentHighlight)

                GeoAuthIllustration(type: .trophy)
                    .kasifWinGlow()

                Text("Dil Ustası!")
                    .font(.custom(GeoFontName.balooBold, size: 26))
                    .foregroundStyle(GeoColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Diller kategorisinin 3 turunu da bitirdin! Dünyanın ülkelerinin ana dillerini öğrendin.")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(GeoColor.textSecondary)
                    .multilineTextAlignment(.center)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: GeoSpacing.md) {
                    ForEach(MainLanguageStructure.continents, id: \.self) { continent in
                        VStack(spacing: GeoSpacing.xs) {
                            Circle()
                                .fill(GeoColor.accentSuccess)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Image(systemName: "character.book.closed.fill")
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
    AnaDillerCategoryCompleteView(onContinue: {})
}
