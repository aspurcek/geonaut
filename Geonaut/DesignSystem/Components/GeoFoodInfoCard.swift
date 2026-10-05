import SwiftUI

/// "Dünya Yemeklerini Öğren" satırlarına dokununca çıkan bilgi kartı — GeoCountryInfoCard
/// ile aynı görsel dil (bkz. o dosyadaki kullanıcı geri bildirimi notu: native .sheet),
/// ama Dili/Kıtası yerine üç yemek türü (Yemek/Tatlı/İçecek) gösterir — bkz. FoodFacts.
struct FoodCardInfo: Identifiable, Equatable {
    let code: String
    let name: String
    let dish: String
    let dessert: String
    let drink: String
    var id: String { code }
}

private extension FoodType {
    var fixedIcon: String {
        switch self {
        case .yemek: "🍽️"
        case .tatli: "🍬"
        case .icecek: "🥛"
        }
    }
}

struct GeoFoodInfoCard: View {
    let info: FoodCardInfo

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
                chip(type: .yemek, value: info.dish, label: "Yemek")
                chip(type: .tatli, value: info.dessert, label: "Tatlı")
                chip(type: .icecek, value: info.drink, label: "İçecek")
            }
            // Kullanıcı kararı: üç kutu da aynı yükseklikte olsun (bir yemek adı 2 satıra
            // taşınca diğerleri kısa kalıyordu) — en uzun kutuya eşitlenir.
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, GeoSpacing.xl)
        .padding(.top, GeoSpacing.xl)
        .frame(maxWidth: .infinity)
    }

    /// Kullanıcı kararı: Yemek/Tatlı/İçecek chip'lerinde fotoğraf yerine HER ülkede aynı
    /// sabit emoji (🍽️ / 🍬 / 🥛) — tutarlılık için. Fotoğraflar yalnızca soru ekranında.
    @ViewBuilder
    private func chip(type: FoodType, value: String, label: String) -> some View {
        VStack(spacing: GeoSpacing.xs) {
            Text(type.fixedIcon)
                .font(.system(size: 22))
            .frame(width: 30, height: 30)
            Text(D(value))
                .font(.custom(GeoFontName.balooExtraBold, size: 14))
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
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
    func foodInfoSheet(selected: Binding<FoodCardInfo?>) -> some View {
        sheet(item: selected) { info in
            GeoFoodInfoCard(info: info)
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.white)
        }
    }
}

#Preview {
    GeoFoodInfoCard(info: FoodCardInfo(code: "IT", name: "İtalya", dish: "Pizza", dessert: "Tiramisu", drink: "Espresso"))
        .background(Color.white)
}
