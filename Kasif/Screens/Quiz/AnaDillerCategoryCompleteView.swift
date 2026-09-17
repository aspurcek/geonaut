import SwiftUI

/// Ana Diller kategorisinin tamamı (7 kıta + Karışık) bitince gösterilir — bkz.
/// GameProgress.isMainLanguageCategoryCompleted. Kaşif'in üçüncü ve son kategorisi
/// olduğu için (bkz. MapCategoryCompleteView'daki zincir notu) başka bir kategoriyi
/// açtığını söylemez, genel bir "hepsini bitirdin" kutlaması yapar.
struct AnaDillerCategoryCompleteView: View {
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: KasifSpacing.lg) {
                KasifAuthIllustration(type: .trophy)

                Text("Ana Diller Kupası!")
                    .font(.custom(KasifFontName.balooBold, size: 26))
                    .foregroundStyle(KasifColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Dünyanın 7 kıtasındaki ülkelerin ana dillerini öğrendin! Kaşif'in tüm kategorilerini tamamladın.")
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
                            Text(continent)
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
        .background(KasifColor.bgCanvas)
    }
}

#Preview {
    AnaDillerCategoryCompleteView(onContinue: {})
}
