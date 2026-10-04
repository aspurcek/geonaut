import SwiftUI

/// Figma "Dünya Yemeklerini Öğren" (Dünya Yemekleri FLOW6 bölümü) — LearnLanguagesView'in
/// yemek eşleniği. Satırlarda ülkenin meşhur yemeği (dish) gösterilir — tatlı/içecek
/// bilgisi dokunulunca açılan KasifCountryInfoCard'da (bkz. cardInfo) yer alır.
struct LearnFoodsView: View {
    var onBack: () -> Void
    @State private var query = ""
    @State private var selectedCountry: FoodCardInfo?

    private var allCountries: [Country] { WorldFoods.learnableCountries.sortedLocalized(by: \.name) }

    private var filtered: [Country] {
        guard !query.isEmpty else { return allCountries }
        return allCountries.filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || (WorldFoods.item(for: $0.code, type: .yemek) ?? "").localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .accessibilityLabel("Geri")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(KasifColor.textPrimary)
                    .padding(KasifSpacing.sm)
            }

            VStack(alignment: .leading, spacing: KasifSpacing.xs) {
                Text("Lezzetleri Öğren")
                    .font(.custom(KasifFontName.balooExtraBold, size: 24))
                    .foregroundStyle(KasifColor.textPrimary)
                Text("Dünya ülkelerinin yemeklerini öğren")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(KasifColor.textSecondary)
            }
            .padding(.top, KasifSpacing.sm)
            .padding(.bottom, KasifSpacing.lg)

            KasifSearchBar(placeholder: "Ülke veya yemek ara...", text: $query)
                .padding(.bottom, KasifSpacing.sm)

            if filtered.isEmpty {
                KasifStatusView(style: .empty, title: "Sonuç bulunamadı", subtitle: "Farklı bir ülke veya kelime denemeyi dene.")
            } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filtered, id: \.code) { country in
                        Button {
                            selectedCountry = cardInfo(for: country)
                        } label: {
                            KasifFlagListRow(
                                countryCode: country.code, countryName: country.name,
                                continentName: WorldFoods.item(for: country.code, type: .yemek)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            }
        }
        .padding(.horizontal, KasifSpacing.xl)
        .padding(.top, KasifSpacing.md)
        .background { KasifColor.bgSurface.ignoresSafeArea() }
        .foodInfoSheet(selected: $selectedCountry)
    }

    private func cardInfo(for country: Country) -> FoodCardInfo {
        let facts = FoodData.facts[country.code]
        return FoodCardInfo(
            code: country.code, name: country.name,
            dish: facts?.dish ?? "Bilinmiyor",
            dessert: facts?.dessert ?? "Bilinmiyor",
            drink: facts?.drink ?? "Bilinmiyor"
        )
    }
}

#Preview {
    LearnFoodsView(onBack: {})
}
