import SwiftUI

/// "Görsel Kaynakları" — Ayarlar'dan açılır. Dünya Yemekleri'ndeki 90 fotoğraf, telif
/// riski taşıyan (kaynağı belirsiz) eski görsellerin yerine Openverse üzerinden
/// ticari kullanıma ve değişikliğe açık lisanslarla (CC0/PDM/CC BY/CC BY-SA)
/// bulundu (bkz. PhotoCredits.swift). CC BY/BY-SA lisansı görünür bir atıf istiyor —
/// bu ekran o atıfı sağlıyor. Fotoğrafı gösteren GeoFoodInfoCard/foodImageCard
/// bu listeye link vermiyor; kullanıcı isterse Ayarlar'dan kendi bulur (lisans
/// atıfın "kolay bulunabilir" olmasını ister, gizlenmesini değil).
struct PhotoCreditsView: View {
    var onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .accessibilityLabel("Geri")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(GeoColor.textPrimary)
                    .padding(GeoSpacing.sm)
            }

            VStack(alignment: .leading, spacing: GeoSpacing.xs) {
                Text("Görsel Kaynakları")
                    .font(.custom(GeoFontName.balooExtraBold, size: 24))
                    .foregroundStyle(GeoColor.textPrimary)
                Text("Lezzetler'deki fotoğraflar Openverse üzerinden, aşağıdaki lisanslarla kullanılmıştır.")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(GeoColor.textSecondary)
            }
            .padding(.top, GeoSpacing.sm)
            .padding(.bottom, GeoSpacing.lg)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: GeoSpacing.lg) {
                    ForEach(PhotoCredits.all) { credit in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(credit.dishName)
                                .font(.custom(GeoFontName.balooBold, size: 15))
                                .foregroundStyle(GeoColor.textPrimary)
                            Text(credit.attributionLine)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(GeoColor.textMuted)
                                .fixedSize(horizontal: false, vertical: true)
                            if let url = credit.sourceURL {
                                Link("Kaynağı gör", destination: url)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(GeoColor.accentPrimary)
                            }
                        }
                        Divider()
                    }
                }
                .padding(.bottom, GeoSpacing.xxxl)
            }
        }
        .padding(.horizontal, GeoSpacing.xl)
        .padding(.top, GeoSpacing.md)
        .background { GeoColor.bgSurface.ignoresSafeArea() }
    }
}

#Preview {
    PhotoCreditsView(onBack: {})
}
