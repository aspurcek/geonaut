import SwiftUI

/// "Ana Dilleri Öğren" (Ana Diller FLOW5) — ortak LearnCatalogView iskeletiyle (2026-11-14).
/// Satırlar dokunulabilir; kart ülke adı/bayrağı/dili/kıtasını gösterir.
struct LearnLanguagesView: View {
    var onBack: () -> Void
    @State private var selectedCountry: CountryCardInfo?

    private var allCountries: [Country] { Languages.learnableCountries.sortedLocalized(by: \.name) }

    var body: some View {
        LearnCatalogView(
            title: "Dilleri Öğren",
            subtitle: "\(allCountries.count)+ ülkenin ana dilini keşfet",
            symbol: "character.book.closed.fill", tint: GeoColor.accentTertiary,
            countries: allCountries,
            detailIcon: "character.bubble.fill",
            detail: { Languages.language(for: $0.code) },
            searchPlaceholder: "Ülke veya dil ara...",
            matches: { country, query in
                country.name.localizedCaseInsensitiveContains(query)
                    || Languages.language(for: country.code).localizedCaseInsensitiveContains(query)
            },
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
            continent: facts?.continent ?? "Bilinmiyor"
        )
    }
}

#Preview {
    LearnLanguagesView(onBack: {})
}
