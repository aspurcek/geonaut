import SwiftUI

/// Misafir modunda (bkz. AppState.Phase.guest) Kupalar/Profil gibi hesap gerektiren
/// alanlara girildiğinde gösterilir. Ürün kararı: yalnızca Bayrak Tahmin › Avrupa ›
/// Etap 1 hesapsız oynanabilir; gerisi için Apple ile giriş istenir.
struct GuestLockedView: View {
    @Binding var selectedTab: GeoTab
    var onSignIn: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: GeoSpacing.lg) {
                Spacer()

                Circle()
                    .fill(GeoColor.bgLocked)
                    .frame(width: 96, height: 96)
                    .overlay {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(GeoColor.textMuted)
                    }

                Text("Bunu kullanmak için giriş yapmalısın")
                    .font(.custom(GeoFontName.balooBold, size: 22))
                    .foregroundStyle(GeoColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text("İlerlemeni, puanlarını ve rozetlerini kaydedebilmemiz için Apple ile giriş yapman gerekiyor.")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(GeoColor.textSecondary)
                    .multilineTextAlignment(.center)

                GeoSocialButton(provider: .apple, action: onSignIn)
                    .padding(.top, GeoSpacing.sm)

                Spacer()
                Spacer()
            }
            .padding(.horizontal, GeoSpacing.xxl)

            GeoNavBar(selection: $selectedTab)
        }
        .background(GeoColor.bgCanvas)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    GuestLockedView(selectedTab: .constant(.cups), onSignIn: {})
}
