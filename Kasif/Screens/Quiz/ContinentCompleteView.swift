import SwiftUI

/// Figma "Kıta Tamamlandı - Avrupa" (node 176:1093). Bir kıtanın 8 etabı da bitince
/// gösterilir — bkz. Bayrak Tahmin Kural Kitabı böl. 02: "Bir kıtanın 8. etabı bitince
/// o kıtanın kupası kazanılır."
struct ContinentCompleteView: View {
    let continentName: String
    let continentIcon: String
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: KasifSpacing.lg) {
            Spacer()

            KasifAchievementBadge(title: continentName, systemImage: continentIcon, state: .unlocked)
                .scaleEffect(1.1)

            Text("\(continentName) Kıtası Tamamlandı!")
                .font(.custom(KasifFontName.balooBold, size: 24))
                .foregroundStyle(KasifColor.textPrimary)
                .multilineTextAlignment(.center)

            Text("\(continentName)'daki tüm bayrakları öğrendin. \(continentName) Kupasını kazandın!")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(KasifColor.textSecondary)
                .multilineTextAlignment(.center)

            Button("Başlayalım", action: onContinue)
                .buttonStyle(.kasifPrimary)
                .frame(maxWidth: .infinity)
                .padding(.top, KasifSpacing.sm)

            Spacer()
        }
        .padding(.horizontal, KasifSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(KasifColor.bgCanvas)
    }
}

#Preview {
    ContinentCompleteView(continentName: "Avrupa", continentIcon: "globe.europe.africa.fill", onContinue: {})
}
