import SwiftUI

/// Alt sayfada gösterilecek bilgi: istatistik açıklamaları (Puan, Günlük Seri, Öğrenilen Ülke) ve
/// kilitli bölümlerin "neden kilitli" mesajları aynı kalıbı kullanır (bkz. Figma FLOW10).
struct InfoSheetContent: Identifiable {
    let id: String
    let icon: String          // SF Symbol
    let tint: Color
    let title: String
    var value: String? = nil  // örn. "340 puan"
    let lines: [String]
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
}

private struct InfoSheetHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = max(value, nextValue()) }
}

struct InfoSheet: View {
    let content: InfoSheetContent
    @Environment(\.dismiss) private var dismiss
    /// Sayfa içeriğin kendi yüksekliği kadar açılır (ölü alan kalmasın); ölçülene kadar makul bir başlangıç değeri.
    @State private var contentHeight: CGFloat = 420

    var body: some View {
        VStack(spacing: GeoSpacing.lg) {
            Image(systemName: content.icon)
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(content.tint)
                .frame(width: 72, height: 72)
                .background(content.tint.opacity(0.16), in: Circle())
                .accessibilityHidden(true)

            VStack(spacing: GeoSpacing.xs) {
                Text(content.title)
                    .font(.custom(GeoFontName.balooExtraBold, size: 24))
                    .foregroundStyle(GeoColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                if let value = content.value {
                    Text(value)
                        .font(.custom(GeoFontName.balooBold, size: 18))
                        .foregroundStyle(content.tint)
                }
            }

            VStack(alignment: .leading, spacing: GeoSpacing.md) {
                ForEach(content.lines, id: \.self) { line in
                    HStack(alignment: .top, spacing: GeoSpacing.sm) {
                        Circle()
                            .fill(content.tint)
                            .frame(width: 6, height: 6)
                            .padding(.top, 7)
                        Text(line)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(GeoColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: GeoSpacing.sm) {
                if let actionTitle = content.actionTitle, let action = content.action {
                    Button {
                        dismiss()
                        action()
                    } label: {
                        Text(actionTitle).frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.kasifPrimary)

                    Button("Anladım") { dismiss() }
                        .font(.custom(GeoFontName.nunitoBold, size: 15))
                        .foregroundStyle(GeoColor.textSecondary)
                        .frame(minHeight: 44)
                } else {
                    Button {
                        dismiss()
                    } label: {
                        Text("Anladım").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.kasifPrimary)
                }
            }
        }
        .padding(.horizontal, GeoSpacing.xl)
        .padding(.top, GeoSpacing.xxl)
        .padding(.bottom, GeoSpacing.xxxl)
        .frame(maxWidth: .infinity)
        .background {
            GeometryReader { proxy in
                Color.clear.preference(key: InfoSheetHeightKey.self, value: proxy.size.height)
            }
        }
        .onPreferenceChange(InfoSheetHeightKey.self) { if $0 > 0 { contentHeight = $0 } }
        .frame(maxHeight: .infinity, alignment: .top)
        .presentationBackground(GeoColor.bgCanvas)
        .presentationDetents([.height(contentHeight)])
        .presentationDragIndicator(.visible)
    }
}

/// Hazır içerikler. Metinler `L()` ile yerelleştirilir (Localizable.xcstrings).
enum InfoSheets {
    static func points(current: Int) -> InfoSheetContent {
        InfoSheetContent(
            id: "points", icon: "diamond.fill", tint: GeoColor.accentInfoStrong,
            title: L("Puan"), value: String(format: L("%lld puan"), current),
            lines: [
                L("Her doğru cevap 10 puan kazandırır."),
                L("Bir seviyeyi bitirince puanların toplamına eklenir. Aynı seviyeyi tekrar oynarsan yalnızca en iyi sonucun sayılır."),
                L("Canların bitince 50 puanla devam edebilir, kopan serini 50 puanla canlandırabilirsin."),
                L("Ünvanın, harcadığın puana değil şimdiye kadar kazandığın toplam puana bağlıdır. Puan harcamak ünvanını düşürmez."),
            ]
        )
    }

    static func streak(days: Int) -> InfoSheetContent {
        InfoSheetContent(
            id: "streak", icon: "flame.fill", tint: GeoColor.accentPrimaryStrong,
            title: L("Günlük Seri"), value: String(format: L("%lld gün"), days),
            lines: [
                L("Her gün en az bir seviye bitirince serin bir artar."),
                L("Bir gün hiç oynamazsan seri kopar. 50 puanla kaldığın yerden canlandırabilirsin."),
                L("Serin 7, 14, 21… güne ulaşınca 100 puan hediye kazanırsın."),
                L("Profilindeki haftalık takvimde hangi günlerde oynadığını görebilirsin."),
            ]
        )
    }

    static func countries(learned: Int) -> InfoSheetContent {
        InfoSheetContent(
            id: "countries", icon: "globe.europe.africa.fill", tint: GeoColor.accentInfoStrong,
            title: L("Öğrenilen Ülke"), value: String(format: L("%lld / %lld ülke"), learned, Countries.all.count),
            lines: [
                L("Bir soruda gördüğün ve cevapladığın her ülke bu sayıya eklenir. Doğru ya da yanlış fark etmez."),
                L("Bayraklar, Haritalar, Diller, Lezzetler ve Başkentler'deki ülkeler birlikte sayılır."),
                L("Aynı ülkeyi tekrar görmek sayıyı artırmaz. Hedef tüm ülkeleri tanımak."),
            ]
        )
    }
}

/// "Neden kilitli?" mesajları.
enum LockInfo {
    /// Kategori kilitleri: Haritalar ← Bayraklar Tur 1, Diller ← Haritalar, Lezzetler ← Diller, Başkentler ← Lezzetler.
    static func category(_ category: TourCategory, goTo: @escaping () -> Void) -> InfoSheetContent? {
        let title: String, body: String, action: String
        switch category {
        case .maps:
            title = L("Haritalar kilitli"); body = L("Haritalar'ı açmak için Bayraklar'ın Tur 1'ini bitirmelisin."); action = L("Bayraklar'a git")
        case .languages:
            title = L("Diller kilitli"); body = L("Diller'i açmak için Haritalar'ın Tur 1'ini bitirmelisin."); action = L("Haritalar'a git")
        case .foods:
            title = L("Lezzetler kilitli"); body = L("Lezzetler'i açmak için Diller'in Tur 1'ini bitirmelisin."); action = L("Diller'e git")
        case .capitals:
            title = L("Başkentler kilitli"); body = L("Başkentler'i açmak için Lezzetler'in Tur 1'ini bitirmelisin."); action = L("Lezzetler'e git")
        default:
            return nil
        }
        return InfoSheetContent(id: "lock-\(title)", icon: "lock.fill", tint: GeoColor.textSecondary, title: title, lines: [body], actionTitle: action, action: goTo)
    }

    static func tour(_ tour: Int) -> InfoSheetContent {
        InfoSheetContent(
            id: "lock-tour-\(tour)", icon: "lock.fill", tint: GeoColor.textSecondary,
            title: String(format: L("Tur %lld kilitli"), tour + 1),
            lines: [String(format: L("Tur %lld'i açmak için önce Tur %lld'i bitirmelisin."), tour + 1, tour)]
        )
    }

    static let stage = InfoSheetContent(
        id: "lock-stage", icon: "lock.fill", tint: GeoColor.textSecondary,
        title: L("Bu seviye kilitli"), lines: [L("Önceki seviyeyi bitirince bu seviye açılır.")]
    )

    static let section = InfoSheetContent(
        id: "lock-section", icon: "lock.fill", tint: GeoColor.textSecondary,
        title: L("Bu bölüm kilitli"), lines: [L("Bu bölümü açmak için önceki bölümün tüm seviyelerini bitirmelisin.")]
    )
}
