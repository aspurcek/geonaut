import SwiftUI

/// Figma "Dünya Yemeklerini Öğren" (Dünya Yemekleri FLOW6 bölümü) — LearnLanguagesView'in
/// yemek eşleniği. Satırlarda ülkenin meşhur yemeği (dish) gösterilir — tatlı/içecek
/// bilgisi dokunulunca açılan GeoCountryInfoCard'da (bkz. cardInfo) yer alır.
struct LearnFoodsView: View {
    var onBack: () -> Void
    @State private var selectedCountry: FoodCardInfo?

    private var allCountries: [Country] { WorldFoods.learnableCountries.sortedLocalized(by: \.name) }

    var body: some View {
        LearnCatalogView(
            title: "Lezzetleri Öğren",
            subtitle: "Dünya ülkelerinin yemeklerini öğren",
            symbol: "fork.knife", tint: GeoColor.accentSuccess,
            countries: allCountries,
            detailIcon: "fork.knife",
            detail: { WorldFoods.item(for: $0.code, type: .yemek) },
            searchPlaceholder: "Ülke veya yemek ara...",
            matches: { country, query in
                country.name.localizedCaseInsensitiveContains(query)
                    || (WorldFoods.item(for: country.code, type: .yemek) ?? "").localizedCaseInsensitiveContains(query)
            },
            spotlightCaption: "Lezzet",
            spotlightFeaturesDetail: true,
            onSelect: { selectedCountry = cardInfo(for: $0) },
            onBack: onBack
        )
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
