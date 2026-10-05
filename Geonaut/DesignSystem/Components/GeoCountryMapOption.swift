import SwiftUI

/// Figma Design System / Bileşenler / Country Map Option (node 339:15031). Harita
/// Bilmece "Ülkeler" bölümünde "Bayrak → ülke haritası şıklı seç" soru tipinde kullanılır.
///
/// Figma'nın "Design System > Country Map Crop" seti (node 339:14768) yalnızca 17
/// ülkeyi kapsıyor — hepsi export edilip Assets.xcassets'e "CountryMap-<Kod>" adıyla
/// eklendi. Asset yoksa CountryCoordinates'teki gerçek enlem/boylamla canlı bir MapKit
/// haritası gösterilir (bkz. GeoLiveCountryMap) — MapCountries.extended'daki 249
/// ülkenin tamamı için çalışır; ikisi de yoksa nötr ikon placeholder'a düşülür.
struct GeoCountryMapOption: View {
    let countryCode: String
    let countryName: String
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            VStack(spacing: 0) {
                ZStack {
                    Color(hex: 0xF2F5FA)
                    if UIImage(named: "CountryMap-\(countryCode)") != nil {
                        Image("CountryMap-\(countryCode)")
                            .resizable()
                            .scaledToFill()
                    } else if let coordinate = CountryCoordinates.coordinate(for: countryCode) {
                        GeoLiveCountryMap(latitude: coordinate.lat, longitude: coordinate.lon)
                    } else {
                        Image(systemName: "map")
                            .font(.system(size: 28))
                            .foregroundStyle(GeoColor.iconInactive)
                    }
                }
                .frame(width: 169, height: 95)
                .clipped()

                Text(countryName)
                    .font(.custom(GeoFontName.balooBold, size: 15))
                    .foregroundStyle(GeoColor.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 33)
                    .background(GeoColor.bgSurface)
            }
            .frame(width: 169, height: 128)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14).strokeBorder(GeoColor.borderSubtle, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
        .accessibilityLabel(countryName)
    }
}

#Preview {
    HStack(spacing: GeoSpacing.md) {
        GeoCountryMapOption(countryCode: "DE", countryName: "Almanya") {}
        GeoCountryMapOption(countryCode: "GR", countryName: "Yunanistan") {}
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
