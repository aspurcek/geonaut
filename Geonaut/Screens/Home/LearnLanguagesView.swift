import SwiftUI

/// Figma "Ana Dilleri Öğren" (Ana Diller FLOW5 bölümü) — LearnFlagsView'in dil
/// eşleniği. Satırlar dokunulabilir; kart ülke adı/bayrağı/dili/kıtasını gösterir.
struct LearnLanguagesView: View {
    var onBack: () -> Void
    @State private var query = ""
    @State private var selectedCountry: CountryCardInfo?

    private var allCountries: [Country] { Languages.learnableCountries.sortedLocalized(by: \.name) }

    private var filtered: [Country] {
        guard !query.isEmpty else { return allCountries }
        return allCountries.filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || Languages.language(for: $0.code).localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GeoScreenHeader(title: "Dilleri Öğren", subtitle: "\(allCountries.count)+ ülkenin ana dilini keşfet", onBack: onBack)
            .padding(.bottom, GeoSpacing.lg)

            GeoSearchBar(placeholder: "Ülke veya dil ara...", text: $query)
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
                                continentName: Languages.language(for: country.code)
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
            continent: facts?.continent ?? "Bilinmiyor"
        )
    }
}

#Preview {
    LearnLanguagesView(onBack: {})
}
