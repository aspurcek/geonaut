import SwiftUI

/// Figma "Dünya Yemeklerini Öğren" (Dünya Yemekleri FLOW6 bölümü) — LearnLanguagesView'in
/// yemek eşleniği. Satırlarda ülkenin meşhur yemeği (dish) gösterilir — tatlı/içecek
/// bilgisi dokunulunca açılan GeoCountryInfoCard'da (bkz. cardInfo) yer alır.
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
                    .foregroundStyle(GeoColor.textPrimary)
                    .padding(GeoSpacing.sm)
            }

            VStack(alignment: .leading, spacing: GeoSpacing.xs) {
                Text("Lezzetleri Öğren")
                    .font(.custom(GeoFontName.balooExtraBold, size: 24))
                    .foregroundStyle(GeoColor.textPrimary)
                Text("Dünya ülkelerinin yemeklerini öğren")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(GeoColor.textSecondary)
            }
            .padding(.top, GeoSpacing.sm)
            .padding(.bottom, GeoSpacing.lg)

            GeoSearchBar(placeholder: "Ülke veya yemek ara...", text: $query)
                .padding(.bottom, GeoSpacing.sm)

            if filtered.isEmpty {
                GeoStatusView(style: .empty, title: "Sonuç bulunamadı", subtitle: "Farklı bir ülke veya kelime denemeyi dene.")
            } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filtered, id: \.code) { country in
                        Button {
                            selectedCountry = cardInfo(for: country)
                        } label: {
                            GeoFlagListRow(
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
        .padding(.horizontal, GeoSpacing.xl)
        .padding(.top, GeoSpacing.md)
        .background { GeoColor.bgSurface.ignoresSafeArea() }
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
