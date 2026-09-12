import SwiftUI

/// Harita Bilmece'nin kategori tamamlama ekranı — Kıtalar VE Ülkeler bölümlerinin ikisi
/// de bitince gösterilir (bkz. GameProgress.isMapPuzzleCategoryCompleted), Ana Diller'in
/// kilidini açar. Bayrak Tahmin'deki "Kıta Tamamlandı" ara ekranının eşi yoktur — her iki
/// bölüm de kendi Etap Haritası akışının sonunda doğrudan bu ekrana (ya da geri Giriş'e) çıkar.
struct MapCategoryCompleteView: View {
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: KasifSpacing.lg) {
                KasifAuthIllustration(type: .trophy)

                Text("Harita Bilmece Kupası!")
                    .font(.custom(KasifFontName.balooBold, size: 26))
                    .foregroundStyle(KasifColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Dünyanın 7 kıtasını ve ülkelerini haritada bulmayı öğrendin! Ana Diller kategorisinin kilidi açıldı.")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(KasifColor.textSecondary)
                    .multilineTextAlignment(.center)

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
    MapCategoryCompleteView(onContinue: {})
}
