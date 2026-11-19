import SwiftUI

/// Katmanlı avatar karakteri — 100x100 koordinat uzayı (Figma "Design System / 6. Avatar
/// Karakter Sistemi", node 555:12299'un devamı).
///
/// 2026-11-14 "profesyonel" yeniden çizim (kullanıcı: "elementleri ve yüz tipini de
/// profesyonelleştir, hatta 3D bile deneyebilirsin"): düz şekiller yerine tanıtım ekranındaki
/// kil dünya ile aynı dilde yumuşak hacim — her parça ışığı sol üstten alır (açık ton → ana renk →
/// koyu ton), kafada parlama, kulaklar, kaşlar, parlak gözler, allık, burun, boyun ve omuzlar.
/// Renkler yalnızca seçilen ten/saç rengi ile palet tonlarından türetilir.
///
/// Katmanlar (alttan üste): Gövde → Boyun → [Kafa grubu: Saç → Kulaklar → Kafa → Yüz →
/// Sakal → Bıyık → Çil → Gözlük → Küpe → Piercing → Şapka]. Saçın "kep" görünümü kasıtlı:
/// saç kafa dairesinin ALTINDA çizilir, opak kafa saçın yüzle çakışan kısmını gizler.
struct GeoAvatarCharacterView: View {
    var skinTone: SkinTone = .acik
    var hairStyle: HairStyle = .kisa
    var hairColor: Color = GeoColor.textPrimary
    /// Kullanıcı kararı: aynı anda yalnızca BİR aksesuar / BİR yüz detayı.
    var accessory: AvatarAccessory? = nil
    var facialFeature: AvatarFacialFeature? = nil
    /// Aksesuar/yüz detayı seçici önizlemelerinde saç gizlenir (öğe daha net görünsün).
    var showHair: Bool = true
    /// Omuzlardaki tişört rengi.
    var shirtColor: Color = GeoColor.bgSurface
    /// İfade (tanıtım videosu vb. için; varsayılanlarla avatar bugünkü hâliyle aynıdır).
    /// 0…1: kaşlar kalkar, gözler büyür, ağız "O" olur.
    var surprise: CGFloat = 0
    /// 0…1: konuşurken ağız açılır (gülüşün yerine açık ağız).
    var mouthOpen: CGFloat = 0
    /// Göz bebeklerinin bakış yönü (-1…1).
    var gaze: CGPoint = .zero

    private let darkLine = GeoColor.textPrimary
    private var skin: Color { skinTone.color }

    var body: some View {
        ZStack {
            torso
            neck
            headGroup
                // Gövdeye yer açmak için kafa biraz küçültülüp yukarıda tutulur.
                .scaleEffect(0.86, anchor: UnitPoint(x: 0.5, y: 0.3))
        }
        .frame(width: 100, height: 100)
    }

    private var headGroup: some View {
        ZStack {
            if showHair { hairLayer }
            ears
            head
            face
            if facialFeature == .sakal { beard }
            if facialFeature == .biyik { mustache }
            if facialFeature == .cil { freckles }
            if accessory == .gozluk { glasses }
            if accessory == .kupe { earring }
            if accessory == .piercing { nosePiercing }
            if accessory == .sapka { hat }
        }
        .frame(width: 100, height: 100)
    }

    // MARK: - Işık / hacim

    /// Sol üstten ışık alan kil dolgusu.
    private func clay(_ base: Color, light: CGFloat = 0.32, dark: CGFloat = 0.2) -> LinearGradient {
        LinearGradient(
            colors: [base.geoMixed(with: .white, by: light), base, base.geoMixed(with: .black, by: dark)],
            startPoint: UnitPoint(x: 0.25, y: 0.05), endPoint: UnitPoint(x: 0.75, y: 1)
        )
    }

    private func highlight(_ w: CGFloat, _ h: CGFloat, at x: CGFloat, _ y: CGFloat, opacity: Double = 0.4, rotation: Double = -20) -> some View {
        Ellipse()
            .fill(.white.opacity(opacity))
            .frame(width: w, height: h)
            .rotationEffect(.degrees(rotation))
            .blur(radius: min(w, h) * 0.18)
            .position(x: x, y: y)
    }

