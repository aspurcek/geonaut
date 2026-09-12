import SwiftUI

/// Figma Design System / Bileşenler / Divider (node 31:30). "E-posta ile devam et" /
/// "Apple ile Devam Et" butonları arasındaki "veya" ayracı.
struct KasifDivider: View {
    var label: String = "veya"

    var body: some View {
        HStack(spacing: KasifSpacing.md) {
            Rectangle().fill(KasifColor.borderSubtle).frame(height: 1.5)
            Text(label)
                .font(KasifTypography.bodySemibold)
                .foregroundStyle(KasifColor.textSecondary)
                .fixedSize()
            Rectangle().fill(KasifColor.borderSubtle).frame(height: 1.5)
        }
    }
}

#Preview {
    KasifDivider()
        .padding(KasifSpacing.xxxl)
        .background(KasifColor.bgCanvas)
}
