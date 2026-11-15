import SwiftUI

/// Geonaut ikon dili (emoji yerine): Ana Sayfa'daki kategori kartlarıyla aynı — palet renginde
/// yuvarlak bir zemin ve üstünde SF Symbol. Simgenin rengi zemine göre seçilir: açık tonlarda
/// o rengin koyu eşi (ör. gök mavisi zeminde koyu mavi), koyu/doygun tonlarda beyaz.
/// Kullanıcı kararı (2026-11-13): emojiler profesyonel durmuyor, yerlerine uygulamaya özgü ikonlar.
enum GeoGlyph {
    /// Verilen palet zemininde simgenin rengi (bkz. GeoCategoryCard'daki iconTintColor eşleri).
    static func ink(on background: Color) -> Color {
        switch background {
        case GeoColor.accentSuccess: GeoColor.accentSuccessStrong
        case GeoColor.accentInfo: GeoColor.accentInfoStrong
        case GeoColor.accentTertiary: GeoColor.accentTertiaryStrong
        case GeoColor.accentHighlight: GeoColor.accentHighlightStrong
        case GeoColor.textPrimary: GeoColor.accentHighlight
        case GeoColor.bgSurface, GeoColor.bgCanvas, GeoColor.bgLocked: GeoColor.textSecondary
        default: .white
        }
    }
}

/// Palet renginde daire + SF Symbol. Kilitliyken gri zemin ve soluk simge.
struct GeoGlyphCircle: View {
    let symbol: String
    var background: Color
    var size: CGFloat = 40
    var locked = false

    var body: some View {
        Circle()
            .fill(locked ? GeoColor.bgLocked : background)
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: symbol)
                    .font(.system(size: size * 0.44, weight: .bold))
                    .foregroundStyle(locked ? GeoColor.textMuted.opacity(0.6) : GeoGlyph.ink(on: background))
            }
            .accessibilityHidden(true)
    }
}

/// Mutsuz Geonaut yüzü — maskotun çizgisiyle (iki nokta göz + ters gülüş), emoji yerine.
struct GeoSadFace: View {
    var size: CGFloat = 120
    var background: Color = GeoColor.accentTertiary

    var body: some View {
        Circle()
            .fill(background)
            .frame(width: size, height: size)
            .overlay {
                let s = size / 120
                ZStack {
                    HStack(spacing: 26 * s) {
                        Circle().frame(width: 11 * s, height: 11 * s)
                        Circle().frame(width: 11 * s, height: 11 * s)
                    }
                    .offset(y: -8 * s)
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: 12 * s))
                        p.addQuadCurve(to: CGPoint(x: 30 * s, y: 12 * s), control: CGPoint(x: 15 * s, y: 0))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 4.5 * s, lineCap: .round))
                    .frame(width: 30 * s, height: 12 * s)
                    .offset(y: 18 * s)
                }
                .foregroundStyle(GeoColor.textPrimary)
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: GeoSpacing.md) {
        GeoGlyphCircle(symbol: "building.columns.fill", background: GeoColor.accentPrimary)
        GeoGlyphCircle(symbol: "mountain.2.fill", background: GeoColor.accentSuccess)
        GeoGlyphCircle(symbol: "trophy.fill", background: GeoColor.textPrimary)
        GeoGlyphCircle(symbol: "snowflake", background: GeoColor.accentInfo, locked: true)
        GeoSadFace(size: 60)
    }
    .padding()
    .background(GeoColor.bgCanvas)
}

/// Rozet/kupa madalyası — "premium" görünüm (kullanıcı isteği 2026-11-14):
/// metalik açısal kenar, parlak (gloss) yüzey, oyulmuş iç halka, kabartma ikon ve birkaç
/// saniyede bir üstünden kayan ışık. Kategori "Usta" kupaları (mürekkep zemin) altın kenar ve
/// defne dallarıyla ayrışır. Yalnızca palet renkleri. Kilitliyken mat gri, kesik çizgili kenar.
struct GeoMedal: View {
    let symbol: String
    var color: Color
    var size: CGFloat = 56
    var locked = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isTrophy: Bool { color == GeoColor.textPrimary }
    private var ink: Color { GeoGlyph.ink(on: color) }
    /// Işığın her madalyada farklı anda geçmesi için sabit (simgeye bağlı) gecikme.
    private var seed: Double { Double(symbol.unicodeScalars.reduce(0) { $0 + Int($1.value) } % 97) / 97 }

    var body: some View {
        ZStack {
            if locked {
                lockedFace
            } else {
                Circle().fill(rim)
                face
                    .padding(size * 0.075)
            }
        }
        .frame(width: size, height: size)
        .shadow(color: locked ? .clear : (isTrophy ? GeoColor.accentHighlightStrong : ink).opacity(0.35), radius: size * 0.09, x: 0, y: size * 0.07)
        .accessibilityHidden(true)
    }

