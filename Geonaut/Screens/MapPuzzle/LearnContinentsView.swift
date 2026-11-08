import SwiftUI

/// Harita Bilmece'nin "Öğren" hedefi — Figma "Harita Bilmece - Giriş (Kıtalar/Ülkeler)"
/// (node 326:4060/341:44855) referans alındı: geri + başlık + sağda bilgi dairesi,
/// Kıtalar/Ülkeler sekmeleri, Kıtalar sekmesinde TEK seferde bir kart gösteren
/// sayfalı (paged) galeri + alt nokta göstergesi (bkz. continentsCards — önceki
/// sürüm yanlışlıkla yan yana kaydırmalı bir satırdı), Ülkeler sekmesinde arama + liste.
/// "X Sınavına Başla" butonları yok — sınav artık Ana Sayfa'daki Kıtalar/Ülkeler
/// düğümlerinden doğrudan başlıyor (bkz. ContinentPathNode.mapPuzzleTracksPath).
struct LearnContinentsView: View {
    var onBack: () -> Void

    private enum Tab { case continents, countries }
    @State private var tab: Tab = .continents
    @State private var query = ""
    /// Kullanıcı kararı: Kıtalar sekmesine ilk girişte kart hafifçe sağa kayıp geri
    /// dönsün — kaydırılabilir olduğunu hissettiren TEK SEFERLİK bir ipucu. UserDefaults'ta
    /// kalıcı olduğu için uygulamanın tüm ömründe yalnızca bir kez oynuyor (sekmeler
    /// arası geçişte ya da ekrana her dönüşte DEĞİL).
    @AppStorage("geonaut.hasSeenContinentsSwipeHint") private var hasSeenSwipeHint = false
    @State private var swipeHintOffset: CGFloat = 0
    /// Kullanıcı kararı: Bayrakları/Ana Dilleri/Dünya Yemeklerini Öğren'deki gibi
    /// satırlar dokunulabilir — dokununca ülke bilgi kartı açılır (bkz. GeoCountryInfoCard).
    @State private var selectedCountry: CountryCardInfo?
    /// Kullanıcı kararı: kartın altında "2/7" gibi konum göstergesi — kaydırdıkça güncellenir.
    @State private var selectedContinentIndex = 0

    private var sortedCountries: [MapCountry] { MapCountries.all.sortedLocalized(by: \.name) }

    private var filteredCountries: [MapCountry] {
        guard !query.isEmpty else { return sortedCountries }
        return sortedCountries.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GeoScreenHeader(
                title: "Haritalar", subtitle: "7 kıtayı keşfet, ülkeleri haritada bul", onBack: onBack
            ) {
                Circle()
                    .fill(GeoColor.accentTertiary)
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: "safari.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(GeoColor.accentTertiaryStrong)
                    }
            }
            .padding(.bottom, GeoSpacing.lg)

            HStack(spacing: 0) {
                tabButton("Kıtalar", isSelected: tab == .continents) { tab = .continents }
                tabButton("Ülkeler", isSelected: tab == .countries) { tab = .countries }
            }
            .padding(4)
            .background(GeoColor.bgLocked, in: Capsule())
            .padding(.bottom, GeoSpacing.lg)

            switch tab {
            case .continents: continentsCards
            case .countries: countriesList
            }
        }
        .padding(.horizontal, GeoSpacing.xl)
        .padding(.top, GeoSpacing.md)
        .background { GeoColor.bgSurface.ignoresSafeArea() }
        .countryInfoSheet(selected: $selectedCountry)
    }

    private func tabButton(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(LocalizedStringKey(title))
                .font(.custom(GeoFontName.balooBold, size: 14))
                .foregroundStyle(isSelected ? GeoColor.textPrimary : GeoColor.textMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, GeoSpacing.sm)
                .background(isSelected ? GeoColor.bgSurface : .clear, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    /// Figma'da "Kıtalar Pager" — yan yana kaydırmalı bir satır DEĞİL, her seferinde
    /// tam ekran genişliğinde TEK bir kart gösteren sayfalı bir galeri, altında da
    /// "Pagination Dots" (bkz. node 334:11282). Önceki sürümdeki ScrollView(.horizontal)
    /// hatası buradaydı.
    private var continentsCards: some View {
        VStack(spacing: GeoSpacing.sm) {
            TabView(selection: $selectedContinentIndex) {
                ForEach(Array(GeoContinentInfoCard.all.enumerated()), id: \.element.key) { index, info in
                    GeoContinentInfoCard(info: info)
                        .frame(maxWidth: .infinity)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .tint(GeoColor.accentPrimary)
            // countriesList'teki ScrollView gibi kalan tüm dikey alanı doldursun diye —
            // sabit bir height burada Ülkeler sekmesiyle tutarsız, altta boş alan bırakıyordu.
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(x: swipeHintOffset)
            .onAppear { playSwipeHintIfNeeded() }

            // Kullanıcı kararı: "2/7" gibi bir konum göstergesi, kaydırdıkça güncellensin.
            Text("\(selectedContinentIndex + 1)/\(GeoContinentInfoCard.all.count)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(GeoColor.textMuted)
        }
    }

    private func playSwipeHintIfNeeded() {
        guard !hasSeenSwipeHint else { return }
        hasSeenSwipeHint = true
        withAnimation(.easeOut(duration: 0.3)) {
            swipeHintOffset = 24
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                swipeHintOffset = 0
            }
        }
    }

    private var countriesList: some View {
        VStack(spacing: GeoSpacing.md) {
            GeoSearchBar(placeholder: "Bayrak veya ülke adı ara...", text: $query)

            if filteredCountries.isEmpty {
                GeoStatusView(style: .empty, title: "Sonuç bulunamadı", subtitle: "Farklı bir ülke veya kelime denemeyi dene.")
            } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredCountries, id: \.code) { country in
                        Button {
                            selectedCountry = cardInfo(for: country)
                        } label: {
                            GeoFlagListRow(
                                countryCode: country.code, countryName: country.name, continentName: country.continent,
                                showsWhiteBackground: false
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            }
        }
    }

    private func cardInfo(for country: MapCountry) -> CountryCardInfo {
        let facts = CountryData.facts(for: country.code)
        return CountryCardInfo(
            code: country.code, name: country.name,
            language: facts?.mainLanguage ?? "Bilinmiyor",
            continent: facts?.continent ?? country.continent
        )
    }
}

#Preview {
    LearnContinentsView(onBack: {})
}
