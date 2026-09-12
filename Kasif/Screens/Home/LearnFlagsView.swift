import SwiftUI

/// Figma "Bayrakları Öğren" (node 278:2394). Bkz. Bayrak Tahmin Kural Kitabı böl. 02:
/// "Oyun dışı, baskısız bir keşif alanı — puan veya can etkilemez."
struct LearnFlagsView: View {
    var onBack: () -> Void
    @State private var query = ""

    private var allCountries: [Country] { Countries.all }

    private var filtered: [Country] {
        guard !query.isEmpty else { return allCountries }
        return allCountries.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(KasifColor.textPrimary)
                    .padding(KasifSpacing.sm)
            }

            VStack(alignment: .leading, spacing: KasifSpacing.xs) {
                Text("Bayrakları Öğren")
                    .font(.custom(KasifFontName.balooExtraBold, size: 24))
                    .foregroundStyle(KasifColor.textPrimary)
                // "Keşfet" gibi eylem çağrısı yerine bilgilendirici bir ifade
                // kullanılıyor — satırlar dokunulabilir değil, bu yüzden metin
                // bir detay sayfasına gideceği beklentisi yaratmamalı.
                Text("Bayraklar ve isimleri aşağıda listeleniyor")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(KasifColor.textSecondary)
            }
            .padding(.top, KasifSpacing.sm)
            .padding(.bottom, KasifSpacing.lg)

            KasifSearchBar(placeholder: "Bayrak veya ülke adı ara...", text: $query)
                .padding(.bottom, KasifSpacing.sm)

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filtered, id: \.code) { country in
                        KasifFlagListRow(countryCode: country.code, countryName: country.name)
                    }
                }
            }
        }
        .padding(.horizontal, KasifSpacing.xl)
        .padding(.top, KasifSpacing.md)
        // Figma'da bu ekranın zemini krem bgCanvas değil, neredeyse beyaz
        // bgSurface (#FDFCF8) — satır kartlarıyla (Color.white) aynı aileden,
        // krem zemin diğer ekranlardan farklı olarak burada kullanılmıyor.
        .background(KasifColor.bgSurface)
    }
}

#Preview {
    LearnFlagsView(onBack: {})
}