    // MARK: Parçalar

    private var rim: AngularGradient {
        let colors: [Color] = isTrophy
            ? [GeoColor.accentHighlight, GeoColor.accentHighlightStrong, .white, GeoColor.accentHighlight, GeoColor.accentHighlightStrong, GeoColor.accentHighlight, .white, GeoColor.accentHighlight]
            : [.white, color, ink, color, .white, color, ink, color, .white]
        return AngularGradient(colors: colors, center: .center, angle: .degrees(-35))
    }

    private var face: some View {
        ZStack {
            Circle().fill(color)
            // Alt kısımda hafif derinlik, üstte parlak cam yansıması.
            Circle().fill(LinearGradient(colors: [.clear, .black.opacity(isTrophy ? 0.25 : 0.10)], startPoint: .center, endPoint: .bottom))
            Ellipse()
                .fill(LinearGradient(colors: [.white.opacity(isTrophy ? 0.18 : 0.42), .white.opacity(0)], startPoint: .top, endPoint: .bottom))
                .frame(width: size * 0.7, height: size * 0.42)
                .offset(y: -size * 0.2)
            // Oyulmuş iç halka.
            Circle()
                .strokeBorder(isTrophy ? GeoColor.accentHighlight.opacity(0.55) : .white.opacity(0.5),
                              style: StrokeStyle(lineWidth: max(1, size * 0.018), dash: isTrophy ? [] : [size * 0.035, size * 0.03]))
                .padding(size * 0.065)
            icon
            shine
        }
        .clipShape(Circle())
    }

    @ViewBuilder
    private var icon: some View {
        if isTrophy {
            HStack(spacing: -size * 0.03) {
                Image(systemName: "laurel.leading")
                    .font(.system(size: size * 0.3, weight: .semibold))
                Image(systemName: symbol)
                    .font(.system(size: size * 0.32, weight: .bold))
                Image(systemName: "laurel.trailing")
                    .font(.system(size: size * 0.3, weight: .semibold))
            }
            .foregroundStyle(LinearGradient(colors: [GeoColor.accentHighlight, GeoColor.accentHighlightStrong], startPoint: .top, endPoint: .bottom))
            .shadow(color: .black.opacity(0.35), radius: 0, x: 0, y: size * 0.02)
        } else {
            Image(systemName: symbol)
                .font(.system(size: size * 0.38, weight: .bold))
                .foregroundStyle(ink)
                // Kabartma: altta koyu, üstte açık ince gölge.
                .shadow(color: .black.opacity(0.18), radius: 0, x: 0, y: size * 0.022)
                .shadow(color: .white.opacity(0.35), radius: 0, x: 0, y: -size * 0.012)
        }
    }

    /// Birkaç saniyede bir yüzeyden çapraz kayan ışık şeridi.
    private var shine: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30, paused: reduceMotion)) { context in
            let period = 4.2
            let t = reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate + seed * period
            let phase = t.truncatingRemainder(dividingBy: period) / period // 0...1
            let sweep = min(phase / 0.3, 1) // ilk %30'da geçer, kalan sürede bekler
            Rectangle()
                .fill(LinearGradient(colors: [.clear, .white.opacity(isTrophy ? 0.45 : 0.6), .clear], startPoint: .leading, endPoint: .trailing))
                .frame(width: size * 0.32, height: size * 1.6)
                .rotationEffect(.degrees(25))
                .offset(x: -size * 0.9 + sweep * size * 1.8)
                .opacity(reduceMotion ? 0 : 1)
                .blendMode(.plusLighter)
        }
        .allowsHitTesting(false)
    }

    private var lockedFace: some View {
        ZStack {
            Circle().fill(GeoColor.bgLocked)
            Circle()
                .strokeBorder(GeoColor.iconInactive, style: StrokeStyle(lineWidth: max(1.2, size * 0.025), dash: [size * 0.05, size * 0.04]))
                .padding(size * 0.06)
            Image(systemName: symbol)
                .font(.system(size: size * 0.36, weight: .bold))
                .foregroundStyle(GeoColor.textMuted.opacity(0.5))
        }
    }
}

#Preview("Madalyalar") {
    HStack(spacing: GeoSpacing.lg) {
        GeoMedal(symbol: "building.columns.fill", color: GeoColor.accentPrimary)
        GeoMedal(symbol: "mountain.2.fill", color: GeoColor.accentSuccess)
        GeoMedal(symbol: "trophy.fill", color: GeoColor.textPrimary)
        GeoMedal(symbol: "snowflake", color: GeoColor.accentInfo, locked: true)
    }
    .padding()
    .background(GeoColor.bgCanvas)
}
