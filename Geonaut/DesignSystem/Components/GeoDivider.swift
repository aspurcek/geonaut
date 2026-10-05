import SwiftUI

/// Figma Design System / Bileşenler / Divider (node 31:30). "E-posta ile devam et" /
/// "Apple ile Devam Et" butonları arasındaki "veya" ayracı.
struct GeoDivider: View {
    var label: String = "veya"

    var body: some View {
        HStack(spacing: GeoSpacing.md) {
            Rectangle().fill(GeoColor.borderSubtle).frame(height: 1.5)
            Text(LocalizedStringKey(label))
                .font(GeoTypography.bodySemibold)
                .foregroundStyle(GeoColor.textSecondary)
                .fixedSize()
            Rectangle().fill(GeoColor.borderSubtle).frame(height: 1.5)
        }
    }
}

#Preview {
    GeoDivider()
        .padding(GeoSpacing.xxxl)
        .background(GeoColor.bgCanvas)
}
