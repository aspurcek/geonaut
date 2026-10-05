import SwiftUI

/// Figma "Serini Kaybettin - Yeniden Başla" (node 508:12231) — canlandırmayı
/// reddedince (Vazgeç) gösterilen, seriyi sıfırlayan ekran.
struct StreakRestartView: View {
    let streakDays: Int
    var onRestart: () -> Void

    var body: some View {
        VStack(spacing: GeoSpacing.xl) {
            Spacer()

            GeoSadIllustration()

            Text("Olsun, Bazen Böyle Olur!")
                .font(.custom(GeoFontName.balooBold, size: 24))
                .foregroundStyle(GeoColor.textPrimary)

            Text("\(streakDays) günlük serin sona erdi ama önemli değil. Hadi bugün yeniden başla, yeni bir seri seni bekliyor!")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(GeoColor.textSecondary)
                .multilineTextAlignment(.center)

            Button("Yeniden Başla", action: onRestart)
                .buttonStyle(.kasifPrimary)
                .frame(maxWidth: .infinity)

            Spacer()
        }
        .padding(.horizontal, GeoSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
    }
}

#Preview {
    StreakRestartView(streakDays: 12, onRestart: {})
}
