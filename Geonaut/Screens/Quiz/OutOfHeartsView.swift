import SwiftUI

/// Figma "Canların Bitti" (node 174:1034). Bkz. Bayrak Tahmin Kural Kitabı böl. 04:
/// puan ≥ 50 ise "Puanla Devam Et" (50 puan harcanır, canlar 5'e tamamlanır), değilse
/// sadece "Seviyeyi Baştan Başla" (ücretsiz, ilerleme sıfırlanır) aktif olur.
///
/// Not: Figma'daki iki buton da genel "Başlayalım" placeholder metniyle bırakılmış —
/// kural kitabındaki gerçek eylemlere göre metinler dolduruldu (tasarımda eksik olan
/// bir içerik boşluğu, yeni bir görsel karar değil).
struct OutOfHeartsView: View {
    let currentPoints: Int
    var onContinueWithPoints: () -> Void
    var onRestartStage: () -> Void
    /// Kullanıcı kararı: canlar bitince de seviyeden çıkılabilsin (ücretsiz, puan kaybı yok).
    var onExit: () -> Void = {}

    private var canAffordRefill: Bool { currentPoints >= GameRules.heartRefillCost }

    var body: some View {
        VStack(spacing: GeoSpacing.xl) {
            Spacer()

            GeoAuthIllustration(type: .hearts)

            Text("Canların Bitti!")
                .font(.custom(GeoFontName.balooBold, size: 24))
                .foregroundStyle(GeoColor.textPrimary)

            Text("Devam etmek için canlarını doldurabilir ya da daha sonra tekrar dönebilirsin.")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(GeoColor.textSecondary)
                .multilineTextAlignment(.center)

            GeoStatPill(icon: .points, value: "\(currentPoints)")

            VStack(spacing: GeoSpacing.md) {
                Button("Puanla Devam Et (-\(GameRules.heartRefillCost))", action: onContinueWithPoints)
                    .buttonStyle(.kasifPrimary)
                    .frame(maxWidth: .infinity)
                    .disabled(!canAffordRefill)

                Button("Seviyeyi Baştan Başla", action: onRestartStage)
                    .buttonStyle(.kasifSecondary)
                    .frame(maxWidth: .infinity)

                Button("Seviyeden Çık", action: onExit)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(GeoColor.textMuted)
                    .padding(.top, GeoSpacing.xs)
            }

            Spacer()
        }
        .padding(.horizontal, GeoSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
    }
}

#Preview {
    VStack {
        OutOfHeartsView(currentPoints: 340, onContinueWithPoints: {}, onRestartStage: {})
        Divider()
        OutOfHeartsView(currentPoints: 20, onContinueWithPoints: {}, onRestartStage: {})
    }
}
