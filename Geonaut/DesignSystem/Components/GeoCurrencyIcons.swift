import SwiftUI

/// Geonaut'a özgü seri (alev) ve puan (mücevher) ikonları — SF Symbol yerine elle çizilmiş,
/// madalyalarla aynı "premium" dil: palet renklerinde degrade, parlak yüzey ve hafif hareket.
/// Kullanıcı isteği (2026-11-14): "günlük seri ve puan ikonlarını da yap".

// MARK: - Alev (günlük seri)

/// Katmanlı alev: dışta mercan degrade, içte sarı-krem çekirdek, sol lobda parlama.
/// `lit` false ise (seri 0) gri ve sönük; true ise çok hafif titrer.
struct GeoFlameIcon: View {
    var size: CGFloat = 20
    var lit = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20, paused: reduceMotion || !lit)) { context in
            let t = (reduceMotion || !lit) ? 0 : context.date.timeIntervalSinceReferenceDate
            let flicker = 1 + 0.035 * sin(t * 7) + 0.02 * sin(t * 11.3)
            ZStack {
                FlameOuter()
                    .fill(lit
                          ? AnyShapeStyle(LinearGradient(colors: [GeoColor.accentPrimarySoft, GeoColor.accentPrimary, GeoColor.accentPrimaryStrong], startPoint: .top, endPoint: .bottom))
                          : AnyShapeStyle(GeoColor.iconInactive))
                FlameInner()
                    .fill(lit
                          ? AnyShapeStyle(LinearGradient(colors: [GeoColor.accentHighlight, GeoColor.bgSurface], startPoint: .top, endPoint: .bottom))
                          : AnyShapeStyle(GeoColor.bgLocked))
                    .scaleEffect(x: 1, y: flicker * 1.02, anchor: .bottom)
                Ellipse()
                    .fill(.white.opacity(lit ? 0.45 : 0.25))
                    .frame(width: size * 0.14, height: size * 0.26)
                    .rotationEffect(.degrees(20))
                    .offset(x: -size * 0.2, y: -size * 0.02)
            }
            .scaleEffect(x: 1, y: flicker, anchor: .bottom)
        }
        .frame(width: size * 0.86, height: size)
        .shadow(color: lit ? GeoColor.accentPrimary.opacity(0.35) : .clear, radius: size * 0.12, y: size * 0.05)
        .accessibilityHidden(true)
    }
}

private struct FlameOuter: Shape {
    func path(in r: CGRect) -> Path {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: r.minX + x * r.width, y: r.minY + y * r.height) }
        var path = Path()
        path.move(to: p(0.5, 0.99))
        path.addCurve(to: p(0.06, 0.62), control1: p(0.24, 0.99), control2: p(0.05, 0.83))
        path.addCurve(to: p(0.32, 0.20), control1: p(0.07, 0.44), control2: p(0.22, 0.34))
        path.addCurve(to: p(0.54, 0.0), control1: p(0.40, 0.11), control2: p(0.50, 0.07))
        path.addCurve(to: p(0.72, 0.36), control1: p(0.58, 0.14), control2: p(0.64, 0.26))
        path.addCurve(to: p(0.84, 0.26), control1: p(0.77, 0.36), control2: p(0.82, 0.32))
        path.addCurve(to: p(0.94, 0.62), control1: p(0.94, 0.38), control2: p(0.96, 0.50))
        path.addCurve(to: p(0.5, 0.99), control1: p(0.93, 0.83), control2: p(0.76, 0.99))
        path.closeSubpath()
        return path
    }
}

private struct FlameInner: Shape {
    func path(in r: CGRect) -> Path {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: r.minX + x * r.width, y: r.minY + y * r.height) }
        var path = Path()
        path.move(to: p(0.5, 0.95))
        path.addCurve(to: p(0.26, 0.72), control1: p(0.36, 0.95), control2: p(0.26, 0.85))
        path.addCurve(to: p(0.50, 0.40), control1: p(0.26, 0.58), control2: p(0.42, 0.50))
        path.addCurve(to: p(0.74, 0.72), control1: p(0.58, 0.50), control2: p(0.74, 0.58))
        path.addCurve(to: p(0.5, 0.95), control1: p(0.74, 0.85), control2: p(0.64, 0.95))
        path.closeSubpath()
        return path
    }
}

