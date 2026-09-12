import SwiftUI

/// Figma Design System / Bileşenler / Search Bar (node 298:3665). State=Empty/Filled.
/// Not: Figma'da "Filled" durumun border rengi `color/accent/danger` olarak tanımlı
/// (hata rengi değil, dolu/aktif durumu vurgulamak için kullanılmış) — tasarıma sadık
/// kalınarak birebir uygulandı.
struct KasifSearchBar: View {
    var placeholder: String = "Bayrak veya ülke adı ara..."
    @Binding var text: String
    @FocusState private var isFocused: Bool

    private var isFilled: Bool { !text.isEmpty }

    var body: some View {
        HStack(spacing: KasifSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(KasifColor.textSecondary)

            TextField(placeholder, text: $text)
                .focused($isFocused)
                .font(.system(size: 15))
                .foregroundStyle(KasifColor.textPrimary)

            if isFilled {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(KasifColor.textSecondary)
                }
            }
        }
        .padding(.horizontal, KasifSpacing.lg)
        .padding(.vertical, KasifSpacing.md)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(isFilled ? KasifColor.accentDanger : KasifColor.iconInactive, lineWidth: 1.5)
        }
    }
}

#Preview {
    @Previewable @State var empty = ""
    @Previewable @State var filled = "alm"

    VStack(spacing: KasifSpacing.xl) {
        KasifSearchBar(text: $empty)
        KasifSearchBar(text: $filled)
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
