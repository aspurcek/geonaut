import SwiftUI

/// Figma "Başkentleri Öğren" (FLOW9) — LearnLanguagesView'in başkent eşleniği. Satırlar dokunulabilir;
/// kart ülke adı/bayrağı/başkenti/kıtasını gösterir.
struct LearnCapitalsView: View {
    var onBack: () -> Void
    @State private var query = ""
    @State private var selectedCountry: CountryCardInfo?

    private var allCountries: [Country] { Capitals.learnableCountries.sortedLocalized(by: \.name) }

    private var filtered: [Country] {
        guard !query.isEmpty else { return allCountries }
        return allCountries.filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || Capitals.name(for: $0.code).localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GeoScreenHeader(title: "Başkentleri Öğren", subtitle: "\(allCountries.count) ülkenin başkentini keşfet", onBack: onBack)
            .padding(.bottom, GeoSpacing.lg)

            GeoSearchBar(placeholder: "Ülke veya başkent ara...", text: $query)
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
                                continentName: Capitals.name(for: country.code),
                                prioritizesTrailing: true
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