// MARK: - Mücevher (puan)

/// Yüzeyli (fasetli) mücevher: gök mavisi tonlarında üçgen yüzeyler, ince koyu kontur
/// ve sağ üstte ara sıra göz kırpan bir parıltı.
struct GeoGemIcon: View {
    var size: CGFloat = 20

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private typealias Facet = (points: [CGPoint], color: Color)

    private static let light = GeoColor.accentInfo
    private static let strong = GeoColor.accentInfoStrong

    /// Birim karede (0...1) yüzeyler: üstte taç, altta sivri kısım.
    private static let facets: [Facet] = [
        ([.init(x: 0.03, y: 0.38), .init(x: 0.22, y: 0.12), .init(x: 0.34, y: 0.38)], light),
        ([.init(x: 0.22, y: 0.12), .init(x: 0.5, y: 0.38), .init(x: 0.34, y: 0.38)], Color.white.opacity(0.75)),
        ([.init(x: 0.22, y: 0.12), .init(x: 0.78, y: 0.12), .init(x: 0.5, y: 0.38)], Color.white.opacity(0.92)),
        ([.init(x: 0.78, y: 0.12), .init(x: 0.66, y: 0.38), .init(x: 0.5, y: 0.38)], light),
        ([.init(x: 0.78, y: 0.12), .init(x: 0.97, y: 0.38), .init(x: 0.66, y: 0.38)], strong.opacity(0.75)),
        ([.init(x: 0.03, y: 0.38), .init(x: 0.34, y: 0.38), .init(x: 0.5, y: 0.95)], light),
        ([.init(x: 0.34, y: 0.38), .init(x: 0.66, y: 0.38), .init(x: 0.5, y: 0.95)], strong.opacity(0.8)),
        ([.init(x: 0.66, y: 0.38), .init(x: 0.97, y: 0.38), .init(x: 0.5, y: 0.95)], strong)
    ]

    var body: some View {
        ZStack {
            Canvas { context, canvasSize in
                func pt(_ u: CGPoint) -> CGPoint { CGPoint(x: u.x * canvasSize.width, y: u.y * canvasSize.height) }
                for facet in Self.facets {
                    var path = Path()
                    path.addLines(facet.points.map(pt))
                    path.closeSubpath()
                    context.fill(path, with: .color(Self.light))
                    context.fill(path, with: .color(facet.color))
                }
                var outline = Path()
                outline.addLines([.init(x: 0.22, y: 0.12), .init(x: 0.78, y: 0.12), .init(x: 0.97, y: 0.38), .init(x: 0.5, y: 0.95), .init(x: 0.03, y: 0.38)].map(pt))
                outline.closeSubpath()
                context.stroke(outline, with: .color(Self.strong), style: StrokeStyle(lineWidth: max(1, canvasSize.width * 0.06), lineJoin: .round))
            }
            TimelineView(.animation(minimumInterval: 1.0 / 20, paused: reduceMotion)) { context in
                let t = reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate
                let phase = (t.truncatingRemainder(dividingBy: 3.2)) / 3.2
                let twinkle = phase < 0.25 ? sin(phase / 0.25 * .pi) : 0
                Image(systemName: "sparkle")
                    .font(.system(size: size * 0.42, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: Self.strong.opacity(0.6), radius: 1)
                    .scaleEffect(0.4 + 0.8 * twinkle)
                    .opacity(reduceMotion ? 0 : twinkle)
                    .offset(x: size * 0.36, y: -size * 0.34)
            }
        }
        .frame(width: size, height: size)
        .shadow(color: Self.strong.opacity(0.3), radius: size * 0.1, y: size * 0.05)
        .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 24) {
        GeoFlameIcon(size: 40)
        GeoFlameIcon(size: 40, lit: false)
        GeoGemIcon(size: 40)
        GeoFlameIcon(size: 20)
        GeoGemIcon(size: 20)
    }
    .padding()
    .background(GeoColor.bgCanvas)
}
