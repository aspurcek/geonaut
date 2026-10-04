import SwiftUI

/// Figma Design System / Bileşenler / Flag List Row (node 334:11041). "Bayrakları Öğren"
/// ve Harita Bilmece "Ülkeler" listesinde kullanılır. Tip=Basit (sadece isim) / Kıtalı
/// (isim + kıta adı sağda).
struct KasifFlagListRow: View {
    /// ISO 3166-1 alpha-2 ülke kodu — bkz. KasifFlagAnswerOption'daki emoji-bayrak notu.
    let countryCode: String
    let countryName: String
    var continentName: String? = nil
    /// Figma'da "Bayrakları Öğren" / "Ana Dilleri Öğren" satırları beyaz zeminli
    /// (node 334:11041 varsayılan dolgusu), ama Harita Bilmece "Ülkeler" listesindeki
    /// (node 341:44855) örneklerde bu dolgu kaldırılmış — satırlar şeffaf, krem
    /// bgCanvas zemin arkadan görünüyor. Varsayılan true iki mevcut kullanımı korur.
    var showsWhiteBackground: Bool = true

    var body: some View {
        HStack(spacing: 14) {
            Text(KasifFlagAnswerOption.flagEmoji(for: countryCode))
                .font(.system(size: 28))
                .frame(width: 40, height: 28)

            Text(countryName)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.black)
                .lineLimit(1)
                .layoutPriority(1)

            if let continentName {
                Spacer(minLength: KasifSpacing.sm)
                Text(D(continentName))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(KasifColor.textMuted)
                    .lineLimit(1)
            } else {
                Spacer(minLength: 0)
            }

            // Satırların dokunulabilir olduğunu belirten ok — kullanıcı kararı:
            // dokununca ülke bilgi kartı açılır (bkz. KasifCountryInfoCard).
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(KasifColor.textMuted)
        }
        .padding(.horizontal, KasifSpacing.xs)
        .padding(.vertical, 10)
        .frame(height: 56)
        .background(showsWhiteBackground ? Color.white : Color.clear)
        .contentShape(Rectangle())
    }
}

#Preview {
    VStack(spacing: 0) {
        KasifFlagListRow(countryCode: "DE", countryName: "Almanya")
        KasifFlagListRow(countryCode: "RU", countryName: "Rusya", continentName: "Avrupa / Asya")
    }
    .background(KasifColor.bgCanvas)
}
