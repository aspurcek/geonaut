import SwiftUI

/// App Store'da yeni sürüm varsa Ana Sayfa'da bir kez çıkan "Güncelle" sayfası (bkz. AppUpdateChecker).
/// Zorunlu değil; "Sonra" denirse bu sürüm için bir daha sorulmaz.
struct UpdatePromptSheet: View {
    let version: String
    var onUpdate: () -> Void
    var onLater: () -> Void

    var body: some View {
        VStack(spacing: GeoSpacing.lg) {
            GeoGlyphCircle(symbol: "arrow.down.circle.fill", background: GeoColor.accentInfo, size: 84)
                .kasifWinGlow(color: GeoColor.accentHighlight, size: 170)
            Text("Yeni sürüm hazır")
                .font(.custom(GeoFontName.balooBold, size: 22))
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            Text("Geonaut \(version) App Store'da. Yeni özellikler ve düzeltmeler için uygulamayı güncelle.")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(GeoColor.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            VStack(spacing: GeoSpacing.md) {
                Button(action: onUpdate) {
                    Text("Güncelle").frame(maxWidth: .infinity)
                }
                .buttonStyle(.kasifPrimary)
                Button("Sonra", action: onLater)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(GeoColor.textMuted)
            }
            .padding(.top, GeoSpacing.sm)
        }
        .padding(.horizontal, GeoSpacing.xxl)
        .padding(.top, GeoSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
        .presentationDetents([.height(350)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    Color.clear.sheet(isPresented: .constant(true)) {
        UpdatePromptSheet(version: "1.0.5", onUpdate: {}, onLater: {})
    }
}
