import SwiftUI

/// Figma "Harita Bilmece - Giriş (Kıtalar/Ülkeler)" (node 326:4060). Bkz. Harita
/// Bilmece Kural Kitabı böl. 02: iki sekme — Kıtalar (dokunmatik olmayan tanıtım
/// galerisi) ve Ülkeler (aranabilir, kıta bilgili liste, "Bayrakları Öğren"in eşi).
struct MapPuzzleEntryView: View {
    private enum Tab { case continents, countries }
    @State private var selectedTab: Tab = .continents
    @State private var query = ""

    var onBack: () -> Void
    var onSelectContinentsStage: () -> Void
    var onSelectCountriesStage: () -> Void

    private var filteredCountries: [MapCountry] {
        guard !query.isEmpty else { return MapCountries.all }
        return MapCountries.all.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(KasifColor.textPrimary)
                    .padding(KasifSpacing.sm)
            }

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: KasifSpacing.xs) {
                    Text("Harita Bilmece")
                        .font(.custom(KasifFontName.balooExtraBold, size: 24))
                        .foregroundStyle(KasifColor.textPrimary)
                    Text("7 kıtayı keşfet, ülkeleri haritada bul")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(KasifColor.textSecondary)
                }
                Spacer()
                Circle()
                    .fill(KasifColor.accentInfo)
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: "info")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }
            }
            .padding(.top, KasifSpacing.sm)
            .padding(.bottom, KasifSpacing.lg)

            HStack(spacing: 0) {
                tabButton("Kıtalar", isSelected: selectedTab == .continents) { selectedTab = .continents }
                tabButton("Ülkeler", isSelected: selectedTab == .countries) { selectedTab = .countries }
            }
            .padding(4)
            .background(KasifColor.bgLocked, in: Capsule())
            .padding(.bottom, KasifSpacing.lg)

            switch selectedTab {
            case .continents:
                continentsGallery
            case .countries:
                countriesList
            }
        }
        .padding(.horizontal, KasifSpacing.xl)
        .padding(.top, KasifSpacing.md)
        .background(KasifColor.bgCanvas)
    }

    private func tabButton(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.custom(KasifFontName.balooBold, size: 14))
                .foregroundStyle(isSelected ? KasifColor.textPrimary : KasifColor.textMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, KasifSpacing.sm)
                .background(isSelected ? KasifColor.bgSurface : .clear, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    /// Bkz. Harita Bilmece Kural Kitabı: "dokunmatik değil, yalnızca tanıtım amaçlı" —
    /// asıl sınav Etap Haritası'nda. Figma'nın statik ekranında galerinin altında görünür
    /// bir CTA yok; bu buton, kıta kartlarının kendisini dokunmatik yapıp sınavı yanlışlıkla
    /// "ezberleme" riskine girmeden (bkz. yukarıdaki gerekçe) Etap Haritası'na geçişi sağlıyor.
    private var continentsGallery: some View {
        VStack(spacing: KasifSpacing.md) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: KasifSpacing.lg) {
                    ForEach(KasifContinentInfoCard.all, id: \.key) { info in
                        KasifContinentInfoCard(info: info)
                    }
                }
            }

            Button("Kıtalar Sınavına Başla", action: onSelectContinentsStage)
                .buttonStyle(.kasifPrimary)
                .frame(maxWidth: .infinity)
        }
    }

    private var countriesList: some View {
        VStack(spacing: KasifSpacing.md) {
            KasifSearchBar(placeholder: "Ülke adı ara...", text: $query)

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredCountries, id: \.code) { country in
                        KasifFlagListRow(countryCode: country.code, countryName: country.name, continentName: country.continent)
                    }
                }
            }

            Button("Ülkeler Sınavına Başla", action: onSelectCountriesStage)
                .buttonStyle(.kasifPrimary)
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    MapPuzzleEntryView(onBack: {}, onSelectContinentsStage: {}, onSelectCountriesStage: {})
}
