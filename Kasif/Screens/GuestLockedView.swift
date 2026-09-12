import SwiftUI

/// Misafir modunda (bkz. AppState.Phase.guest) Kupalar/Profil gibi hesap gerektiren
/// alanlara girildiğinde gösterilir. Ürün kararı: yalnızca Bayrak Tahmin › Avrupa ›
/// Etap 1 hesapsız oynanabilir; gerisi için Apple ile giriş istenir.
struct GuestLockedView: View {
    @Binding var selectedTab: KasifTab
    var onSignIn: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: KasifSpacing.lg) {
                Spacer()

                Circle()
                    .fill(KasifColor.bgLocked)
                    .frame(width: 96, height: 96)
                    .overlay {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(KasifColor.textMuted)
                    }

                Text("Bunu kullanmak için giriş yapmalısın")
                    .font(.custom(KasifFontName.balooBold, size: 22))
                    .foregroundStyle(KasifColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text("İlerlemeni, puanlarını ve rozetlerini kaydedebilmemiz için Apple ile giriş yapman gerekiyor.")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(KasifColor.textSecondary)
                    .multilineTextAlignment(.center)

                KasifSocialButton(provider: .apple, action: onSignIn)
                    .padding(.top, KasifSpacing.sm)

                Spacer()
                Spacer()
            }
            .padding(.horizontal, KasifSpacing.xxl)

            KasifNavBar(selection: $selectedTab)
        }
        .background(KasifColor.bgCanvas)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    GuestLockedView(selectedTab: .constant(.cups), onSignIn: {})
}
