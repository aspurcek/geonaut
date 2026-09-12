import SwiftUI

/// Figma Design System / Bileşenler / Category Card (node 170:816), gerçek Ana Sayfa
/// örnekleriyle doğrulandı (271:5448-50, 344:55300-01): her kategorinin kendi "marka"
/// rengi var (Bayrak Tahmin=coral, Harita Bilmece=açık mavi) — genel/soyut dokümantasyon
/// örneğindeki nötr gri, gerçek kartlarda kullanılmıyor.
struct KasifCategoryCard: View {
    enum State { case unlocked, locked }
    enum Icon { case system(String), emoji(String) }

    let title: String
    var icon: Icon = .system("questionmark")
    var state: State = .unlocked
    /// Kilitliyken göz ardı edilir (her zaman nötr gri) — sadece unlocked'ta kullanılır.
    var iconCircleColor: Color = KasifColor.accentPrimary
    var iconTintColor: Color = .white
    /// Figma'daki "State=Selected": coral kenarlık + parlama. Bir basma/press efekti
    /// DEĞİL — "bu, içinde bulunduğun ekranın kategorisi" göstergesi, kalıcı bir durum
    /// (bkz. node 271:5448: Bayrak Tahmin'in kartı Ana Sayfa'da her zaman bu görünümde,
    /// çünkü Ana Sayfa onun ekranı; 344:55301: aynı görünüm Harita Bilmece'nin kendi
    /// akışındaki Ana Sayfa kopyasında Harita Bilmece'ye ait).
    var isCurrentCategory: Bool = false

    private var circleColor: Color { state == .locked ? KasifColor.bgLocked : iconCircleColor }
    private var tintColor: Color { state == .locked ? KasifColor.iconInactive : iconTintColor }
    private var titleColor: Color { state == .locked ? KasifColor.textMuted : KasifColor.textPrimary }

    var body: some View {
        VStack(spacing: KasifSpacing.sm) {
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
                        .foregroundStyle(KasifColor.textMuted, KasifColor.bgCanvas)
                        .offset(x: 4, y: -4)
                }
            }

            Text(title)
                .font(.custom(KasifFontName.balooBold, size: 13))
                .foregroundStyle(titleColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(14)
        // Figma'da üç kart da sabit 108.67x126 (node "Category Cards", 271:5447) —
        // metin tek/çift satır olsa da hepsi aynı boyda olmalı.
        .frame(width: 106, height: 126)
        .background(KasifColor.bgSurface, in: RoundedRectangle(cornerRadius: KasifRadius.lg))
        .overlay {
            if isCurrentCategory {
                RoundedRectangle(cornerRadius: KasifRadius.lg)
                    .strokeBorder(KasifColor.accentDanger.opacity(0.2), lineWidth: 1.5)
            }
        }
        .shadow(
            color: isCurrentCategory ? KasifColor.accentPrimary.opacity(0.35) : .black.opacity(0.08),
            radius: isCurrentCategory ? 9 : 5,
            x: 0, y: isCurrentCategory ? 8 : 4
        )
    }
}

/// Sadece dokunma geri bildirimi (hafif küçülme) — Figma'da ayrı bir "pressed" durumu
/// tanımlı değil, gerçek "Selected" durumu yukarıdaki isCurrentCategory'ye taşındı.
struct KasifCategoryCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == KasifCategoryCardButtonStyle {
    static var kasifCategoryCard: KasifCategoryCardButtonStyle { KasifCategoryCardButtonStyle() }
}

#Preview {
    HStack(spacing: KasifSpacing.lg) {
        KasifCategoryCard(title: "Bayrak Tahmin", icon: .emoji("🇹🇷"), state: .unlocked, iconCircleColor: KasifColor.accentPrimary, isCurrentCategory: true)
        KasifCategoryCard(title: "Harita Bilmece", icon: .system("map.fill"), state: .unlocked, iconCircleColor: KasifColor.accentInfo, iconTintColor: KasifColor.accentInfoStrong)
        KasifCategoryCard(title: "Ana Diller", icon: .system("character.book.closed.fill"), state: .locked)
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
