import SwiftUI

/// Figma "Serini Kaybettin - Yeniden Başla" (node 508:12231) — canlandırmayı
/// reddedince (Vazgeç) gösterilen, seriyi sıfırlayan ekran.
struct StreakRestartView: View {
    let streakDays: Int
    var onRestart: () -> Void

    var body: some View {
        VStack(spacing: KasifSpacing.xl) {
            Spacer()

            KasifSadIllustration()

            Text("Olsun, Bazen Böyle Olur!")
                .font(.custom(KasifFontName.balooBold, size: 24))
                .foregroundStyle(KasifColor.textPrimary)

            Text("\(streakDays) günlük serin sona erdi ama önemli değil. Hadi bugün yeniden başla, yeni bir seri seni bekliyor!")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(KasifColor.textSecondary)
                .multilineTextAlignment(.center)

            Button("Yeniden Başla", action: onRestart)
                .buttonStyle(.kasifPrimary)
                .frame(maxWidth: .infinity)

            Spacer()
        }
        .padding(.horizontal, KasifSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { KasifColor.bgCanvas.ignoresSafeArea() }
    }
}

#Preview {
    StreakRestartView(streakDays: 12, onRestart: {})
}
