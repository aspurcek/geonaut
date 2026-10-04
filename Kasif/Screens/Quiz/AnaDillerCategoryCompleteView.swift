import SwiftUI

/// Ana Diller kategorisinin tamamı (7 kıta + Karışık) bitince gösterilir — bkz.
/// GameProgress.isMainLanguageCategoryCompleted. MapCategoryCompleteView'daki zincir
/// deseniyle aynı: Dünya Yemekleri kategorisinin kilidini açar (bkz.
/// WorldFoodsCategoryCompleteView — Kaşif'in artık son kategorisi orası).
struct AnaDillerCategoryCompleteView: View {
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: KasifSpacing.lg) {
                KasifAuthIllustration(type: .trophy)
                    .kasifWinGlow()

                Text("Dil Ustası!")
                    .font(.custom(KasifFontName.balooBold, size: 26))
                    .foregroundStyle(KasifColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Diller kategorisinin 3 turunu da bitirdin! Dünyanın ülkelerinin ana dillerini öğrendin.")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(KasifColor.textSecondary)
                    .multilineTextAlignment(.center)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: KasifSpacing.md) {
                    ForEach(MainLanguageStructure.continents, id: \.self) { continent in
                        VStack(spacing: KasifSpacing.xs) {
                            Circle()
                                .fill(KasifColor.accentSuccess)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Image(systemName: "character.book.closed.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.white)
                                }
                            Text(LocalizedStringKey(continent))
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
    AnaDillerCategoryCompleteView(onContinue: {})
}
