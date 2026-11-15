import SwiftUI

/// İlk seviye bittikten sonra, yalnızca bir kez gösterilen "önce nazikçe sor" sayfası: sistem izin
/// penceresi ancak kullanıcı "Hatırlat" derse açılır (reddedilen sistem izni geri alınamadığı için
/// bu, doğrudan sistem penceresini göstermekten daha güvenli).
struct ReminderPromptSheet: View {
    let streakDays: Int
    var onAccept: () -> Void
    var onDecline: () -> Void

    var body: some View {
        VStack(spacing: GeoSpacing.lg) {
            GeoGlyphCircle(symbol: "flame.fill", background: GeoColor.accentPrimary, size: 84)
                .kasifWinGlow(color: GeoColor.accentHighlight, size: 170)
            Text("Serini korumak ister misin?")
                .font(.custom(GeoFontName.balooBold, size: 22))
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)
            Text("Her akşam 19.00'da küçük bir hatırlatma gönderelim, serin yarım kalmasın. İstediğin zaman Ayarlar'dan kapatabilirsin.")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(GeoColor.textSecondary)
                .multilineTextAlignment(.center)
            VStack(spacing: GeoSpacing.md) {
                Button("Hatırlat", action: onAccept)
                    .buttonStyle(.kasifPrimary)
                    .frame(maxWidth: .infinity)
                Button("Şimdi değil", action: onDecline)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(GeoColor.textMuted)
            }
            .padding(.top, GeoSpacing.sm)
        }
        .padding(.horizontal, GeoSpacing.xxl)
        .padding(.top, GeoSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    ReminderPromptSheet(streakDays: 1, onAccept: {}, onDecline: {})
}
