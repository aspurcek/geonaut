import SwiftUI

/// Figma "Kategori Tamamlandı - Bayrak Tahmin" (node 176:1122). 8 bölümün (7 kıta +
/// Karışık) tamamı bitince gösterilir; Harita Bilmece'nin kilidini açar (bkz. Bayrak
/// Tahmin Kural Kitabı böl. 04, 07).
struct CategoryCompleteView: View {
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: KasifSpacing.lg) {
                KasifAuthIllustration(type: .trophy)

                Text("Bayrak Bilmece Kupası!")
                    .font(.custom(KasifFontName.balooBold, size: 26))
                    .foregroundStyle(KasifColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Dünyadaki tüm kıtaların bayraklarını öğrendin! Harita Bilmece kategorisinin kilidi açıldı.")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(KasifColor.textSecondary)
                    .multilineTextAlignment(.center)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: KasifSpacing.md) {
                    ForEach(FlagGuessStructure.continents, id: \.self) { continent in
                        VStack(spacing: KasifSpacing.xs) {
                            Circle()
                                .fill(KasifColor.accentSuccess)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Image(systemName: "globe")
                                        .font(.system(size: 18))
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
    CategoryCompleteView(onContinue: {})
}
