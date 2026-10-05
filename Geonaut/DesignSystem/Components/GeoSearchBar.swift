import SwiftUI

/// Figma Design System / Bileşenler / Search Bar (node 298:3665). State=Empty/Filled.
/// Not: Figma'da "Filled" durumun border rengi `color/accent/danger` olarak tanımlı
/// (hata rengi değil, dolu/aktif durumu vurgulamak için kullanılmış) — tasarıma sadık
/// kalınarak birebir uygulandı.
struct GeoSearchBar: View {
    var placeholder: String = "Bayrak veya ülke adı ara..."
    @Binding var text: String
    @FocusState private var isFocused: Bool

    private var isFilled: Bool { !text.isEmpty }

    var body: some View {
        HStack(spacing: GeoSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(GeoColor.textSecondary)

            TextField(LocalizedStringKey(placeholder), text: $text)
                .focused($isFocused)
                .font(.system(size: 15))
                .foregroundStyle(GeoColor.textPrimary)

            if isFilled {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(GeoColor.textSecondary)
                }
            }
        }
        .padding(.horizontal, GeoSpacing.lg)
        .padding(.vertical, GeoSpacing.md)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(isFilled ? GeoColor.accentDanger : GeoColor.iconInactive, lineWidth: 1.5)
        }
    }
}

#Preview {
    @Previewable @State var empty = ""
    @Previewable @State var filled = "alm"

    VStack(spacing: GeoSpacing.xl) {
        GeoSearchBar(text: $empty)
        GeoSearchBar(text: $filled)
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
