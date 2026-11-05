import SwiftUI

/// Krem zeminin üstünde yavaşça parıldayan küçük yıldızlar (Ana Sayfa arka planı).
/// Konumlar sabit tohumdan üretilir, böylece her açılışta aynı gökyüzü görünür; içerik
/// kaydırılırken yıldızlar ekranda sabit kalır. "Hareketi azalt" açıksa parıldama durur.
struct GeoStarfield: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private struct Star {
        let x: CGFloat, y: CGFloat, size: CGFloat, phase: Double, speed: Double, color: Color
    }

    private static let stars: [Star] = {
        var rng = SeededGenerator(seed: 42)
        let palette: [Color] = [
            GeoColor.accentHighlightStrong.opacity(0.55),
            GeoColor.accentPrimarySoft.opacity(0.7),
            GeoColor.accentTertiaryStrong.opacity(0.6),
            GeoColor.accentInfoStrong.opacity(0.4)
        ]
        return (0..<26).map { i in
            Star(
                x: .random(in: 0.04...0.96, using: &rng), y: .random(in: 0.02...0.98, using: &rng),
                size: .random(in: 5...12, using: &rng), phase: .random(in: 0...6.28, using: &rng),
                speed: .random(in: 0.6...1.4, using: &rng), color: palette[i % palette.count]
            )
        }
    }()

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20, paused: reduceMotion)) { timeline in
            let t = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                for star in Self.stars {
                    let twinkle = reduceMotion ? 0.8 : 0.55 + 0.45 * sin(t * star.speed + star.phase)
                    let r = star.size / 2 * (0.75 + 0.25 * twinkle)
                    let c = CGPoint(x: star.x * size.width, y: star.y * size.height)
                    var path = Path()
                    path.move(to: CGPoint(x: c.x, y: c.y - r))
                    path.addQuadCurve(to: CGPoint(x: c.x + r, y: c.y), control: CGPoint(x: c.x + r * 0.18, y: c.y - r * 0.18))
                    path.addQuadCurve(to: CGPoint(x: c.x, y: c.y + r), control: CGPoint(x: c.x + r * 0.18, y: c.y + r * 0.18))
                    path.addQuadCurve(to: CGPoint(x: c.x - r, y: c.y), control: CGPoint(x: c.x - r * 0.18, y: c.y + r * 0.18))
                    path.addQuadCurve(to: CGPoint(x: c.x, y: c.y - r), control: CGPoint(x: c.x - r * 0.18, y: c.y - r * 0.18))
                    context.opacity = twinkle
                    context.fill(path, with: .color(star.color))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    init(seed: UInt64) { state = seed &+ 0x9E3779B97F4A7C15 }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

#Preview {
    GeoColor.bgCanvas.ignoresSafeArea().overlay { GeoStarfield() }
}
