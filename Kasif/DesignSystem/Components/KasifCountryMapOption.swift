import SwiftUI

/// Figma Design System / Bileşenler / Country Map Option (node 339:15031). Harita
/// Bilmece "Ülkeler" bölümünde "Bayrak → ülke haritası şıklı seç" soru tipinde kullanılır.
///
/// Figma'nın "Design System > Country Map Crop" seti (node 339:14768) tam olarak
/// oyunun kullandığı 17 ülkeyi kapsıyor (MapCountries.all ile birebir) — hepsi export
/// edilip Assets.xcassets'e "CountryMap-<Kod>" adıyla eklendi. Asset yoksa (ör. ileride
/// MapCountries'e yeni bir ülke eklenirse) paylaşılan "ContinentMap-neutral" dünya
/// haritası mapCenter etrafında yakınlaştırılarak (bkz. CountryQuestionView.zoomedMapCard,
/// aynı teknik) geçici bir görünüm üretir; ikisi de yoksa nötr ikon placeholder'a düşülür.
struct KasifCountryMapOption: View {
    let countryCode: String
    let countryName: String
    var mapCenter: CGPoint? = nil
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
                    } else if let mapCenter {
                        GeometryReader { geo in
                            ZStack {
                                Image("ContinentMap-neutral")
                                    .resizable()
                                    .frame(width: geo.size.width, height: geo.size.height)
                                    .scaleEffect(6, anchor: UnitPoint(x: mapCenter.x, y: mapCenter.y))
                                Circle()
                                    .fill(KasifColor.accentInfoStrong.opacity(0.6))
                                    .frame(width: 14, height: 14)
                                    .position(x: mapCenter.x * geo.size.width, y: mapCenter.y * geo.size.height)
                            }
                        }
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
        KasifCountryMapOption(countryCode: "DE", countryName: "Almanya", mapCenter: CGPoint(x: 0.5024, y: 0.3379)) {}
        KasifCountryMapOption(countryCode: "TR", countryName: "Türkiye", mapCenter: CGPoint(x: 0.5708, y: 0.394)) {}
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
