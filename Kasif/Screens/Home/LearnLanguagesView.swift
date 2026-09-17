import SwiftUI

/// Figma "Ana Dilleri Öğren" (Ana Diller FLOW5 bölümü) — LearnFlagsView'in dil
/// eşleniği. Satırlar dokunulabilir; kart ülke adı/bayrağı/dili/kıtasını gösterir.
struct LearnLanguagesView: View {
    var onBack: () -> Void
    @State private var query = ""
    @State private var selectedCountry: CountryCardInfo?

    private var allCountries: [Country] { Languages.learnableCountries }

    private var filtered: [Country] {
        guard !query.isEmpty else { return allCountries }
        return allCountries.filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || Languages.language(for: $0.code).localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(KasifColor.textPrimary)
                    .padding(KasifSpacing.sm)
            }

            VStack(alignment: .leading, spacing: KasifSpacing.xs) {
                Text("Ana Dilleri Öğren")
                    .font(.custom(KasifFontName.balooExtraBold, size: 24))
                    .foregroundStyle(KasifColor.textPrimary)
                Text("\(allCountries.count)+ ülkenin ana dilini keşfet")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(KasifColor.textSecondary)
            }
            .padding(.top, KasifSpacing.sm)
            .padding(.bottom, KasifSpacing.lg)

            KasifSearchBar(placeholder: "Ülke veya dil ara...", text: $query)
                .padding(.bottom, KasifSpacing.sm)

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filtered, id: \.code) { country in
                        Button {
                            selectedCountry = cardInfo(for: country)
                        } label: {
                            KasifFlagListRow(
                                countryCode: country.code, countryName: country.name,
                                continentName: Languages.language(for: country.code)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, KasifSpacing.xl)
        .padding(.top, KasifSpacing.md)
        .background(KasifColor.bgSurface)
        .countryInfoOverlay(selected: $selectedCountry)
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
