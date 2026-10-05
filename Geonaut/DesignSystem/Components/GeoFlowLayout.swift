import SwiftUI

/// Figma'daki rozet ızgaraları eşit genişlikli sütunlar değil — her rozet kendi
/// metnine göre genişler ve satır sonunda bir sonraki satıra kayar (bkz. "Rozetler"
/// node 355:13868 metadata: örn. "Afrika" 56pt, "K. Amerika" 68pt, "Bayrak Bilmece
/// Kupası" tek başına 142pt, hepsi sol hizalı). LazyVGrid'in eşit sütunları bunu
/// üretemiyor, bu yüzden basit bir flow/wrap layout.
struct GeoFlowLayout: Layout {
    var horizontalSpacing: CGFloat = GeoSpacing.md
    var verticalSpacing: CGFloat = GeoSpacing.lg

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > maxWidth {
                x = 0
                y += rowHeight + verticalSpacing
                rowHeight = 0
            }
            x += size.width + horizontalSpacing
            rowHeight = max(rowHeight, size.height)
        }
        y += rowHeight
        return CGSize(width: maxWidth, height: y)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX && x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + verticalSpacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + horizontalSpacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
