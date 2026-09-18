import SwiftUI

/// Figma Design System / Bileşenler / Country Map Option (node 339:15031). Harita
/// Bilmece "Ülkeler" bölümünde "Bayrak → ülke haritası şıklı seç" soru tipinde kullanılır.
///
/// Figma'nın "Design System > Country Map Crop" seti (node 339:14768) yalnızca 17
/// ülkeyi kapsıyor — hepsi export edilip Assets.xcassets'e "CountryMap-<Kod>" adıyla
/// eklendi. Asset yoksa CountryCoordinates'teki gerçek enlem/boylamla canlı bir MapKit
/// haritası gösterilir (bkz. KasifLiveCountryMap) — MapCountries.extended'daki 249
/// ülkenin tamamı için çalışır; ikisi de yoksa nötr ikon placeholder'a düşülür.
struct KasifCountryMapOption: View {
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
                        KasifLiveCountryMap(latitude: coordinate.lat, longitude: coordinate.lon)
                    } else {
                        Image(systemName: "map")
                            .font(.system(size: 28))
                            .foregroundStyle(KasifColor.iconInactive)
                    }
                }
                .frame(width: 169, height: 95)
                .clipped()

                Text(countryName)
                    .font(.custom(KasifFontName.balooBold, size: 15))
                    .foregroundStyle(KasifColor.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 33)
                    .background(KasifColor.bgSurface)
            }
            .frame(width: 169, height: 128)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14).strokeBorder(KasifColor.borderSubtle, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}

#Preview {
    HStack(spacing: KasifSpacing.md) {
        KasifCountryMapOption(countryCode: "DE", countryName: "Almanya") {}
        KasifCountryMapOption(countryCode: "GR", countryName: "Yunanistan") {}
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
