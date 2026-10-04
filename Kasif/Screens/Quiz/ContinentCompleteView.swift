import SwiftUI

/// Figma "Kıta Tamamlandı - Avrupa" (node 176:1093). Bir kıtanın 8 etabı da bitince
/// gösterilir — bkz. Bayrak Tahmin Kural Kitabı böl. 02: "Bir kıtanın 8. etabı bitince
/// o kıtanın kupası kazanılır."
struct ContinentCompleteView: View {
    let continentName: String
    /// Bayrak Tahmin dışındaki kategoriler (ör. Ana Diller) kendi başarı metnini
    /// geçebilir — varsayılan, bu ekranın ilk sahibi olan Bayrak Tahmin'in metni.
    var achievementText: String? = nil
    var onContinue: () -> Void

    private var icon: (icon: String, color: Color) {
        BadgeCatalog.continentIcon(for: continentName) ?? ("🏆", KasifColor.accentHighlightStrong)
    }

    var body: some View {
        VStack(spacing: KasifSpacing.lg) {
            Spacer()

            KasifAchievementBadge(title: continentName, icon: icon.icon, accentColor: icon.color, state: .unlocked)
                .scaleEffect(1.1)
                .kasifWinGlow(color: icon.color)

            Text("\(L(continentName)) Kıtası Tamamlandı!")
                .font(.custom(KasifFontName.balooBold, size: 24))
                .foregroundStyle(KasifColor.textPrimary)
                .multilineTextAlignment(.center)

            Text(achievementText.map { LocalizedStringKey($0) } ?? LocalizedStringKey("\(L(continentName))'daki tüm bayrakları öğrendin. \(L(continentName)) Kupasını kazandın!"))
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
        .background { KasifColor.bgCanvas.ignoresSafeArea() }
    }
}

#Preview {
    ContinentCompleteView(continentName: "Avrupa", onContinue: {})
}
