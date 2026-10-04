import SwiftUI

/// Bir kategorinin Tur 1 ya da Tur 2'si bitince gösterilir (Tur 3 bitince kupa ekranı çıkar,
/// bkz. HomeView.advanceAfterStage). Tur 1 bitince ayrıca bir sonraki KATEGORİNİN açıldığı
/// söylenir (kullanıcı kararı: diğer kategoriler yalnızca Tur 1'le açılır).
struct TourCompleteView: View {
    let category: TourCategory
    /// Az önce biten tur, 0 tabanlı (0 = Tur 1).
    let tour: Int
    var onContinue: () -> Void

    private var categoryTitle: LocalizedStringKey {
        switch category {
        case .flags: "Bayraklar"
        case .maps: "Haritalar"
        case .languages: "Diller"
        case .foods: "Lezzetler"
        }
    }

    private var nextCategoryTitle: LocalizedStringKey? {
        switch category {
        case .flags: "Haritalar"
        case .maps: "Diller"
        case .languages: "Lezzetler"
        case .foods: nil
        }
    }

    var body: some View {
        VStack(spacing: KasifSpacing.lg) {
            Spacer()

            KasifAuthIllustration(type: .success)
                .kasifWinGlow(color: KasifColor.accentSuccess)

            Text("Tur \(tour + 1) Tamamlandı!")
                .font(.custom(KasifFontName.balooBold, size: 26))
                .foregroundStyle(KasifColor.textPrimary)
                .multilineTextAlignment(.center)

            Text("\(Text(categoryTitle)) kategorisinde Tur \(tour + 1)'i bitirdin. Tur \(tour + 2) açıldı: aynı yol, yepyeni sorular!")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(KasifColor.textSecondary)
                .multilineTextAlignment(.center)

            if tour == 0, let next = nextCategoryTitle {
                Text("\(Text(next)) kategorisinin de kilidi açıldı.")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(KasifColor.accentSuccessStrong)
                    .multilineTextAlignment(.center)
            }

            Button("Başlayalım", action: onContinue)
                .buttonStyle(.kasifPrimary)
                .frame(maxWidth: .infinity)
                .padding(.top, KasifSpacing.sm)

            Spacer()
        }
        .padding(.horizontal, KasifSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { KasifColor.bgCanvas.ignoresSafeArea() }
    }
}

#Preview {
    TourCompleteView(category: .flags, tour: 0, onContinue: {})
}
