import SwiftUI

/// Figma Design System / Bileşenler / Input Field (node 31:18).
/// State=Default/Filled/Focused/Error — Filled ve Focused görsel olarak metin rengi
/// dışında aynı, bu yüzden burada state ayrımı `isFocused` (otomatik) ve
/// `errorMessage` (verilirse Error durumuna geçer) üzerinden yapılıyor.
struct GeoTextField: View {
    let label: String
    var placeholder: String = ""
    @Binding var text: String
    var helperText: String = ""
    var errorMessage: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    @FocusState private var isFocused: Bool

    private var isError: Bool { errorMessage != nil }

    private var borderColor: Color {
        if isError { return GeoColor.accentDanger }
        if isFocused { return GeoColor.accentPrimary }
        return GeoColor.borderSubtle
    }

    private var borderWidth: CGFloat { isError || isFocused ? 2 : 1.5 }

    var body: some View {
        VStack(alignment: .leading, spacing: GeoSpacing.xs) {
            Text(LocalizedStringKey(label))
                .font(GeoTypography.bodySemibold)
                .foregroundStyle(GeoColor.textPrimary)

            Group {
                if isSecure {
                    SecureField(LocalizedStringKey(placeholder), text: $text)
                } else {
                    TextField(LocalizedStringKey(placeholder), text: $text)
                        .keyboardType(keyboardType)
                }
            }
            .focused($isFocused)
            .font(GeoTypography.bodyBoldL)
            .foregroundStyle(text.isEmpty ? GeoColor.textMuted : GeoColor.textPrimary)
            .padding(.horizontal, GeoSpacing.lg)
            .padding(.vertical, GeoSpacing.md)
            .frame(maxWidth: .infinity)
            .background(GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: GeoRadius.md))
            .overlay {
                RoundedRectangle(cornerRadius: GeoRadius.md)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            }

            if let errorMessage {
                Text(LocalizedStringKey(errorMessage))
                    .font(GeoTypography.caption)
                    .foregroundStyle(GeoColor.accentDanger)
            } else if !helperText.isEmpty {
                Text(LocalizedStringKey(helperText))
                    .font(GeoTypography.caption)
                    .foregroundStyle(GeoColor.textMuted)
            }
        }
        .animation(.easeOut(duration: 0.15), value: isFocused)
    }
}

#Preview {
    @Previewable @State var email = ""
    @Previewable @State var filled = "ornek@eposta.com"
    @Previewable @State var invalid = "ornek@eposta"

    VStack(spacing: GeoSpacing.xl) {
        GeoTextField(label: "E-posta", placeholder: "ornek@eposta.com", text: $email,
                        helperText: "E-posta adresini gir")
        GeoTextField(label: "E-posta", placeholder: "ornek@eposta.com", text: $filled,
                        helperText: "E-posta adresini gir")
        GeoTextField(label: "E-posta", placeholder: "ornek@eposta.com", text: $invalid,
                        errorMessage: "Geçerli bir e-posta adresi gir")
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
