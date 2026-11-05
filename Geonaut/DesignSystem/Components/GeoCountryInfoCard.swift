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
                    chip(icon: "🏛️", value: capital, label: "Başkenti")
                } else {
                    chip(icon: "🗣️", value: info.language, label: "Dili")
                }
                chip(icon: "🌍", value: info.continent, label: "Kıtası")
            }
            // Kutular aynı yükseklikte olsun (kullanıcı kararı) — en uzun kutuya eşitlenir.
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, GeoSpacing.xl)
        .padding(.top, GeoSpacing.xl)
        .frame(maxWidth: .infinity)
    }

    private func chip(icon: String, value: String, label: String) -> some View {
        VStack(spacing: GeoSpacing.xs) {
            Text(icon).font(.system(size: 22))
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

extension View {
    /// Her iki "Öğren" ekranının da paylaştığı sheet sunumu.
    func countryInfoSheet(selected: Binding<CountryCardInfo?>) -> some View {
        sheet(item: selected) { info in
            GeoCountryInfoCard(info: info)
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.white)
        }
    }
}

#Preview {
    GeoCountryInfoCard(info: CountryCardInfo(code: "DE", name: "Almanya", language: "Almanca", continent: "Avrupa"))
        .background(Color.white)
}
