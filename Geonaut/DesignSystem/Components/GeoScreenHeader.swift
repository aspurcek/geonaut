import SwiftUI

/// Geri oku: görsel boyutu 18 pt'lik ikon ama dokunma alanı 44×44 pt (Apple'ın önerdiği
/// en az boyut). Bkz. GeoScreenHeader ve sınav ekranlarındaki üst çubuk.
struct GeoBackButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .accessibilityLabel("Geri")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(GeoColor.textPrimary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
    }
}

/// Ekran başlığı: geri oku, başlık (ve isteğe bağlı sağ öğe) TEK satırda, alt başlık
/// geri okun sol kenarıyla hizalı altında. Önceden ok kendi satırını kaplıyor, yanı boş kalıyordu.
/// `onBack` nil ise (sekme kökü ekranlar) ok ve girinti yoktur.
struct GeoScreenHeader<Trailing: View>: View {
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey? = nil
    var titleFontName: String = GeoFontName.balooExtraBold
    var titleSize: CGFloat = 24
    var onBack: (() -> Void)? = nil
    @ViewBuilder var trailing: () -> Trailing

    /// 44 pt'lik dokunma alanı ikonu içeri itmesin diye satır sola kaydırılır; 
    private static var shift: CGFloat { GeoSpacing.sm }
    /// Alt başlık, başlığa değil geri okun görünen sol kenarına hizalanır: 44 pt'lik alanda ortalanan
    /// ok (≈12 pt genişlik) kaydırmadan sonra sayfa kenarından ≈8 pt içeride başlar.
    private var subtitleIndent: CGFloat { onBack == nil ? 0 : GeoSpacing.sm }

    var body: some View {
        VStack(alignment: .leading, spacing: GeoSpacing.xs) {
            HStack(spacing: -4) {
                if let onBack {
                    GeoBackButton(action: onBack)
                }
                Text(title)
                    .font(.custom(titleFontName, size: titleSize))
                    .foregroundStyle(GeoColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: GeoSpacing.sm)
                trailing()
            }
            .padding(.leading, onBack == nil ? 0 : -Self.shift)

            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(GeoColor.textSecondary)
                    .padding(.leading, subtitleIndent)
            }
        }
    }
}

extension GeoScreenHeader where Trailing == EmptyView {
    init(
        title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil,
        titleFontName: String = GeoFontName.balooExtraBold, titleSize: CGFloat = 24,
        onBack: (() -> Void)? = nil
    ) {
        self.init(
            title: title, subtitle: subtitle, titleFontName: titleFontName,
            titleSize: titleSize, onBack: onBack, trailing: { EmptyView() }
        )
    }
}
