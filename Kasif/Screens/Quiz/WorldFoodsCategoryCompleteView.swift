import SwiftUI

/// Dünya Yemekleri kategorisinin tamamı (Yemekler/İçecekler/Tatlılar + Karışık) bitince
/// gösterilir — bkz. GameProgress.isWorldFoodCategoryCompleted. Kaşif'in dördüncü ve son
/// kategorisi olduğu için (bkz. MapCategoryCompleteView/AnaDillerCategoryCompleteView'daki
/// zincir notu) başka bir kategoriyi açtığını söylemez, genel bir "hepsini bitirdin" kutlaması yapar.
struct WorldFoodsCategoryCompleteView: View {
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: KasifSpacing.lg) {
                KasifAuthIllustration(type: .trophy)
                    .kasifWinGlow()

                Text("Lezzet Ustası!")
                    .font(.custom(KasifFontName.balooBold, size: 26))
                    .foregroundStyle(KasifColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Lezzetler kategorisinin 3 turunu da bitirdin! Dünyanın meşhur yemeklerini, tatlılarını ve içeceklerini öğrendin.")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(KasifColor.textSecondary)
                    .multilineTextAlignment(.center)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: KasifSpacing.md) {
                    ForEach(ContinentPathNode.worldFoodsOrder, id: \.name) { entry in
                        VStack(spacing: KasifSpacing.xs) {
                            Circle()
                                .fill(KasifColor.accentSuccessStrong)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Image(systemName: entry.systemImage)
                                        .font(.system(size: 16))
                                        .foregroundStyle(.white)
                                }
                            Text(LocalizedStringKey(entry.name))
                                .font(.custom(KasifFontName.balooBold, size: 10))
                                .foregroundStyle(KasifColor.textPrimary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                    }
                }
                .padding(.top, KasifSpacing.sm)

                Button("Başlayalım", action: onContinue)
                    .buttonStyle(.kasifPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, KasifSpacing.sm)
            }
            .padding(.horizontal, KasifSpacing.xxl)
            .padding(.top, KasifSpacing.xxxxl)
            .padding(.bottom, KasifSpacing.xxxl)
        }
        .background { KasifColor.bgCanvas.ignoresSafeArea() }
    }
}

#Preview {
    WorldFoodsCategoryCompleteView(onContinue: {})
}
