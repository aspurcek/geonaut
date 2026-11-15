import SwiftUI

/// Öğren ekranlarının ortak iskeleti — Bayraklar / Başkentler / Diller / Lezzetler
/// (2026-11-14 yeniden tasarım, kullanıcı: "öğren kısımlarının UI'larını da geliştir"):
/// - Lavanta "Ülke" vitrini (her gün değişir; zarla başka bir ülke).
/// - Arama ve kıta filtreleri kaydırırken üstte sabit kalır.
/// - Liste (harf başlıklarıyla) ya da ızgara görünümü.
/// Kullanıcı kararı (2026-11-14): "öğrenildi" yeşil mührü ve ilerleme çubuğu YOK (veri kategoriye
/// özel değildi, anlamı belirsizdi); vitrin başlığı "Günün ülkesi" değil yalnızca "Ülke".
/// Oyun dışı, baskısız keşif alanı — puan veya can etkilemez (Kural Kitabı böl. 02).
struct LearnCatalogView: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let symbol: String
    let tint: Color
    /// Alfabetik sıralı ülkeler.
    let countries: [Country]
    var detailIcon: String? = nil
    var detail: (Country) -> String? = { _ in nil }
    var searchPlaceholder = "Ülke ara..."
    var matches: (Country, String) -> Bool = { country, query in country.name.localizedCaseInsensitiveContains(query) }
    var prefersGrid = false
    /// Vitrin üst yazısı (ör. "Ülke", "Başkent", "Lezzet").
    var spotlightCaption: LocalizedStringKey = "Ülke"
    /// true ise vitrinde büyük başlık ayrıntı (başkent/yemek adı) olur, altında ülke adı yazar
    /// (kullanıcı kararı 2026-11-14: Başkentler ve Lezzetler). false ise başlık ülke adıdır.
    var spotlightFeaturesDetail = false
    /// Varsa bayrak yerine gösterilecek görsel (ör. yemek fotoğrafı); bayrak köşede küçük kalır.
    var image: (Country) -> String? = { _ in nil }
    /// Vitrin yalnızca bu ülkelerden seçilsin (ör. fotoğrafı olan yemekler). nil = tüm liste.
    var spotlightCountries: [Country]? = nil
    var onSelect: (Country) -> Void
    var onBack: () -> Void

    @State private var query = ""
    @State private var continent: String?
    @State private var gridOverride: Bool?
    @State private var spotlightShift = 0

    private var isGrid: Bool { gridOverride ?? prefersGrid }

    // MARK: Veri

    private func continentOf(_ country: Country) -> String {
        CountryData.facts(for: country.code)?.continent ?? ""
    }

    private var continents: [String] {
        FlagGuessStructure.continents.filter { name in countries.contains { continentOf($0) == name } }
    }

    private var filtered: [Country] {
        countries.filter { country in
            (continent == nil || continentOf(country) == continent)
                && (query.isEmpty || matches(country, query))
        }
    }

    /// Liste görünümünde baş harfe göre gruplar (sıra korunur).
    private var groups: [(letter: String, items: [Country])] {
        var result: [(letter: String, items: [Country])] = []
        for country in filtered {
            let letter = String(country.name.prefix(1)).uppercased(with: Locale.current)
            if result.last?.letter == letter {
                result[result.count - 1].items.append(country)
            } else {
                result.append((letter, [country]))
            }
        }
        return result
    }

    private var spotlight: Country? {
        let pool = (spotlightCountries?.isEmpty == false ? spotlightCountries : nil) ?? countries
        guard !pool.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .era, for: .now) ?? 0
        let index = (day * 31 + spotlightShift * 17) % pool.count
        return pool[abs(index)]
    }

    // MARK: Görünüm

    var body: some View {
        VStack(spacing: 0) {
            GeoScreenHeader(title: title, subtitle: subtitle, onBack: onBack) {
                GeoGlyphCircle(symbol: symbol, background: tint, size: 44)
            }
            .padding(.horizontal, GeoSpacing.xl)
            .padding(.bottom, GeoSpacing.md)

            ScrollView {
                LazyVStack(spacing: GeoSpacing.md, pinnedViews: [.sectionHeaders]) {
                    if query.isEmpty, let country = spotlight {
                        spotlightCard(country)
                            .padding(.horizontal, GeoSpacing.xl)
                    }
                    Section {
                        results
                    } header: {
                        controls
                    }
                }
                .padding(.bottom, GeoSpacing.xxl)
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .padding(.top, GeoSpacing.md)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
        .sensoryFeedback(.selection, trigger: continent)
    }

    // MARK: Günün ülkesi

    private func spotlightCard(_ country: Country) -> some View {
        VStack(alignment: .leading, spacing: GeoSpacing.md) {
            Button { onSelect(country) } label: {
                HStack(spacing: GeoSpacing.lg) {
                    GeoLearnThumb(code: country.code, imageName: image(country), width: 96, height: 76, flagSize: 54, corner: 16)
                        .shadow(color: GeoColor.accentTertiaryStrong.opacity(0.25), radius: 6, y: 3)
                        .id(country.code)
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(spotlightCaption)
                            .font(GeoTypography.caption)
                            .textCase(.uppercase)
                            .tracking(0.8)
                            .foregroundStyle(GeoColor.textSecondary)
                        let featured = spotlightFeaturesDetail ? detail(country).map(D) : nil
                        Text(featured ?? country.name)
                            .font(GeoTypography.headingL)
                            .foregroundStyle(GeoColor.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                        if featured != nil {
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.system(size: 11, weight: .bold))
                                Text(country.name).lineLimit(1)
                            }
                            .font(GeoTypography.bodySemibold)
                            .foregroundStyle(GeoColor.textSecondary)
                        } else if let value = detail(country) {
                            detailLabel(value)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

        }
        .padding(GeoSpacing.lg)
        .background {
            DailyTheme.background
                .overlay {
                    DailyGlobeLines()
                        .frame(width: 220, height: 220)
                        .offset(x: 130, y: 20)
                }
                .overlay { DailyNightSky(count: 14, seed: 5) }
        }
        .clipShape(RoundedRectangle(cornerRadius: GeoRadius.xl))
        .overlay(alignment: .topTrailing) {
            Button {
                withAnimation(.spring(duration: 0.35, bounce: 0.3)) { spotlightShift += 1 }
            } label: {
                Image(systemName: "dice.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(GeoColor.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.85), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Başka bir ülke göster"))
            .padding(GeoSpacing.md)
        }
        .shadow(color: DailyTheme.shadow, radius: 10, x: 0, y: 5)
    }

    private func detailLabel(_ value: String) -> some View {
        HStack(spacing: 4) {
            if let detailIcon {
                Image(systemName: detailIcon)
                    .font(.system(size: 11, weight: .bold))
            }
            Text(D(value))
                .lineLimit(1)
        }
        .font(GeoTypography.bodySemibold)
        .foregroundStyle(GeoColor.textSecondary)
    }

    // MARK: Arama + filtreler (sabit başlık)

    private var controls: some View {
        VStack(spacing: GeoSpacing.sm) {
            GeoSearchBar(placeholder: searchPlaceholder, text: $query)
            HStack(spacing: GeoSpacing.sm) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: GeoSpacing.sm) {
                        chip(title: "Tümü", count: countries.count, selected: continent == nil) { continent = nil }
                        ForEach(continents, id: \.self) { name in
                            chip(title: D(name), count: countries.filter { continentOf($0) == name }.count, selected: continent == name) {
                                continent = continent == name ? nil : name
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
                // Sağ kenarda yumuşak geçiş: filtreler görünüm düğmesinin altına girmesin.
                .mask {
                    HStack(spacing: 0) {
                        Color.black
                        LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing).frame(width: 18)
                    }
                }
                Button {
                    withAnimation(.spring(duration: 0.3)) { gridOverride = !isGrid }
                } label: {
                    Image(systemName: isGrid ? "list.bullet" : "square.grid.2x2.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(GeoColor.textPrimary)
                        .frame(width: 38, height: 38)
                        .background(GeoColor.bgSurface, in: Circle())
                        .overlay { Circle().strokeBorder(GeoColor.borderSubtle, lineWidth: 1.5) }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isGrid ? Text("Liste görünümü") : Text("Izgara görünümü"))
            }
        }
        .padding(.horizontal, GeoSpacing.xl)
        .padding(.vertical, GeoSpacing.sm)
        .background(GeoColor.bgCanvas)
    }

    private func chip(title: String, count: Int, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.spring(duration: 0.3)) { action() }
        } label: {
            HStack(spacing: 5) {
                Text(LocalizedStringKey(title))
                Text(verbatim: "\(count)")
                    .font(GeoTypography.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(selected ? Color.white.opacity(0.25) : GeoColor.bgLocked, in: Capsule())
            }
            .font(GeoTypography.bodyBold)
            .foregroundStyle(selected ? Color.white : GeoColor.textPrimary)
            .padding(.horizontal, GeoSpacing.md)
            .padding(.vertical, 8)
            .background(selected ? GeoColor.accentPrimaryStrong : GeoColor.bgSurface, in: Capsule())
            .overlay { Capsule().strokeBorder(selected ? .clear : GeoColor.borderSubtle, lineWidth: 1.5) }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    // MARK: Sonuçlar

    @ViewBuilder
    private var results: some View {
        if filtered.isEmpty {
            GeoStatusView(style: .empty, title: "Sonuç bulunamadı", subtitle: "Farklı bir ülke veya kelime denemeyi dene.")
                .padding(.top, GeoSpacing.xl)
        } else if isGrid {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: GeoSpacing.sm), count: 3), spacing: GeoSpacing.sm) {
                ForEach(filtered, id: \.code) { country in
                    Button { onSelect(country) } label: {
                        GeoLearnTile(code: country.code, name: country.name, imageName: image(country))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, GeoSpacing.xl)
        } else {
            ForEach(groups, id: \.letter) { group in
                VStack(alignment: .leading, spacing: GeoSpacing.sm) {
                    Text(verbatim: group.letter)
                        .font(GeoTypography.headingM)
                        .foregroundStyle(GeoColor.textMuted)
                        .padding(.leading, GeoSpacing.xs)
                    ForEach(group.items, id: \.code) { country in
                        Button { onSelect(country) } label: {
                            GeoLearnRow(
                                code: country.code, name: country.name,
                                detail: detail(country).map(D), detailIcon: detailIcon,
                                imageName: image(country)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, GeoSpacing.xl)
            }
        }
    }
}

/// Öğren listelerindeki kart satırı: bayrak kutusu, ülke adı + ikonlu ayrıntı.
struct GeoLearnRow: View {
    let code: String
    let name: String
    var detail: String? = nil
    var detailIcon: String? = nil
    var imageName: String? = nil

    var body: some View {
        HStack(spacing: GeoSpacing.md) {
            GeoLearnThumb(code: code, imageName: imageName, width: 56, height: 44, flagSize: 30, corner: 10)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(GeoTypography.bodyBoldL)
                    .foregroundStyle(GeoColor.textPrimary)
                    .lineLimit(1)
                if let detail {
                    HStack(spacing: 4) {
                        if let detailIcon {
                            Image(systemName: detailIcon).font(.system(size: 10, weight: .bold))
                        }
                        Text(detail).lineLimit(1)
                    }
                    .font(GeoTypography.bodySemibold)
                    .foregroundStyle(GeoColor.textSecondary)
                }
            }
            Spacer(minLength: GeoSpacing.sm)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(GeoColor.iconInactive)
        }
        .padding(.horizontal, GeoSpacing.md)
        .padding(.vertical, 10)
        .background(GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: GeoRadius.md))
        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
        .contentShape(Rectangle())
    }
}

/// Öğren ızgarasındaki kart: büyük bayrak + ad.
struct GeoLearnTile: View {
    let code: String
    let name: String
    var imageName: String? = nil

    var body: some View {
        VStack(spacing: 6) {
            GeoLearnThumb(code: code, imageName: imageName, width: 72, height: 54, flagSize: 44, corner: 10, plain: imageName == nil)
            Text(name)
                .font(GeoTypography.bodyBold)
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(height: 36, alignment: .top)
        }
        .padding(.top, GeoSpacing.md)
        .padding(.horizontal, GeoSpacing.xs)
        .frame(maxWidth: .infinity)
        .background(GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: GeoRadius.md))
        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
        .contentShape(Rectangle())
    }
}

/// Öğren küçük görseli: görsel varsa (ör. yemek fotoğrafı) kırpılmış fotoğraf + köşede küçük bayrak;
/// yoksa bayrak kutusu.
struct GeoLearnThumb: View {
    let code: String
    var imageName: String? = nil
    var width: CGFloat
    var height: CGFloat
    var flagSize: CGFloat
    var corner: CGFloat
    /// Izgarada fotoğraf yoksa bayrak çerçevesiz dursun.
    var plain = false

    var body: some View {
        if let imageName {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: corner))
                .overlay(alignment: .bottomTrailing) {
                    Text(GeoFlagAnswerOption.flagEmoji(for: code))
                        .font(.system(size: max(12, flagSize * 0.36)))
                        .padding(3)
                        .background(.white, in: Circle())
                        .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                        .offset(x: 5, y: 5)
                }
                .accessibilityHidden(true)
        } else if plain {
            Text(GeoFlagAnswerOption.flagEmoji(for: code))
                .font(.system(size: flagSize))
                .frame(height: height)
                .accessibilityHidden(true)
        } else {
            Text(GeoFlagAnswerOption.flagEmoji(for: code))
                .font(.system(size: flagSize))
                .frame(width: width, height: height)
                .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: corner))
                .accessibilityHidden(true)
        }
    }
}
