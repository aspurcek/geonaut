import SwiftUI

/// Figma Design System / Bileşenler / Category Card (node 170:816), gerçek Ana Sayfa
/// örnekleriyle doğrulandı (271:5448-50, 344:55300-01): her kategorinin kendi "marka"
/// rengi var (Bayrak Tahmin=coral, Harita Bilmece=açık mavi) — genel/soyut dokümantasyon
/// örneğindeki nötr gri, gerçek kartlarda kullanılmıyor.
struct GeoCategoryCard: View {
    enum State { case unlocked, locked }
    enum Icon { case system(String), emoji(String) }

    let title: String
    var icon: Icon = .system("questionmark")
    var state: State = .unlocked
    /// Kilitliyken göz ardı edilir (her zaman nötr gri) — sadece unlocked'ta kullanılır.
    var iconCircleColor: Color = GeoColor.accentPrimary
    var iconTintColor: Color = .white
    /// Figma'daki "State=Selected": coral kenarlık + parlama. Bir basma/press efekti
    /// DEĞİL — "bu, içinde bulunduğun ekranın kategorisi" göstergesi, kalıcı bir durum
    /// (bkz. node 271:5448: Bayrak Tahmin'in kartı Ana Sayfa'da her zaman bu görünümde,
    /// çünkü Ana Sayfa onun ekranı; 344:55301: aynı görünüm Harita Bilmece'nin kendi
    /// akışındaki Ana Sayfa kopyasında Harita Bilmece'ye ait).
    var isCurrentCategory: Bool = false
    /// iPad'de kategori satırı artık sabit 106pt kartlar yerine genişliği doldurarak
    /// eşit paylaşıyor (kullanıcı kararı: "kategori cardları sağa sola fill olsun") —
    /// bkz. HomeView.categoryRow. iPhone'da varsayılan (false) sabit genişlik korunuyor.
    var fillWidth: Bool = false

    private var circleColor: Color { state == .locked ? GeoColor.bgLocked : iconCircleColor }
    private var tintColor: Color { state == .locked ? GeoColor.iconInactive : iconTintColor }
    private var titleColor: Color { state == .locked ? GeoColor.textMuted : GeoColor.textPrimary }

    var body: some View {
        VStack(spacing: GeoSpacing.sm) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(circleColor)
                    .frame(width: 48, height: 48)
                    .overlay {
                        switch icon {
                        case .system(let name):
                            Image(systemName: name)
                                .font(.system(size: 20))
                                .foregroundStyle(tintColor)
                        case .emoji(let emoji):
                            Text(emoji)
                                .font(.system(size: 22))
                                .opacity(state == .locked ? 0.4 : 1)
                        }
                    }

                if state == .locked {
                    Image(systemName: "lock.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(GeoColor.textMuted, GeoColor.bgCanvas)
                        .offset(x: 4, y: -4)
                }
            }

            Text(LocalizedStringKey(title))
                .font(.custom(GeoFontName.balooBold, size: 13))
                .foregroundStyle(titleColor)
                .multilineTextAlignment(.center)
                // Tek satır + gerekirse küçülme: uzun adlar (ör. Almanca "Spezialitäten") kartı
                // yükseltip diğerlerinden farklı boya getirmesin.
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(14)
        // Kategori adları artık kısa (tek satır) olduğu için sabit 126pt yükseklik
        // başlığın altında gereksiz boşluk bırakıyordu (bkz. kullanıcı geri bildirimi) —
        // yükseklik içeriğe göre; farklı satır sayılı kartlar HStack'te üstten hizalanır.
        // Kullanıcı kararı: tüm kartlar AYNI genişlikte olsun (eskiden 106 yalnızca üst sınırdı,
        // yazı kısa olan kart daha dar çıkıyordu) — iPhone'da sabit 106, iPad'de eşit paylaşım.
        .modifier(CategoryCardWidth(fillWidth: fillWidth))
        .background(GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: GeoRadius.lg))
        .overlay {
            if isCurrentCategory {
                RoundedRectangle(cornerRadius: GeoRadius.lg)
                    .strokeBorder(GeoColor.accentDanger.opacity(0.2), lineWidth: 1.5)
            }
        }
        .shadow(
            color: isCurrentCategory ? GeoColor.accentPrimary.opacity(0.35) : .black.opacity(0.08),
            radius: isCurrentCategory ? 9 : 5,
            x: 0, y: isCurrentCategory ? 8 : 4
        )
    }
}

private struct CategoryCardWidth: ViewModifier {
    let fillWidth: Bool

    func body(content: Content) -> some View {
        if fillWidth {
            content.frame(maxWidth: .infinity, alignment: .top)
        } else {
            content.frame(width: 106, alignment: .top)
        }
    }
}

/// Sadece dokunma geri bildirimi (hafif küçülme) — Figma'da ayrı bir "pressed" durumu
/// tanımlı değil, gerçek "Selected" durumu yukarıdaki isCurrentCategory'ye taşındı.
struct GeoCategoryCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GeoCategoryCardButtonStyle {
    static var kasifCategoryCard: GeoCategoryCardButtonStyle { GeoCategoryCardButtonStyle() }
}

#Preview {
    HStack(spacing: GeoSpacing.lg) {
        GeoCategoryCard(title: "Bayraklar", icon: .system("flag.fill"), state: .unlocked, iconCircleColor: GeoColor.accentPrimary, isCurrentCategory: true)
        GeoCategoryCard(title: "Haritalar", icon: .system("map.fill"), state: .unlocked, iconCircleColor: GeoColor.accentInfo, iconTintColor: GeoColor.accentInfoStrong)
        GeoCategoryCard(title: "Diller", icon: .system("character.book.closed.fill"), state: .locked)
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
