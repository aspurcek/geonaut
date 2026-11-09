import SwiftUI

/// Figma Design System / Bileşenler / Speech Bubble (node 105:370). Maskot yanındaki
/// konuşma balonu — sol-alt köşesi keskin (xs=4), diğer köşeler md=16 radius.
/// `pointsDown` açıkken balon, altındaki öğeyi (örn. tıklanacak düğüm) gösteren küçük bir uçla çizilir.
struct GeoSpeechBubble: View {
    let text: String
    var pointsDown = false

    private static let tailHeight: CGFloat = 9

    var body: some View {
        Text(LocalizedStringKey(text))
            .font(GeoTypography.bodySemibold)
            .foregroundStyle(GeoColor.textPrimary)
            .padding(.horizontal, GeoSpacing.lg)
            .padding(.top, GeoSpacing.sm)
            .padding(.bottom, GeoSpacing.sm + (pointsDown ? Self.tailHeight : 0))
            .background {
                if pointsDown {
                    BubbleWithTail(tailHeight: Self.tailHeight)
                        .fill(GeoColor.bgSurface)
                        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 4)
                } else {
                    UnevenRoundedRectangle(
                        topLeadingRadius: GeoRadius.md,
                        bottomLeadingRadius: GeoSpacing.xs,
                        bottomTrailingRadius: GeoRadius.md,
                        topTrailingRadius: GeoRadius.md
                    )
                    .fill(GeoColor.bgSurface)
                    .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 4)
                }
            }
    }
}

/// Yuvarlak köşeli balon + alt orta kenarda aşağı bakan üçgen uç.
private struct BubbleWithTail: Shape {
    let tailHeight: CGFloat

    func path(in rect: CGRect) -> Path {
        let body = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height - tailHeight)
        var path = Path(roundedRect: body, cornerRadius: GeoRadius.md)
        let midX = rect.midX
        path.move(to: CGPoint(x: midX - 9, y: body.maxY - 0.5))
        path.addLine(to: CGPoint(x: midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: midX + 9, y: body.maxY - 0.5))
        path.closeSubpath()
        return path
    }
}

#Preview {
    VStack(spacing: GeoSpacing.xl) {
        GeoSpeechBubble(text: "Hadi başlayalım!")
        GeoSpeechBubble(text: "Hadi başlayalım!", pointsDown: true)
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
