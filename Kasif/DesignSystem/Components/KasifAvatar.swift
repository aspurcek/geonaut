import SwiftUI

/// Figma Design System / Bileşenler / Avatar (node 162:397). 106pt renkli daire + insan
/// silueti. Profil-Ayarlar'da arka plan rengi 6 swatch'tan seçilebilir (bkz. KasifColor.avatarSwatches)
/// — önde duran silüet sabit kalır, sadece zemin rengi değişir.
struct KasifAvatar: View {
    var backgroundColor: Color = KasifColor.accentPrimarySoft
    var showSettingsBadge: Bool = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(backgroundColor)
                .frame(width: 104, height: 104)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.white)
                }

            if showSettingsBadge {
                Circle()
                    .fill(KasifColor.bgSurface)
                    .frame(width: 30, height: 30)
                    .overlay {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(KasifColor.textSecondary)
                    }
            }
        }
        .frame(width: 106, height: 106, alignment: .topLeading)
    }
}

#Preview {
    HStack(spacing: KasifSpacing.xl) {
        KasifAvatar(backgroundColor: KasifColor.accentPrimarySoft, showSettingsBadge: true)
        KasifAvatar(backgroundColor: KasifColor.accentSuccessStrong)
        KasifAvatar(backgroundColor: KasifColor.accentInfoStrong)
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