    // MARK: - Gövde

    private var torso: some View {
        ZStack {
            Path { p in
                p.move(to: CGPoint(x: 8, y: 112))
                p.addCurve(to: CGPoint(x: 34, y: 86), control1: CGPoint(x: 10, y: 96), control2: CGPoint(x: 20, y: 87))
                p.addLine(to: CGPoint(x: 66, y: 86))
                p.addCurve(to: CGPoint(x: 92, y: 112), control1: CGPoint(x: 80, y: 87), control2: CGPoint(x: 90, y: 96))
                p.closeSubpath()
            }
            .fill(clay(shirtColor, light: 0.1, dark: 0.12))
            // Yaka
            Path { p in
                p.move(to: CGPoint(x: 41, y: 86.5))
                p.addQuadCurve(to: CGPoint(x: 59, y: 86.5), control: CGPoint(x: 50, y: 96))
            }
            .stroke(shirtColor.geoMixed(with: .black, by: 0.18), style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
        }
    }

    private var neck: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(skin.geoMixed(with: .black, by: 0.08))
                .frame(width: 20, height: 16)
                .position(x: 50, y: 82)
            // Çene altı gölgesi
            Ellipse()
                .fill(skin.geoMixed(with: .black, by: 0.28).opacity(0.7))
                .frame(width: 20, height: 7)
                .blur(radius: 1.2)
                .position(x: 50, y: 77)
        }
    }

    // MARK: - Kafa

    private var ears: some View {
        ZStack {
            ForEach([16.5, 83.5], id: \.self) { x in
                Ellipse()
                    .fill(clay(skin, light: 0.2, dark: 0.18))
                    .frame(width: 13, height: 17)
                    .position(x: x, y: 58)
                Ellipse()
                    .fill(skin.geoMixed(with: .black, by: 0.18))
                    .frame(width: 6, height: 9)
                    .position(x: x + (x < 50 ? 1 : -1), y: 58)
            }
        }
    }

    private var head: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [skin.geoMixed(with: .white, by: 0.22), skin, skin.geoMixed(with: .black, by: 0.16)],
                    center: UnitPoint(x: 0.36, y: 0.3), startRadius: 2, endRadius: 52
                ))
                .frame(width: 70, height: 70)
                .position(x: 50, y: 55)
            highlight(22, 12, at: 36, 33, opacity: 0.35)
        }
    }

    private var face: some View {
        ZStack {
            // Kaşlar (saç renginde, biraz koyu)
            ForEach([-1.0, 1.0], id: \.self) { side in
                Path { p in
                    let cx = 50 + 12 * side
                    let lift = 4 * surprise
                    p.move(to: CGPoint(x: cx - 5.5, y: 42 - lift))
                    p.addQuadCurve(to: CGPoint(x: cx + 5.5, y: 42 - lift), control: CGPoint(x: cx, y: 38.8 - lift * 1.4))
                }
                .stroke(hairColor.geoMixed(with: .black, by: 0.15), style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
            }
            // Gözler: beyaz, iris, parlama (şaşırınca büyür; bakış yönüne kayar)
            ForEach([38.0, 62.0], id: \.self) { x in
                Ellipse()
                    .fill(.white)
                    .frame(width: 11 + 2.5 * surprise, height: 12 + 3.5 * surprise)
                    .overlay { Ellipse().strokeBorder(darkLine.opacity(0.12), lineWidth: 0.8) }
                    .position(x: x, y: 50.5)
                Circle()
                    .fill(RadialGradient(colors: [darkLine.geoMixed(with: .white, by: 0.25), darkLine], center: .bottom, startRadius: 0, endRadius: 5))
                    .frame(width: 7.5 - 1.2 * surprise, height: 7.5 - 1.2 * surprise)
                    .position(x: x + 0.6 + 2 * gaze.x, y: 51.5 + 1.6 * gaze.y)
                Circle().fill(.white).frame(width: 2.6, height: 2.6).position(x: x - 1.1 + 2 * gaze.x, y: 49.4 + 1.6 * gaze.y)
            }
            // Allık
            ForEach([31.0, 69.0], id: \.self) { x in
                Ellipse()
                    .fill(GeoColor.accentPrimarySoft.opacity(0.45))
                    .frame(width: 10, height: 6)
                    .blur(radius: 1.4)
                    .position(x: x, y: 61)
            }
            // Burun
            Capsule()
                .fill(skin.geoMixed(with: .black, by: 0.14))
                .frame(width: 6, height: 4.2)
                .position(x: 50, y: 58.5)
            Circle().fill(.white.opacity(0.35)).frame(width: 2, height: 2).position(x: 49, y: 57.6)
            if surprise > 0.5 {
                // Ağız: şaşkın "O"
                Ellipse()
                    .fill(darkLine)
                    .frame(width: 6 + 2 * surprise, height: 7 + 3 * surprise)
                    .overlay(alignment: .bottom) {
                        Ellipse().fill(GeoColor.accentPrimarySoft).frame(width: 4, height: 3).padding(.bottom, 1)
                    }
                    .position(x: 50, y: 67)
            } else if mouthOpen > 0.05 {
                // Ağız: konuşurken açık gülüş
                Path { p in
                    p.move(to: CGPoint(x: 43, y: 64.5))
                    p.addQuadCurve(to: CGPoint(x: 57, y: 64.5), control: CGPoint(x: 50, y: 66 + 9 * mouthOpen))
                    p.addQuadCurve(to: CGPoint(x: 43, y: 64.5), control: CGPoint(x: 50, y: 63.5))
                    p.closeSubpath()
                }
                .fill(darkLine)
            } else {
                // Ağız: hilal gülüş
                Path { p in
                    p.move(to: CGPoint(x: 42.5, y: 64.5))
                    p.addQuadCurve(to: CGPoint(x: 57.5, y: 64.5), control: CGPoint(x: 50, y: 73))
                    p.addQuadCurve(to: CGPoint(x: 42.5, y: 64.5), control: CGPoint(x: 50, y: 67.5))
                    p.closeSubpath()
                }
                .fill(darkLine)
                Path { p in
                    p.move(to: CGPoint(x: 42.5, y: 64.5))
                    p.addQuadCurve(to: CGPoint(x: 57.5, y: 64.5), control: CGPoint(x: 50, y: 73))
                }
                .stroke(darkLine, style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
            }
        }
    }

    // MARK: - Saç

    private var hairFill: LinearGradient { clay(hairColor, light: 0.3, dark: 0.28) }

    @ViewBuilder private var hairLayer: some View {
        ZStack {
            switch hairStyle {
            case .kisa:
                hairEllipse(50, 35, 78, 50)
            case .uzun:
                hairEllipse(50, 35, 78, 50)
                hairRect(20, 72.5, 16, 45, radius: 8)
                hairRect(80, 72.5, 16, 45, radius: 8)
            case .kivircik:
                hairEllipse(50, 39, 70, 42)
                ForEach([(27.0, 27.0), (38.0, 17.0), (50.0, 12.0), (62.0, 17.0), (73.0, 27.0)], id: \.0) { c in
                    hairEllipse(c.0, c.1, 18, 18)
                    highlight(6, 4, at: c.0 - 3, c.1 - 3.5, opacity: 0.3)
                }
            case .atKuyrugu:
                hairEllipse(82, 58, 16, 30, rotation: -20)
                hairEllipse(50, 35, 78, 50)
            case .topuz:
                hairEllipse(50, 8, 24, 24)
                highlight(8, 5, at: 45, 4, opacity: 0.35)
                hairEllipse(50, 33, 72, 34)
            }
            // Saç parlaması (ışık sol üstten)
            if hairStyle != .kivircik {
                Path { p in
                    p.move(to: CGPoint(x: 27, y: 27))
                    p.addQuadCurve(to: CGPoint(x: 47, y: 15), control: CGPoint(x: 33, y: 17))
                }
                .stroke(.white.opacity(0.3), style: StrokeStyle(lineWidth: 3.2, lineCap: .round))
                .blur(radius: 0.6)
            }
        }
    }

    private func hairEllipse(_ cx: CGFloat, _ cy: CGFloat, _ w: CGFloat, _ h: CGFloat, rotation: Double = 0) -> some View {
        Ellipse()
            .fill(hairFill)
            .frame(width: w, height: h)
            .rotationEffect(.degrees(rotation))
            .position(x: cx, y: cy)
    }

    private func hairRect(_ cx: CGFloat, _ cy: CGFloat, _ w: CGFloat, _ h: CGFloat, radius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(hairFill)
            .frame(width: w, height: h)
            .position(x: cx, y: cy)
    }

    // MARK: - Yüz detayları

    private var beard: some View {
        Path { p in
            p.move(to: CGPoint(x: 20.5, y: 62))
            p.addQuadCurve(to: CGPoint(x: 50, y: 95), control: CGPoint(x: 22, y: 93))
            p.addQuadCurve(to: CGPoint(x: 79.5, y: 62), control: CGPoint(x: 78, y: 93))
            p.addQuadCurve(to: CGPoint(x: 62, y: 73.5), control: CGPoint(x: 73, y: 73))
            p.addQuadCurve(to: CGPoint(x: 38, y: 73.5), control: CGPoint(x: 50, y: 79))
            p.addQuadCurve(to: CGPoint(x: 20.5, y: 62), control: CGPoint(x: 27, y: 73))
            p.closeSubpath()
        }
        .fill(hairFill)
    }

    private var mustache: some View {
        ZStack {
            ForEach([-1.0, 1.0], id: \.self) { side in
                Path { p in
                    p.move(to: CGPoint(x: 50, y: 61))
                    p.addQuadCurve(to: CGPoint(x: 50 + 12 * side, y: 64.5), control: CGPoint(x: 50 + 7 * side, y: 57.5))
                    p.addQuadCurve(to: CGPoint(x: 50, y: 63.6), control: CGPoint(x: 50 + 6 * side, y: 65))
                    p.closeSubpath()
                }
                .fill(hairFill)
            }
        }
    }

    private var freckles: some View {
        let freckleColor = skin.geoMixed(with: Color(hex: 0x8A4A2B), by: 0.55)
        let points: [(CGFloat, CGFloat, CGFloat)] = [
            (31.5, 58.5, 2.6), (35.5, 62, 2.2), (29.5, 63, 2),
            (68.5, 58.5, 2.6), (64.5, 62, 2.2), (70.5, 63, 2),
        ]
        return ZStack {
            ForEach(points.indices, id: \.self) { i in
                Circle().fill(freckleColor.opacity(0.85)).frame(width: points[i].2, height: points[i].2).position(x: points[i].0, y: points[i].1)
            }
        }
    }

    // MARK: - Aksesuar

    private var hat: some View {
        let khaki = Color(hex: 0xBF9452)
        return ZStack {
            Ellipse().fill(clay(khaki, light: 0.25, dark: 0.25)).frame(width: 70, height: 17).position(x: 50, y: 29)
            Path { p in
                p.move(to: CGPoint(x: 28, y: 28))
                p.addCurve(to: CGPoint(x: 72, y: 28), control1: CGPoint(x: 28, y: 0), control2: CGPoint(x: 72, y: 0))
                p.closeSubpath()
            }
            .fill(clay(khaki, light: 0.3, dark: 0.2))
            Path { p in
                p.move(to: CGPoint(x: 29, y: 25.5))
                p.addQuadCurve(to: CGPoint(x: 71, y: 25.5), control: CGPoint(x: 50, y: 19.5))
            }
            .stroke(khaki.geoMixed(with: .black, by: 0.4), style: StrokeStyle(lineWidth: 4.5, lineCap: .round))
            // Geonaut amblemi: bant üzerinde küçük altın küre
            Circle()
                .fill(clay(GeoColor.accentHighlight, light: 0.3, dark: 0.25))
                .frame(width: 7, height: 7)
                .overlay { Circle().strokeBorder(GeoColor.accentHighlightStrong, lineWidth: 0.8) }
                .position(x: 50, y: 22.6)
            highlight(16, 6, at: 40, 12, opacity: 0.35)
        }
    }

    private var glasses: some View {
        ZStack {
            // Saplar
            Path { p in
                p.move(to: CGPoint(x: 28, y: 49)); p.addLine(to: CGPoint(x: 18, y: 52))
                p.move(to: CGPoint(x: 72, y: 49)); p.addLine(to: CGPoint(x: 82, y: 52))
            }
            .stroke(darkLine, style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
            ForEach([38.0, 62.0], id: \.self) { x in
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 20, height: 20)
                    .overlay { Circle().strokeBorder(darkLine, lineWidth: 2.6) }
                    .overlay {
                        // Cam parlaması
                        Path { p in
                            p.move(to: CGPoint(x: 5, y: 9)); p.addLine(to: CGPoint(x: 9, y: 5))
                        }
                        .stroke(.white.opacity(0.75), style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
                        .frame(width: 20, height: 20)
                    }
                    .position(x: x, y: 50)
            }
            Path { p in
                p.move(to: CGPoint(x: 47.5, y: 49.5))
                p.addQuadCurve(to: CGPoint(x: 52.5, y: 49.5), control: CGPoint(x: 50, y: 47))
            }
            .stroke(darkLine, style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
        }
    }

    private var earring: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [GeoColor.accentHighlight.geoMixed(with: .white, by: 0.4), GeoColor.accentHighlight, GeoColor.accentHighlightStrong], center: UnitPoint(x: 0.35, y: 0.3), startRadius: 0, endRadius: 5))
                .frame(width: 7.5, height: 7.5)
                .position(x: 84, y: 67.5)
            Circle().fill(.white.opacity(0.9)).frame(width: 2, height: 2).position(x: 82.8, y: 66.3)
        }
    }

    private var nosePiercing: some View {
        Circle()
            .trim(from: 0.1, to: 0.9)
            .stroke(
                LinearGradient(colors: [.white, GeoColor.iconInactive, GeoColor.textMuted], startPoint: .topLeading, endPoint: .bottomTrailing),
                style: StrokeStyle(lineWidth: 1.8, lineCap: .round)
            )
            .rotationEffect(.degrees(90))
            .frame(width: 5.5, height: 5.5)
            .position(x: 54.2, y: 60.6)
    }
}

