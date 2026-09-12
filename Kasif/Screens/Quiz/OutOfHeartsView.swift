import SwiftUI

/// Figma "Canların Bitti" (node 174:1034). Bkz. Bayrak Tahmin Kural Kitabı böl. 04:
/// puan ≥ 50 ise "Puanla Devam Et" (50 puan harcanır, canlar 5'e tamamlanır), değilse
/// sadece "Etabı Baştan Başla" (ücretsiz, ilerleme sıfırlanır) aktif olur.
///
/// Not: Figma'daki iki buton da genel "Başlayalım" placeholder metniyle bırakılmış —
/// kural kitabındaki gerçek eylemlere göre metinler dolduruldu (tasarımda eksik olan
/// bir içerik boşluğu, yeni bir görsel karar değil).
struct OutOfHeartsView: View {
    let currentPoints: Int
    var onContinueWithPoints: () -> Void
    var onRestartStage: () -> Void

    private var canAffordRefill: Bool { currentPoints >= GameRules.heartRefillCost }

    var body: some View {
        VStack(spacing: KasifSpacing.xl) {
            Spacer()

            KasifAuthIllustration(type: .hearts)

            Text("Canların Bitti!")
                .font(.custom(KasifFontName.balooBold, size: 24))
                .foregroundStyle(KasifColor.textPrimary)

            Text("Devam etmek için canlarını doldurabilir ya da daha sonra tekrar dönebilirsin.")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(KasifColor.textSecondary)
                .multilineTextAlignment(.center)

            KasifStatPill(icon: .points, value: "\(currentPoints)")

            VStack(spacing: KasifSpacing.md) {
                Button("Puanla Devam Et (-\(GameRules.heartRefillCost))", action: onContinueWithPoints)
                    .buttonStyle(.kasifPrimary)
                    .frame(maxWidth: .infinity)
                    .disabled(!canAffordRefill)

                Button("Etabı Baştan Başla", action: onRestartStage)
                    .buttonStyle(.kasifSecondary)
                    .frame(maxWidth: .infinity)
            }

            Spacer()
        }
        .padding(.horizontal, KasifSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(KasifColor.bgCanvas)
    }
}

#Preview {
    VStack {
        OutOfHeartsView(currentPoints: 340, onContinueWithPoints: {}, onRestartStage: {})
        Divider()
        OutOfHeartsView(currentPoints: 20, onContinueWithPoints: {}, onRestartStage: {})
    }
}
