import SwiftUI

/// Figma Design System / Bileşenler / Country Map Option (node 339:15031). Harita
/// Bilmece "Ülkeler" bölümünde "Bayrak → ülke haritası şıklı seç" soru tipinde kullanılır.
///
/// Her ülkenin kendi kırpılmış harita görselini (Design System > Country Map Crop,
/// 67 ülke) tek tek export etmek yerine — ki bu, gerçek fayda/efor oranı düşük bir iş
/// olurdu (bkz. KasifFlagAnswerOption'ın emoji-bayrak tercihiyle aynı gerekçe) —
/// paylaşılan "ContinentMap-neutral" dünya haritası, MapCountry.mapCenter etrafında
/// yakınlaştırılıp (bkz. CountryQuestionView.zoomedMapCard, aynı teknik) ülkeye özel
/// bir görünüm üretiyor. mapCenter verilmezse nötr bir ikon placeholder'a düşülür.
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
                    if let mapCenter {
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
