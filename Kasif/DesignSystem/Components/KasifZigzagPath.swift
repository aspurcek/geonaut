import SwiftUI

/// Ana Sayfa'daki kıta yolu (node 271:5428) ve Etap Haritası'ndaki (node 271:5549)
/// zikzak düğüm dizilimi aynı deseni paylaşıyor — bu genel amaçlı layout ikisinde de
/// kullanılıyor (bkz. "her tekrar eden parça tek bir reusable component" kuralı).
///
/// Not — Responsive: Figma'daki "Connector" sabit 390pt kanvasa göre çizilmiş; burada
/// aynı zikzak ritmi iki oransal x-kolonu arasında noktalı düz çizgilerle üretiliyor.
struct KasifZigzagPath<Node: View>: View {
    let count: Int
    var rowHeight: CGFloat = 130
    var leadingFraction: CGFloat = 0.18
    var trailingFraction: CGFloat = 0.62
    @ViewBuilder var node: (Int) -> Node

    var body: some View {
        GeometryReader { geo in
            let leadingX = geo.size.width * leadingFraction
            let trailingX = geo.size.width * trailingFraction

            ZStack(alignment: .top) {
                connectorPath(leadingX: leadingX, trailingX: trailingX)
                    .stroke(KasifColor.borderSubtle, style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [2, 10]))

                ForEach(0..<count, id: \.self) { index in
                    let isRight = index % 2 == 0
                    node(index)
                        .position(x: isRight ? trailingX : leadingX, y: CGFloat(index) * rowHeight + 60)
                }
            }
        }
        .frame(height: CGFloat(count) * rowHeight + 40)
    }

    private func connectorPath(leadingX: CGFloat, trailingX: CGFloat) -> Path {
        Path { path in
            guard count > 0 else { return }
            for index in 0..<count {
                let isRight = index % 2 == 0
                let point = CGPoint(x: isRight ? trailingX : leadingX, y: CGFloat(index) * rowHeight + 60)
                if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
            }
        }
    }
}
