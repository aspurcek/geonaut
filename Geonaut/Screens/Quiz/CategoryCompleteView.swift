import SwiftUI

/// Figma "Kategori Tamamlandı - Bayrak Tahmin" (node 176:1122). 8 bölümün (7 kıta +
/// Karışık) tamamı bitince gösterilir; Harita Bilmece'nin kilidini açar (bkz. Bayrak
/// Tahmin Kural Kitabı böl. 04, 07).
struct CategoryCompleteView: View {
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: GeoSpacing.lg) {
                AchievementChip(text: "YENİ KUPA", color: GeoColor.accentHighlight)

                GeoAuthIllustration(type: .trophy)
                    .kasifWinGlow()

                Text("Bayrak Ustası!")
                    .font(.custom(GeoFontName.balooBold, size: 26))
                    .foregroundStyle(GeoColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Bayraklar kategorisinin 3 turunu da bitirdin! Dünyadaki tüm kıtaların bayraklarını öğrendin.")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(GeoColor.textSecondary)
                    .multilineTextAlignment(.center)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: GeoSpacing.md) {
                    ForEach(FlagGuessStructure.continents, id: \.self) { continent in
                        VStack(spacing: GeoSpacing.xs) {
                            Circle()
                                .fill(GeoColor.accentSuccess)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Image(systemName: "globe")
                                        .font(.system(size: 18))
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

                Button("Başlayalım", action: onContinue)
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
    CategoryCompleteView(onContinue: {})
}
