import SwiftUI

/// Harita Bilmece'nin kategori tamamlama ekranı — Kıtalar VE Ülkeler bölümlerinin ikisi
/// de bitince gösterilir (bkz. GameProgress.isMapPuzzleCategoryCompleted), Ana Diller'in
/// kilidini açar. Bayrak Tahmin'deki "Kıta Tamamlandı" ara ekranının eşi yoktur — her iki
/// bölüm de kendi Etap Haritası akışının sonunda doğrudan bu ekrana (ya da geri Giriş'e) çıkar.
struct MapCategoryCompleteView: View {
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: GeoSpacing.lg) {
                AchievementChip(text: "YENİ KUPA", color: GeoColor.accentHighlight)

                GeoAuthIllustration(type: .trophy)
                    .kasifWinGlow()

                Text("Harita Ustası!")
                    .font(.custom(GeoFontName.balooBold, size: 26))
                    .foregroundStyle(GeoColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Haritalar kategorisinin 3 turunu da bitirdin! Kıtaları ve ülkeleri haritada bulmayı öğrendin.")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(GeoColor.textSecondary)
                    .multilineTextAlignment(.center)

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
    MapCategoryCompleteView(onContinue: {})
}
