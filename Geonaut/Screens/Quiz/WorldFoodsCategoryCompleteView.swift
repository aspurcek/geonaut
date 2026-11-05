import SwiftUI

/// Dünya Yemekleri kategorisinin tamamı (Yemekler/İçecekler/Tatlılar + Karışık) bitince
/// gösterilir — bkz. GameProgress.isWorldFoodCategoryCompleted. Kaşif'in dördüncü ve son
/// kategorisi olduğu için (bkz. MapCategoryCompleteView/AnaDillerCategoryCompleteView'daki
/// zincir notu) başka bir kategoriyi açtığını söylemez, genel bir "hepsini bitirdin" kutlaması yapar.
struct WorldFoodsCategoryCompleteView: View {
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: GeoSpacing.lg) {
                AchievementChip(text: "YENİ KUPA", color: GeoColor.accentHighlight)

                GeoAuthIllustration(type: .trophy)
                    .kasifWinGlow()

                Text("Lezzet Ustası!")
                    .font(.custom(GeoFontName.balooBold, size: 26))
                    .foregroundStyle(GeoColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Lezzetler kategorisinin 3 turunu da bitirdin! Dünyanın meşhur yemeklerini, tatlılarını ve içeceklerini öğrendin.")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(GeoColor.textSecondary)
                    .multilineTextAlignment(.center)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: GeoSpacing.md) {
                    ForEach(ContinentPathNode.worldFoodsOrder, id: \.name) { entry in
                        VStack(spacing: GeoSpacing.xs) {
                            Circle()
                                .fill(GeoColor.accentSuccessStrong)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Image(systemName: entry.systemImage)
                                        .font(.system(size: 16))
                                        .foregroundStyle(.white)
                                }
                            Text(LocalizedStringKey(entry.name))
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
    WorldFoodsCategoryCompleteView(onContinue: {})
}
