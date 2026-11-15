import SwiftUI

/// "Başkentleri Öğren" (FLOW9) — ortak LearnCatalogView iskeletiyle (2026-11-14).
/// Satırlar dokunulabilir; kart ülke adı/bayrağı/başkenti/kıtasını gösterir.
struct LearnCapitalsView: View {
    var onBack: () -> Void
    @State private var selectedCountry: CountryCardInfo?

    private var allCountries: [Country] { Capitals.learnableCountries.sortedLocalized(by: \.name) }

    var body: some View {
        LearnCatalogView(
            title: "Başkentleri Öğren",
            subtitle: "\(allCountries.count) ülkenin başkentini keşfet",
            symbol: "building.columns.fill", tint: GeoColor.accentHighlight,
            countries: allCountries,
            detailIcon: "building.columns.fill",
            detail: { Capitals.name(for: $0.code) },
            searchPlaceholder: "Ülke veya başkent ara...",
            matches: { country, query in
                country.name.localizedCaseInsensitiveContains(query)
                    || Capitals.name(for: country.code).localizedCaseInsensitiveContains(query)
            },
            spotlightCaption: "Başkent",
            spotlightFeaturesDetail: true,
            onSelect: { selectedCountry = cardInfo(for: $0) },
            onBack: onBack
        )
        .countryInfoSheet(selected: $selectedCountry)
    }

    private func cardInfo(for country: Country) -> CountryCardInfo {
        let facts = CountryData.facts(for: country.code)
        return CountryCardInfo(
            code: country.code, name: country.name,
            language: facts?.mainLanguage ?? "Bilinmiyor",
            continent: facts?.continent ?? "Bilinmiyor",
            capital: Capitals.name(for: country.code)
        )
    }
}

#Preview {
    LearnCapitalsView(onBack: {})
}
