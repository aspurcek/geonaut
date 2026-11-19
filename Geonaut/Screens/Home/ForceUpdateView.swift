import SwiftUI

/// Zorunlu güncelleme ekranı (kullanıcı kararı 2026-11-19, "güncellemeden oynatmasın").
/// Uygulamanın tamamını kapatır; kapatma düğmesi yok, yalnızca App Store'u açan "Güncelle" var.
/// Bkz. AppUpdateChecker.mustUpdate (yeni sürüm yayınlanalı 24 saat geçince devreye girer).
struct ForceUpdateView: View {
    let version: String
    var onUpdate: () -> Void

    var body: some View {
        ZStack {
            GeoColor.bgCanvas.ignoresSafeArea()
            GeoStarfield().ignoresSafeArea()
            VStack(spacing: GeoSpacing.lg) {
                Spacer()
                GeoBouncingMascot()
                    .frame(height: 180)
                Text("Güncellemen gerekiyor")
                    .font(.custom(GeoFontName.balooExtraBold, size: 28))
                    .foregroundStyle(GeoColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                Text("Geonaut \(version) yayında. Oynamaya devam etmek için uygulamayı App Store'dan güncelle; ilerlemen olduğu gibi kalır.")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(GeoColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, GeoSpacing.lg)
                Spacer()
                Button(action: onUpdate) {
                    Label("Güncelle", systemImage: "arrow.down.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.kasifPrimary)
            }
            .padding(.horizontal, GeoSpacing.xxl)
            .padding(.bottom, GeoSpacing.xxl)
        }
    }
}

#Preview {
    ForceUpdateView(version: "1.0.5", onUpdate: {})
}
