import SwiftUI

/// Figma Design System / Bileşenler / Input Field (node 31:18).
/// State=Default/Filled/Focused/Error — Filled ve Focused görsel olarak metin rengi
/// dışında aynı, bu yüzden burada state ayrımı `isFocused` (otomatik) ve
/// `errorMessage` (verilirse Error durumuna geçer) üzerinden yapılıyor.
struct KasifTextField: View {
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
        if isError { return KasifColor.accentDanger }
        if isFocused { return KasifColor.accentPrimary }
        return KasifColor.borderSubtle
    }

    private var borderWidth: CGFloat { isError || isFocused ? 2 : 1.5 }

    var body: some View {
        VStack(alignment: .leading, spacing: KasifSpacing.xs) {
            Text(LocalizedStringKey(label))
                .font(KasifTypography.bodySemibold)
                .foregroundStyle(KasifColor.textPrimary)

            Group {
                if isSecure {
                    SecureField(LocalizedStringKey(placeholder), text: $text)
                } else {
                    TextField(LocalizedStringKey(placeholder), text: $text)
                        .keyboardType(keyboardType)
                }
            }
            .focused($isFocused)
            .font(KasifTypography.bodyBoldL)
            .foregroundStyle(text.isEmpty ? KasifColor.textMuted : KasifColor.textPrimary)
            .padding(.horizontal, KasifSpacing.lg)
            .padding(.vertical, KasifSpacing.md)
            .frame(maxWidth: .infinity)
            .background(KasifColor.bgSurface, in: RoundedRectangle(cornerRadius: KasifRadius.md))
            .overlay {
                RoundedRectangle(cornerRadius: KasifRadius.md)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            }

            if let errorMessage {
                Text(LocalizedStringKey(errorMessage))
                    .font(KasifTypography.caption)
                    .foregroundStyle(KasifColor.accentDanger)
            } else if !helperText.isEmpty {
                Text(LocalizedStringKey(helperText))
                    .font(KasifTypography.caption)
                    .foregroundStyle(KasifColor.textMuted)
            }
        }
        .animation(.easeOut(duration: 0.15), value: isFocused)
    }
}

#Preview {
    @Previewable @State var email = ""
    @Previewable @State var filled = "ornek@eposta.com"
    @Previewable @State var invalid = "ornek@eposta"

    VStack(spacing: KasifSpacing.xl) {
        KasifTextField(label: "E-posta", placeholder: "ornek@eposta.com", text: $email,
                        helperText: "E-posta adresini gir")
        KasifTextField(label: "E-posta", placeholder: "ornek@eposta.com", text: $filled,
                        helperText: "E-posta adresini gir")
        KasifTextField(label: "E-posta", placeholder: "ornek@eposta.com", text: $invalid,
                        errorMessage: "Geçerli bir e-posta adresi gir")
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