extension Color {
    /// İki rengi doğrusal karıştırır (0 = kendisi, 1 = diğeri) — avatarın açık/koyu tonları için.
    func geoMixed(with other: Color, by amount: CGFloat) -> Color {
        let a = UIColor(self), b = UIColor(other)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        a.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        b.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let t = max(0, min(amount, 1))
        return Color(red: r1 + (r2 - r1) * t, green: g1 + (g2 - g1) * t, blue: b1 + (b2 - b1) * t, opacity: a1 + (a2 - a1) * t)
    }
}

#Preview {
    VStack(spacing: GeoSpacing.lg) {
        HStack(spacing: GeoSpacing.md) {
            GeoAvatarCharacterView(skinTone: .acik, hairStyle: .kisa, hairColor: GeoColor.textPrimary)
            GeoAvatarCharacterView(skinTone: .bugday, hairStyle: .uzun, hairColor: GeoColor.accentHighlightStrong)
            GeoAvatarCharacterView(skinTone: .esmer, hairStyle: .kivircik, hairColor: GeoColor.accentDanger)
            GeoAvatarCharacterView(skinTone: .siyahi, hairStyle: .atKuyrugu, hairColor: GeoColor.accentTertiaryStrong)
        }
        HStack(spacing: GeoSpacing.md) {
            GeoAvatarCharacterView(skinTone: .bugday, hairStyle: .topuz, hairColor: GeoColor.accentSuccessStrong, accessory: .sapka, facialFeature: .sakal)
            GeoAvatarCharacterView(skinTone: .acik, hairStyle: .kisa, hairColor: GeoColor.accentDanger, accessory: .gozluk, facialFeature: .biyik)
            GeoAvatarCharacterView(skinTone: .esmer, hairStyle: .uzun, hairColor: GeoColor.accentHighlightStrong, accessory: .kupe, facialFeature: .cil)
        }
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
