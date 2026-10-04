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
    var id: String { code }
}

struct KasifCountryInfoCard: View {
    let info: CountryCardInfo

    var body: some View {
        VStack(spacing: KasifSpacing.lg) {
            Text(KasifFlagAnswerOption.flagEmoji(for: info.code))
                .font(.system(size: 64))
                .frame(width: 96, height: 64)

            Text(info.name)
                .font(.custom(KasifFontName.balooExtraBold, size: 24))
                .foregroundStyle(KasifColor.textPrimary)
                .multilineTextAlignment(.center)

            HStack(spacing: KasifSpacing.md) {
                chip(icon: "🗣️", value: info.language, label: "Dili")
                chip(icon: "🌍", value: info.continent, label: "Kıtası")
            }
            // Kutular aynı yükseklikte olsun (kullanıcı kararı) — en uzun kutuya eşitlenir.
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, KasifSpacing.xl)
        .padding(.top, KasifSpacing.xl)
        .frame(maxWidth: .infinity)
    }

    private func chip(icon: String, value: String, label: String) -> some View {
        VStack(spacing: KasifSpacing.xs) {
            Text(icon).font(.system(size: 22))
            Text(D(value))
                .font(.custom(KasifFontName.balooExtraBold, size: 16))
                .foregroundStyle(KasifColor.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(LocalizedStringKey(label))
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(KasifColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, KasifSpacing.md)
        .background(KasifColor.bgCanvas, in: RoundedRectangle(cornerRadius: KasifRadius.lg))
    }
}

extension View {
    /// Her iki "Öğren" ekranının da paylaştığı sheet sunumu.
    func countryInfoSheet(selected: Binding<CountryCardInfo?>) -> some View {
        sheet(item: selected) { info in
            KasifCountryInfoCard(info: info)
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.white)
        }
    }
}

#Preview {
    KasifCountryInfoCard(info: CountryCardInfo(code: "DE", name: "Almanya", language: "Almanca", continent: "Avrupa"))
        .background(Color.white)
}
