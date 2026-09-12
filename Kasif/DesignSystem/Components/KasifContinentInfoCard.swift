import SwiftUI

/// Figma Design System / Bileşenler / Continent Info Card (node 341:44574). Harita
/// Bilmece "Giriş (Kıtalar)" sekmesindeki yatay kaydırmalı tanıtım kartları — dokunmatik
/// değil, sadece tanıma amaçlı (bkz. Harita Bilmece Kural Kitabı böl. 02).
struct KasifContinentInfoCard: View {
    struct Info {
        let key: String // Assets.xcassets'teki "ContinentMap-<key>" ismiyle eşleşir
        let name: String
        let fact: String
    }

    let info: Info

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image("ContinentMap-\(info.key)")
                .resizable()
                .scaledToFill()
                .frame(width: 350, height: 200)
                .clipped()

            VStack(alignment: .leading, spacing: 10) {
                Text("KITA")
                    .font(KasifTypography.caption)
                    .foregroundStyle(KasifColor.textOnAccent)
                    .padding(.horizontal, KasifSpacing.md)
                    .padding(.vertical, 5)
                    .background(KasifColor.accentPrimary, in: Capsule())

                Text(info.name)
                    .font(.custom(KasifFontName.balooExtraBold, size: 30))
                    .foregroundStyle(KasifColor.textPrimary)

                Text(info.fact)
                    .font(.system(size: 14.5))
                    .foregroundStyle(KasifColor.textMuted)
            }
            .padding(.horizontal, KasifSpacing.xxl)
            .padding(.top, 22)
            .padding(.bottom, KasifSpacing.xxl)
        }
        .frame(width: 350, height: 430, alignment: .top)
        .background(KasifColor.bgSurface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24).strokeBorder(KasifColor.borderSubtle, lineWidth: 1)
        }
    }

    /// Kaşif Uygulama Kural Kitabı + Figma'daki 7 kıta tanıtım metni.
    static let all: [Info] = [
        Info(key: "avrupa", name: "Avrupa", fact: "51 ülke • dünyanın en yoğun sınır komşuluğuna sahip kıtası"),
        Info(key: "asya", name: "Asya", fact: "54 ülke • yüzölçümü en büyük, nüfusu en kalabalık kıta"),
        Info(key: "afrika", name: "Afrika", fact: "58 ülke • ülke sayısı en fazla olan kıta"),
        Info(key: "kuzeyamerika", name: "Kuzey Amerika", fact: "41 ülke • Kanada'dan Panama'ya uzanır"),
        Info(key: "guneyamerika", name: "Güney Amerika", fact: "15 ülke • Amazon ormanlarının evi"),
        Info(key: "okyanusya", name: "Okyanusya", fact: "31 ülke • binlerce adadan oluşan takımada kıtası"),
        Info(key: "antarktika", name: "Antarktika", fact: "3 ülke • buzla kaplı, kalıcı nüfusu olmayan kıta")
    ]
}

#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: KasifSpacing.lg) {
            ForEach(KasifContinentInfoCard.all, id: \.key) { info in
                KasifContinentInfoCard(info: info)
            }
        }
        .padding(KasifSpacing.xxxl)
    }
    .background(KasifColor.bgCanvas)
}
