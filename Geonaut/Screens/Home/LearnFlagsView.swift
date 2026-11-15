import SwiftUI

/// "Bayrakları Öğren" (ilk sürüm: Figma node 278:2394) — 2026-11-14'ten beri ortak
/// LearnCatalogView iskeletiyle: günün ülkesi, kıta filtreleri, varsayılan ızgara görünümü.
/// Kural Kitabı böl. 02: "Oyun dışı, baskısız bir keşif alanı — puan veya can etkilemez."
struct LearnFlagsView: View {
    var onBack: () -> Void
    @State private var selectedCountry: CountryCardInfo?

    private var allCountries: [Country] { Countries.all.sortedLocalized(by: \.name) }

    var body: some View {
        LearnCatalogView(
            title: "Bayrakları Öğren",
            subtitle: "\(allCountries.count) ülkenin bayrağını keşfet",
            symbol: "flag.fill", tint: GeoColor.accentPrimary,
            countries: allCountries,
            detailIcon: "globe.europe.africa.fill",
            detail: { CountryData.facts(for: $0.code)?.continent },
            searchPlaceholder: "Bayrak veya ülke adı ara...",
            prefersGrid: true,
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
    LearnFlagsView(onBack: {})
}
