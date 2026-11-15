import SwiftUI

/// "Bayrakları/Ana Dilleri Öğren" satırlarına dokununca çıkan bilgi kartı — Figma
/// "Ülke Bilgi Kartı" (Ana Diller FLOW5 bölümü). Kullanıcı kararı: satırlar
/// dokunulabilir, kart ülke adı + bayrağı + dili + kıtasını gösterir.
///
/// Kullanıcı geri bildirimi: ortalanmış kart + karartma overlay'i mobilde native
/// hissettirmiyor — iOS'un kendi alttan açılan sheet'i (.sheet + presentationDetents)
/// kullanılıyor: sürükleyerek kapatma, güvenli alan yönetimi vb. bedavaya geliyor.
struct CountryCardInfo: Identifiable, Equatable {
    let code: String
    let name: String
    let language: String
    let continent: String
    /// Doluysa kartta "Dili" yerine "Başkenti" gösterilir (Başkentler kategorisinin Öğren ekranı).
    var capital: String? = nil
    var id: String { code }
}

struct GeoCountryInfoCard: View {
    let info: CountryCardInfo

    var body: some View {
        if let capital = info.capital {
            capitalLayout(capital)
        } else {
            classicLayout
        }
    }

    /// Başkentler (2026-11-14): Lezzetler'deki fotoğraf galerisinin karşılığı — üstte bayrak + ad,
    /// ortada başkenti iğneyle gösteren harita, altta Başkenti/Kıtası kutuları.
    private func capitalLayout(_ capital: String) -> some View {
        VStack(spacing: GeoSpacing.md) {
            HStack(spacing: GeoSpacing.sm) {
                Text(GeoFlagAnswerOption.flagEmoji(for: info.code))
                    .font(.system(size: 30))
                Text(info.name)
                    .font(GeoTypography.headingL)
                    .foregroundStyle(GeoColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 0)
            }

            GeoCapitalMap(countryCode: info.code, countryName: info.name, capital: capital)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: GeoRadius.xl))
                // Etiket üst köşede: alt köşedeki Apple Haritalar yasal yazısı kapanmasın.
                .overlay(alignment: .topLeading) {
                    HStack(spacing: 6) {
                        GeoGlyphCircle(symbol: "building.columns.fill", background: GeoColor.accentHighlight, size: 22)
                        Text("Başkent")
                            .foregroundStyle(GeoColor.textSecondary)
                        Text(verbatim: "·")
                            .foregroundStyle(GeoColor.textMuted)
                        Text(D(capital))
                            .foregroundStyle(GeoColor.textPrimary)
                            .lineLimit(1)
                    }
                    .font(GeoTypography.bodyBold)
                    .padding(.leading, 5)
                    .padding(.trailing, GeoSpacing.md)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.92), in: Capsule())
                    .shadow(color: .black.opacity(0.08), radius: 3, y: 1)
                    .padding(GeoSpacing.md)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(verbatim: "\(L("Başkent")): \(D(capital))"))

            HStack(spacing: GeoSpacing.md) {
                chip(icon: "building.columns.fill", tint: GeoColor.accentHighlight, value: capital, label: "Başkenti")
                chip(icon: "globe.europe.africa.fill", tint: GeoColor.accentInfo, value: info.continent, label: "Kıtası")
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, GeoSpacing.xl)
        .padding(.top, GeoSpacing.xl)
        .frame(maxWidth: .infinity)
    }

    private var classicLayout: some View {
        VStack(spacing: GeoSpacing.lg) {
            Text(GeoFlagAnswerOption.flagEmoji(for: info.code))
                .font(.system(size: 64))
                .frame(width: 96, height: 64)

            Text(info.name)
                .font(.custom(GeoFontName.balooExtraBold, size: 24))
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)

            HStack(spacing: GeoSpacing.md) {
                if let capital = info.capital {
                    chip(icon: "building.columns.fill", tint: GeoColor.accentHighlight, value: capital, label: "Başkenti")
                } else {
                    chip(icon: "character.bubble.fill", tint: GeoColor.accentTertiary, value: info.language, label: "Dili")
                }
                chip(icon: "globe.europe.africa.fill", tint: GeoColor.accentInfo, value: info.continent, label: "Kıtası")
            }
            // Kutular aynı yükseklikte olsun (kullanıcı kararı) — en uzun kutuya eşitlenir.
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, GeoSpacing.xl)
        .padding(.top, GeoSpacing.xl)
        .frame(maxWidth: .infinity)
    }

    private func chip(icon: String, tint: Color, value: String, label: String) -> some View {
        VStack(spacing: GeoSpacing.xs) {
            GeoGlyphCircle(symbol: icon, background: tint, size: 30)
            Text(D(value))
                .font(.custom(GeoFontName.balooExtraBold, size: 16))
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(LocalizedStringKey(label))
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(GeoColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, GeoSpacing.md)
        .background(GeoColor.bgCanvas, in: RoundedRectangle(cornerRadius: GeoRadius.lg))
    }
}

private struct CountrySheetHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = max(value, nextValue()) }
}

/// Alt sayfa içeriği: yüksekliği içeriğe göre ölçülür — üstte/altta boş alan kalmaz.
private struct CountryInfoSheetContent: View {
    let info: CountryCardInfo
    @State private var height: CGFloat = 0

    var body: some View {
        GeoCountryInfoCard(info: info)
            .padding(.bottom, GeoSpacing.sm)
            .fixedSize(horizontal: false, vertical: true)
            .background {
                GeometryReader { proxy in
                    Color.clear.preference(key: CountrySheetHeightKey.self, value: proxy.size.height)
                }
            }
            .onPreferenceChange(CountrySheetHeightKey.self) { if $0 > 0 { height = $0 } }
            .frame(maxHeight: .infinity, alignment: .top)
            .presentationDetents([.height(height > 0 ? height : (info.capital != nil ? 460 : 320))])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color.white)
    }
}

extension View {
    /// Öğren ekranlarının paylaştığı sheet sunumu (yüksekliği içeriğe göre).
    func countryInfoSheet(selected: Binding<CountryCardInfo?>) -> some View {
        sheet(item: selected) { info in
            CountryInfoSheetContent(info: info)
        }
    }
}

#Preview {
    GeoCountryInfoCard(info: CountryCardInfo(code: "DE", name: "Almanya", language: "Almanca", continent: "Avrupa"))
        .background(Color.white)
}
