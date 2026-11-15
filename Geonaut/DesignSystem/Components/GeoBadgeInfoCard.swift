import SwiftUI

/// Rozetler & Kupalar ekranında bir rozete dokununca çıkan bilgi kartı — kullanıcı
/// kararı: "nasıl kazanılacağını anlatsın, eğer kazandıysa kazandığını belli etsin".
/// GeoCountryInfoCard/GeoFoodInfoCard ile aynı native .sheet deseni (bkz. o
/// dosyalardaki kullanıcı geri bildirimi notu).
struct BadgeCardInfo: Identifiable, Equatable {
    let title: String
    let icon: String
    let accentColor: Color
    let unlocked: Bool
    let description: String
    var id: String { title }

    static func == (lhs: BadgeCardInfo, rhs: BadgeCardInfo) -> Bool {
        lhs.title == rhs.title && lhs.unlocked == rhs.unlocked
    }
}

struct GeoBadgeInfoCard: View {
    let info: BadgeCardInfo

    var body: some View {
        VStack(spacing: GeoSpacing.lg) {
            GeoMedal(symbol: info.icon, color: info.accentColor, size: 96, locked: !info.unlocked)
                .padding(.top, GeoSpacing.xs)

            Text(LocalizedStringKey(info.title))
                .font(.custom(GeoFontName.balooExtraBold, size: 22))
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)

            GeoBadge(
                text: info.unlocked ? "Kazanıldı!" : "Henüz kazanılmadı",
                tone: info.unlocked ? .success : .neutral
            )

            // Kullanıcı kararı: açıklama zaten kazanılmış bir rozette de aynen
            // gösteriliyor ("Kazanıldı!" ile birlikte) — bu yüzden metin artık
            // emir kipiyle ("...tamamla") değil, ne zaman kazanıldığını/kazanılacağını
            // anlatan bir bilgi cümlesiyle ("...tamamladığında kazanırsın") yazılıyor
            // (bkz. BadgeCatalog.description), başına da bir bilgi ikonu eklendi.
            HStack(alignment: .top, spacing: GeoSpacing.xs) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(GeoColor.textMuted)
                Text(info.description)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(GeoColor.textSecondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, GeoSpacing.xl)
        .padding(.top, GeoSpacing.xl)
        .frame(maxWidth: .infinity)
    }
}

extension View {
    func badgeInfoSheet(selected: Binding<BadgeCardInfo?>) -> some View {
        sheet(item: selected) { info in
            GeoBadgeInfoCard(info: info)
                .presentationDetents([.height(360)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.white)
        }
    }
}

#Preview {
    VStack {
        GeoBadgeInfoCard(info: BadgeCardInfo(
            title: "Avrupa", icon: "building.columns.fill", accentColor: GeoColor.accentPrimary, unlocked: true,
            description: "Bayraklar'da Avrupa bölümünün 8 seviyesini tamamla."
        ))
        Divider()
        GeoBadgeInfoCard(info: BadgeCardInfo(
            title: "Karışık", icon: "shuffle", accentColor: GeoColor.accentTertiaryStrong, unlocked: false,
            description: "Diğer 7 kıtayı bitirince açılan Karışık bölümünün 8 seviyesini tamamla."
        ))
    }
    .background(Color.white)
}
