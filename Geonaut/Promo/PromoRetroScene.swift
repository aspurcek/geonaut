#if DEBUG
import SwiftUI

/// Retro (Y2K / eski masaüstü) tanıtım videosu, 9:16, tüm metinler İngilizce (kullanıcı kararı) — kullanıcı isteği 2026-11-23: verilen referans
/// görselin tarzında (mavi gökyüzü, çimen, piksel "PLAY" yazıları, eski pencereler, yükleme çubuğu),
/// arkada sürekli dönen dünya, önde Geonaut ekranlarını gösteren telefon. Pencere/ikon çizimleri
/// genel "eski masaüstü" görünümünde ve özgündür; hiçbir işletim sistemi/tarayıcı logosu kullanılmaz
/// (referanstaki tarayıcı logosunun yerinde dünyanın üstünde Geonaut maskotu oturur).
/// Sahne `t` saniyesine göre tamamen belirlenir; `PromoVideoExporter` 1080×1920 MP4 yazar.
struct PromoRetroScene: View {
    let t: Double
    static let duration: Double = 19
    static let size = CGSize(width: 360, height: 640)
    /// Telefon ekranında gösterilen görüntüler (Mac'teki klasör; simülatör doğrudan okur).
    static let assetFolder = "/Users/aspurce/kaşif/Geonaut-Retro/assets/"

    private let horizon: CGFloat = 415

    // MARK: Zaman yardımcıları

    private func p(_ a: Double, _ b: Double) -> Double { min(max((t - a) / (b - a), 0), 1) }
    private func ease(_ x: Double) -> Double { x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2 }
    private func pop(_ start: Double, _ end: Double) -> Double {
        // Açılış: hızlı büyüme + küçük taşma; kapanış: hızlı küçülme.
        let open = p(start, start + 0.28), close = p(end - 0.18, end)
        guard t >= start, t <= end else { return 0 }
        let o = open < 1 ? 1 - pow(1 - open, 3) * cos(open * 7) : 1
        return max(0, o * (1 - close))
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            sky
            playColumn
            clock
            globe
            grass
            pixelIcons
            phone
            setupDialog
            featureWindows
            loadingDialog
            finalWindow
            cursor
            scanlines
            glitchBands
        }
        .frame(width: Self.size.width, height: Self.size.height, alignment: .topLeading)
        .clipped()
    }

    // MARK: - Gökyüzü, PLAY, saat

    private var sky: some View {
        LinearGradient(colors: [Color(hex: 0x2742C9), Color(hex: 0x3557DD), Color(hex: 0x4A6FE6)], startPoint: .top, endPoint: .bottom)
            .frame(width: Self.size.width, height: horizon + 10)
    }

    private var playColumn: some View {
        let lineHeight: CGFloat = 64
        let scroll = CGFloat(t * 26).truncatingRemainder(dividingBy: lineHeight)
        return VStack(alignment: .leading, spacing: 0) {
            ForEach(0..<9, id: \.self) { _ in
                PixelLabel(text: "PLAY", fontSize: 9, pixel: 4.6, color: Color(hex: 0xEEF3FF), chroma: 2.2)
                    .frame(height: lineHeight, alignment: .center)
            }
        }
        .offset(x: 16, y: -scroll - 6)
        .frame(width: 140, height: horizon - 4, alignment: .top)
        .clipped()
        .opacity(0.95)
    }

    private var clock: some View {
        let blink = Int(t * 2) % 2 == 0
        return PixelLabel(text: "--:--", fontSize: 8, pixel: 3.2, color: Color(hex: 0xD8E6FF), chroma: 1.6)
            .opacity(blink ? 1 : 0.35)
            .offset(x: 248, y: 62)
    }

    // MARK: - Dünya + maskot

    private var globe: some View {
        let d: CGFloat = 300
        let angle = t / 13 * 2 * .pi
        return ZStack {
            Circle()
                .fill(Color(hex: 0xBFE3FF).opacity(0.55))
                .frame(width: d * 1.06, height: d * 1.06)
                .blur(radius: 10)
            if let image = RetroEarth.shared.frame(angle: angle) {
                Image(decorative: image, scale: 1)
                    .resizable()
                    .interpolation(.medium)
                    .frame(width: d, height: d)
            }
            Image("Mascot")
                .resizable()
                .scaledToFit()
                .frame(width: 66)
                .rotationEffect(.degrees(-12 + sin(t * 2.4) * 4))
                .offset(x: -d * 0.3, y: -d * 0.43 + CGFloat(sin(t * 3)) * 3)
        }
        .frame(width: d * 1.1, height: d * 1.1)
        .position(x: 302, y: 350)
    }

    // MARK: - Çimen

    private var grass: some View {
        Canvas { ctx, size in
            let top = horizon
            ctx.fill(Path(CGRect(x: 0, y: top, width: size.width, height: size.height - top)),
                     with: .linearGradient(Gradient(colors: [Color(hex: 0x7BD23A), Color(hex: 0x49AE24), Color(hex: 0x2F8E17)]),
                                           startPoint: CGPoint(x: 0, y: top), endPoint: CGPoint(x: 0, y: size.height)))
            for blade in RetroGrass.blades {
                let y = top + blade.depth * (size.height - top)
                let scale = 0.6 + blade.depth * 1.1
                let sway = CGFloat(sin(t * 2.2 + Double(blade.x) * 0.06)) * 1.4 * scale
                var path = Path()
                path.move(to: CGPoint(x: blade.x - 1.1 * scale, y: y))
                path.addQuadCurve(to: CGPoint(x: blade.x + sway + blade.lean * scale, y: y - blade.height * scale),
                                  control: CGPoint(x: blade.x, y: y - blade.height * scale * 0.5))
                path.addQuadCurve(to: CGPoint(x: blade.x + 1.1 * scale, y: y),
                                  control: CGPoint(x: blade.x + 0.4, y: y - blade.height * scale * 0.45))
                ctx.fill(path, with: .color(blade.color))
            }
            // Ufuk pusu
            ctx.fill(Path(CGRect(x: 0, y: top - 4, width: size.width, height: 10)),
                     with: .linearGradient(Gradient(colors: [.white.opacity(0), .white.opacity(0.55), .white.opacity(0)]),
                                           startPoint: CGPoint(x: 0, y: top - 4), endPoint: CGPoint(x: 0, y: top + 6)))
        }
        .frame(width: Self.size.width, height: Self.size.height)
    }

    private var pixelIcons: some View {
        ZStack(alignment: .topLeading) {
            PixelSymbol(name: "globe.europe.africa.fill", pointSize: 15, pixel: 3.4, colors: [Color(hex: 0x37A24A), Color(hex: 0x2D6FD8)])
                .offset(x: 0, y: 0)
            PixelSymbol(name: "desktopcomputer", pointSize: 13, pixel: 3.4, colors: [Color(hex: 0x9FB3C8), Color(hex: 0x6FE3FF)])
                .offset(x: 30, y: 8)
            PixelSymbol(name: "desktopcomputer", pointSize: 13, pixel: 3.4, colors: [Color(hex: 0x9FB3C8), Color(hex: 0x6FE3FF)])
                .offset(x: 8, y: 40)
        }
        .offset(x: 8, y: 548)
    }

    // MARK: - Telefon

    private struct Shot { let file: String; let start: Double }
    private let shots: [Shot] = [
        Shot(file: "en_home.png", start: 0),
        Shot(file: "en_typed_empty.png", start: 4.0),
        Shot(file: "en_typed_messi.png", start: 6.4),
        Shot(file: "en_capital.png", start: 8.8),
        Shot(file: "en_duel.png", start: 11.2),
        Shot(file: "en_badges.png", start: 13.6)
    ]

    private var phone: some View {
        let w: CGFloat = 172, h: CGFloat = 172 * 2.17
        let index = shots.lastIndex { t >= $0.start } ?? 0
        let since = t - shots[index].start
        let transition = index > 0 ? 1 - p(shots[index].start, shots[index].start + 0.3) : 0
        let jitter = transition > 0 ? CGFloat(sin(t * 90)) * 6 * transition : 0
        let enter = ease(p(0.2, 1.1))
        return ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(hex: 0x15171F))
                .frame(width: w, height: h)
                .shadow(color: .black.opacity(0.45), radius: 16, x: 6, y: 14)
            ZStack {
                if let image = RetroAssets.image(shots[index].file) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .offset(x: jitter + CGFloat(transition) * 40, y: since < 0 ? 0 : 0)
                }
                if transition > 0 {
                    // Ekran geçişinde kısa RGB kayması
                    Color(hex: 0xFF3DD8).opacity(0.18 * transition).blendMode(.screen)
                }
            }
            .frame(width: w - 10, height: h - 10)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            Capsule().fill(.black).frame(width: 52, height: 15).offset(y: -h / 2 + 17)
        }
        .rotationEffect(.degrees(-3))
        .position(x: 170, y: 446 + (1 - enter) * 420 + ease(p(16.0, 16.6)) * 460)
    }

    // MARK: - Pencereler

    private var setupDialog: some View {
        let s = pop(0.5, 3.85)
        let pressed = t > 3.45 && t < 3.8
        return RetroWindow(title: "Geonaut Setup", width: 186) {
            VStack(spacing: 9) {
                HStack(alignment: .top, spacing: 9) {
                    PixelSymbol(name: "desktopcomputer", pointSize: 12, pixel: 2.6, colors: [Color(hex: 0x7F8A99), Color(hex: 0x3BA7FF)])
                    Text(verbatim: "Your geography is a little rusty.")
                        .font(.system(size: 9.5, weight: .medium))
                        .foregroundStyle(.black)
                        .fixedSize(horizontal: false, vertical: true)
                }
                RetroButton(title: "So what?", pressed: pressed, focused: true)
            }
        }
        .scaleEffect(s, anchor: .center)
        .opacity(s > 0 ? 1 : 0)
        .position(x: 112, y: 92)
    }

    private struct Feature { let title: String; let text: String; let symbol: String; let start: Double; let end: Double }
    private let features: [Feature] = [
        Feature(title: "flags.exe", text: "Know the flags of 248 countries", symbol: "flag.fill", start: 4.1, end: 6.3),
        Feature(title: "type.exe", text: "Messi is not a country", symbol: "keyboard", start: 6.5, end: 8.7),
        Feature(title: "capitals.exe", text: "Learn every capital", symbol: "building.columns.fill", start: 8.9, end: 11.1),
        Feature(title: "duel.exe", text: "Duel your friends", symbol: "person.2.fill", start: 11.3, end: 13.5),
        Feature(title: "trophy.exe", text: "Collect badges and trophies", symbol: "trophy.fill", start: 13.7, end: 16.0)
    ]

    private var featureWindows: some View {
        ZStack {
            ForEach(features.indices, id: \.self) { i in
                let f = features[i]
                let s = pop(f.start, f.end)
                if s > 0 {
                    RetroWindow(title: f.title, width: 168) {
                        HStack(spacing: 8) {
                            Image(systemName: f.symbol)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color(hex: 0x10208A))
                                .frame(width: 22)
                            Text(verbatim: f.text)
                                .font(.system(size: 10.5, weight: .bold))
                                .foregroundStyle(.black)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                            if f.title == "type.exe" {
                                Image(systemName: "xmark.square.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(Color(hex: 0xD2352B))
                            }
                        }
                    }
                    .scaleEffect(s)
                    .position(x: i.isMultiple(of: 2) ? 262 : 250, y: i.isMultiple(of: 2) ? 150 : 162)
                }
            }
        }
        .frame(width: Self.size.width, height: Self.size.height)
    }

    private var loadingDialog: some View {
        let s = pop(1.0, 30)
        let progress = p(1.2, 16.0)
        let done = progress >= 1
        return RetroWindow(title: "", width: 132, closeOnly: true) {
            VStack(spacing: 6) {
                Text(verbatim: done ? "Complete" : "Loading the world…")
                    .font(.system(size: 8.5, weight: .medium))
                    .foregroundStyle(.black)
                RetroProgress(progress: progress)
                HStack(spacing: 6) {
                    RetroButton(title: "Done", pressed: false, focused: false, disabled: !done, small: true)
                    RetroButton(title: "Cancel", pressed: false, focused: true, small: true)
                }
            }
        }
        .scaleEffect(s)
        .position(x: 288, y: 590)
    }

    private var finalWindow: some View {
        let s = pop(16.3, 40)
        let pressed = t > 17.6 && t < 17.9
        return RetroWindow(title: "Geonaut", width: 250) {
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Image("Mascot").resizable().scaledToFit().frame(width: 52)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(verbatim: "Geonaut installed!")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(.black)
                        Text(verbatim: "Flags, capitals, languages and food. Duel your friends.")
                            .font(.system(size: 9.5, weight: .medium))
                            .foregroundStyle(Color(hex: 0x222222))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                RetroButton(title: "Play", pressed: pressed, focused: true)
            }
        }
        .scaleEffect(s)
        .position(x: 180, y: 300)
        .overlay {
            if s > 0.5 {
                VStack(spacing: 6) {
                    PixelLabel(text: "FREE ON THE", fontSize: 8, pixel: 2.6, color: .white, chroma: 1.4)
                    PixelLabel(text: "APP STORE", fontSize: 8, pixel: 3.6, color: Color(hex: 0xFFF27A), chroma: 1.8)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(Color(hex: 0x0A1A86))
                .overlay(Bevel())
                .background(Rectangle().fill(.black.opacity(0.35)).offset(x: 3, y: 3))
                .scaleEffect(0.8 + 0.2 * p(16.8, 17.1))
                .opacity(p(16.8, 17.1))
                .position(x: 180, y: 452)
            }
        }
    }

    // MARK: - İmleç

    private var cursor: some View {
        // (zaman, x, y) anahtar kareleri — imlecin ucu.
        let keys: [(Double, CGFloat, CGFloat)] = [
            (0, 330, 640), (1.2, 300, 470), (3.2, 128, 128), (3.85, 128, 128),
            (5.3, 175, 520), (6.4, 170, 515), (8.6, 300, 190), (11.0, 230, 420),
            (13.6, 270, 160), (15.8, 186, 349), (19, 186, 349)
        ]
        var x = keys[0].1, y = keys[0].2
        for i in 0..<(keys.count - 1) where t >= keys[i].0 {
            let k = ease(p(keys[i].0, keys[i + 1].0))
            x = keys[i].1 + (keys[i + 1].1 - keys[i].1) * k
            y = keys[i].2 + (keys[i + 1].2 - keys[i].2) * k
        }
        let clicking = (t > 3.45 && t < 3.75) || (t > 6.2 && t < 6.45) || (t > 17.6 && t < 17.9)
        return PixelCursor()
            .scaleEffect(clicking ? 0.85 : 1, anchor: .topLeading)
            .position(x: x + 9, y: y + 13)
    }

    // MARK: - CRT efektleri

    private var scanlines: some View {
        Canvas { ctx, size in
            var y: CGFloat = 0
            while y < size.height {
                ctx.fill(Path(CGRect(x: 0, y: y, width: size.width, height: 1)), with: .color(.black.opacity(0.07)))
                y += 3
            }
        }
        .frame(width: Self.size.width, height: Self.size.height)
        .allowsHitTesting(false)
    }

    private var glitchBands: some View {
        let moments: [Double] = [0.05, 3.82, 8.8, 13.6, 16.25]
        let active = moments.first { t >= $0 && t < $0 + 0.22 }
        return Canvas { ctx, size in
            guard let start = active else { return }
            let seed = Int((t - start) * 30)
            for i in 0..<5 {
                let y = CGFloat((i * 137 + seed * 61) % Int(size.height))
                let h = CGFloat(4 + (i * 13 + seed * 7) % 14)
                ctx.fill(Path(CGRect(x: 0, y: y, width: size.width, height: h)),
                         with: .color(i.isMultiple(of: 2) ? Color(hex: 0x6FE3FF).opacity(0.35) : Color(hex: 0xFF4FD8).opacity(0.3)))
            }
        }
        .frame(width: Self.size.width, height: Self.size.height)
    }
}

// MARK: - Eski masaüstü bileşenleri

private struct Bevel: View {
    var raised = true
    var body: some View {
        GeometryReader { g in
            let w = g.size.width, h = g.size.height
            let light = raised ? Color.white : Color(hex: 0x404040)
            let dark = raised ? Color(hex: 0x404040) : Color.white
            Path { p in p.move(to: CGPoint(x: 0.5, y: h)); p.addLine(to: CGPoint(x: 0.5, y: 0.5)); p.addLine(to: CGPoint(x: w, y: 0.5)) }
                .stroke(light, lineWidth: 1)
            Path { p in p.move(to: CGPoint(x: w - 0.5, y: 0)); p.addLine(to: CGPoint(x: w - 0.5, y: h - 0.5)); p.addLine(to: CGPoint(x: 0, y: h - 0.5)) }
                .stroke(dark, lineWidth: 1)
        }
    }
}

private struct RetroWindow<Content: View>: View {
    let title: String
    var width: CGFloat
    var closeOnly = false
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                Text(verbatim: title)
                    .font(.system(size: 8.5, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Spacer(minLength: 0)
                ZStack {
                    Color(hex: 0xC0C0C0)
                    Bevel()
                    Image(systemName: "xmark")
                        .font(.system(size: 6, weight: .black))
                        .foregroundStyle(.black)
                }
                .frame(width: 12, height: 10)
            }
            .padding(.horizontal, 3)
            .frame(height: 14)
            .background(LinearGradient(colors: [Color(hex: 0x0A1A86), Color(hex: 0x1C84D6)], startPoint: .leading, endPoint: .trailing))
            content
                .padding(.horizontal, 9)
                .padding(.vertical, 9)
        }
        .padding(2)
        .frame(width: width)
        .background(Color(hex: 0xC0C0C0))
        .overlay(Bevel())
        // Sert gölge ayrı bir dikdörtgen: .shadow tüm alt katmanlara (yazılara) gölge düşürüp çift görüntü yapıyordu.
        .background(Rectangle().fill(.black.opacity(0.35)).offset(x: 3, y: 3))
    }
}

private struct RetroButton: View {
    let title: String
    var pressed: Bool
    var focused: Bool
    var disabled = false
    var small = false

    var body: some View {
        Text(verbatim: title)
            .font(.system(size: small ? 8 : 9.5, weight: .medium))
            .foregroundStyle(disabled ? Color(hex: 0x808080) : .black)
            .frame(width: small ? 48 : 84, height: small ? 15 : 20)
            .background(Color(hex: 0xC0C0C0))
            .overlay(Bevel(raised: !pressed))
            .overlay {
                if focused { Rectangle().stroke(.black, lineWidth: 1).padding(-1) }
            }
            .offset(x: pressed ? 1 : 0, y: pressed ? 1 : 0)
    }
}

private struct RetroProgress: View {
    let progress: Double
    var body: some View {
        let blocks = 14
        let filled = Int((Double(blocks) * progress).rounded(.down))
        HStack(spacing: 1.5) {
            ForEach(0..<blocks, id: \.self) { i in
                Rectangle()
                    .fill(i < filled ? Color(hex: 0x0A1A86) : .clear)
                    .frame(width: 6, height: 9)
            }
        }
        .padding(2)
        .background(Color(hex: 0xD8D8D8))
        .overlay(Bevel(raised: false))
    }
}

private struct PixelCursor: View {
    var body: some View {
        let pixel: CGFloat = 1.6
        // 12×19 ok imleci: 1 = siyah kenar, 2 = beyaz dolgu.
        let rows = [
            "1", "11", "121", "1221", "12221", "122221", "1222221", "12222221", "122222221", "1222222221",
            "12222211111", "1221221", "121 1221", "11  1221", "1    1221", "     1221", "      1221", "      111"
        ]
        return Canvas { ctx, _ in
            for (y, row) in rows.enumerated() {
                for (x, ch) in row.enumerated() where ch != " " {
                    ctx.fill(Path(CGRect(x: CGFloat(x) * pixel, y: CGFloat(y) * pixel, width: pixel, height: pixel)),
                             with: .color(ch == "1" ? .black : .white))
                }
            }
        }
        .frame(width: 12 * pixel, height: 19 * pixel)
        .shadow(color: .black.opacity(0.3), radius: 0, x: 1.5, y: 1.5)
    }
}

/// Metni küçük boyutta 1× çizip en yakın komşu ile büyütür — eski ekran piksel yazısı.
private struct PixelLabel: View {
    let text: String
    var fontSize: CGFloat = 10
    var pixel: CGFloat = 4
    var color: Color = .white
    var chroma: CGFloat = 0

    var body: some View {
        if let cg = RetroAssets.pixelText(text, size: fontSize) {
            let w = CGFloat(cg.width) * pixel, h = CGFloat(cg.height) * pixel
            ZStack {
                if chroma > 0 {
                    glyph(cg, w, h).foregroundStyle(Color(hex: 0xFF3DD8).opacity(0.85)).offset(x: chroma, y: 0)
                    glyph(cg, w, h).foregroundStyle(Color(hex: 0x3DF0FF).opacity(0.85)).offset(x: -chroma, y: 0)
                }
                glyph(cg, w, h).foregroundStyle(color)
            }
            .frame(width: w, height: h)
        }
    }

    private func glyph(_ cg: CGImage, _ w: CGFloat, _ h: CGFloat) -> some View {
        Image(decorative: cg, scale: 1).renderingMode(.template).interpolation(.none).resizable().frame(width: w, height: h)
    }
}

/// SF Symbol'ü küçük çizip piksel ikon gibi büyütür.
private struct PixelSymbol: View {
    let name: String
    var pointSize: CGFloat
    var pixel: CGFloat
    var colors: [Color]

    var body: some View {
        if let cg = RetroAssets.pixelSymbol(name, size: pointSize, colors: colors) {
            Image(decorative: cg, scale: 1)
                .interpolation(.none)
                .resizable()
                .frame(width: CGFloat(cg.width) * pixel, height: CGFloat(cg.height) * pixel)
        }
    }
}

@MainActor
private enum RetroAssets {
    private static var images: [String: UIImage] = [:]
    private static var texts: [String: CGImage] = [:]
    private static var symbols: [String: CGImage] = [:]

    static func image(_ file: String) -> UIImage? {
        if let cached = images[file] { return cached }
        let image = UIImage(contentsOfFile: PromoRetroScene.assetFolder + file)
        images[file] = image
        return image
    }

    static func pixelText(_ text: String, size: CGFloat) -> CGImage? {
        let key = "\(text)|\(size)"
        if let cached = texts[key] { return cached }
        let renderer = ImageRenderer(content: Text(text).font(.system(size: size, weight: .heavy, design: .monospaced)).foregroundStyle(.white).fixedSize())
        renderer.scale = 1
        let cg = renderer.cgImage
        texts[key] = cg
        return cg
    }

    static func pixelSymbol(_ name: String, size: CGFloat, colors: [Color]) -> CGImage? {
        let key = "\(name)|\(size)|\(colors.count)"
        if let cached = symbols[key] { return cached }
        let view = Image(systemName: name)
            .font(.system(size: size, weight: .bold))
            .symbolRenderingMode(.palette)
            .foregroundStyle(colors.first ?? .gray, colors.dropFirst().first ?? .cyan)
            .fixedSize()
        let renderer = ImageRenderer(content: view)
        renderer.scale = 1
        let cg = renderer.cgImage
        symbols[key] = cg
        return cg
    }
}

/// Sabit (her karede aynı) çimen yaprakları.
private enum RetroGrass {
    struct Blade { let x: CGFloat; let depth: CGFloat; let height: CGFloat; let lean: CGFloat; let color: Color }
    static let blades: [Blade] = {
        var seed: UInt64 = 0x9E3779B97F4A7C15
        func rnd() -> CGFloat {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            return CGFloat((seed >> 33) & 0xFFFFFF) / CGFloat(0xFFFFFF)
        }
        let palette: [UInt32] = [0x8EE04A, 0x6CC533, 0x4FAE25, 0x3B961B, 0x2E7F14, 0xA6EA5C]
        var result: [Blade] = []
        for _ in 0..<1400 {
            let depth = pow(rnd(), 0.8)
            result.append(Blade(x: rnd() * 380 - 10, depth: depth, height: 5 + rnd() * 9, lean: (rnd() - 0.5) * 4,
                                color: Color(hex: palette[Int(rnd() * CGFloat(palette.count)) % palette.count])))
        }
        return result.sorted { $0.depth < $1.depth }
    }()
}

// MARK: - Dönen dünya (yazılımla çizilen küre)

/// Eş dikdörtgen (enlem/boylam) dokulu küreyi her karede ortografik izdüşümle çizer. Doku, uygulamadaki
/// kıta çokgenlerinden (ClayGlobeTexture.continents) gürültüyle zenginleştirilerek üretilir: okyanus
/// derinliği, kıyı sığlığı, iklim kuşaklarına göre kara rengi, kutup buzu ve ayrı dönen bulut katmanı.
@MainActor
final class RetroEarth {
    static let shared = RetroEarth()

    private let texW = 1024, texH = 512
    private var surface: [UInt32] = []   // 0xRRGGBB
    private var clouds: [UInt8] = []
    private let size = 480
    private var lutLon: [Float] = []
    private var lutRow: [Int32] = []
    private var lutShade: [Float] = []
    private var lutRim: [Float] = []
    private var lutAlpha: [Float] = []

    private init() {
        buildTexture()
        buildLookup()
    }

    func frame(angle: Double) -> CGImage? {
        let n = size
        var pixels = [UInt32](repeating: 0, count: n * n)
        let offset = Float(angle / (2 * .pi)) * Float(texW)
        let cloudOffset = offset * 1.18
        let w = texW
        pixels.withUnsafeMutableBufferPointer { out in
            surface.withUnsafeBufferPointer { tex in
                clouds.withUnsafeBufferPointer { cl in
                    for i in 0..<(n * n) {
                        let a = lutAlpha[i]
                        if a <= 0 { continue }
                        let row = Int(lutRow[i]) * w
                        var x = Int(lutLon[i] - offset) % w; if x < 0 { x += w }
                        var cx = Int(lutLon[i] - cloudOffset) % w; if cx < 0 { cx += w }
                        let c = tex[row + x]
                        var r = Float((c >> 16) & 0xFF), g = Float((c >> 8) & 0xFF), b = Float(c & 0xFF)
                        let cloud = Float(cl[row + cx]) / 255 * 0.92
                        r += (250 - r) * cloud; g += (252 - g) * cloud; b += (255 - b) * cloud
                        let s = lutShade[i], rim = lutRim[i]
                        r = r * s + (175 - r * s) * rim
                        g = g * s + (215 - g * s) * rim
                        b = b * s + (255 - b * s) * rim
                        let ri = UInt32(max(0, min(255, r * a))), gi = UInt32(max(0, min(255, g * a))), bi = UInt32(max(0, min(255, b * a)))
                        let ai = UInt32(max(0, min(255, a * 255)))
                        // BGRA little-endian (premultipliedFirst)
                        out[i] = (ai << 24) | (ri << 16) | (gi << 8) | bi
                    }
                }
            }
        }
        let data = pixels.withUnsafeBufferPointer { Data(buffer: $0) }
        guard let provider = CGDataProvider(data: data as CFData) else { return nil }
        return CGImage(width: n, height: n, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: n * 4,
                       space: CGColorSpaceCreateDeviceRGB(),
                       bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue),
                       provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
    }

    // MARK: Doku

    private func landMask(blur: CGFloat) -> [UInt8] {
        let size = CGSize(width: texW, height: texH)
        func point(_ lon: Double, _ lat: Double) -> CGPoint {
            CGPoint(x: (lon + 180) / 360 * size.width, y: (90 - lat) / 180 * size.height)
        }
        var gray = [UInt8](repeating: 0, count: texW * texH)
        gray.withUnsafeMutableBytes { buffer in
            guard let ctx = CGContext(data: buffer.baseAddress, width: texW, height: texH, bitsPerComponent: 8, bytesPerRow: texW,
                                      space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue) else { return }
            ctx.translateBy(x: 0, y: size.height)
            ctx.scaleBy(x: 1, y: -1)
            if blur > 0 { ctx.setShadow(offset: .zero, blur: blur, color: UIColor.white.cgColor) }
            ctx.setFillColor(UIColor.white.cgColor)
            for polygon in ClayGlobeTexture.continents {
                ctx.beginPath()
                ctx.move(to: point(polygon[0].0, polygon[0].1))
                for v in polygon.dropFirst() { ctx.addLine(to: point(v.0, v.1)) }
                ctx.closePath()
                ctx.fillPath()
            }
        }
        return gray
    }

    private static func hash(_ x: Int, _ y: Int, _ seed: Int) -> Float {
        var h = UInt32(truncatingIfNeeded: x &* 374_761_393 &+ y &* 668_265_263 &+ seed &* 1_442_695_041)
        h = (h ^ (h >> 13)) &* 1_274_126_177
        h ^= h >> 16
        return Float(h & 0xFFFF) / 65535
    }

    /// Boylamda sarmalanan değer gürültüsü (u: 0..1 boylam, v: 0..1 enlem).
    private static func noise(_ u: Float, _ v: Float, cells: Int, seed: Int) -> Float {
        let x = u * Float(cells), y = v * Float(cells / 2)
        let x0 = Int(floor(x)), y0 = Int(floor(y))
        let fx = x - Float(x0), fy = y - Float(y0)
        let sx = fx * fx * (3 - 2 * fx), sy = fy * fy * (3 - 2 * fy)
        func h(_ a: Int, _ b: Int) -> Float { hash(((a % cells) + cells) % cells, b, seed) }
        let a = h(x0, y0), b = h(x0 + 1, y0), c = h(x0, y0 + 1), d = h(x0 + 1, y0 + 1)
        return (a + (b - a) * sx) + ((c + (d - c) * sx) - (a + (b - a) * sx)) * sy
    }

    private static func fbm(_ u: Float, _ v: Float, base: Int, octaves: Int, seed: Int) -> Float {
        var total: Float = 0, amp: Float = 0.5, norm: Float = 0, cells = base
        for o in 0..<octaves {
            total += noise(u, v, cells: cells, seed: seed + o * 31) * amp
            norm += amp; amp *= 0.5; cells *= 2
        }
        return total / norm
    }

    private func buildTexture() {
        let land = landMask(blur: 0)
        let coast = landMask(blur: 18)
        surface = [UInt32](repeating: 0, count: texW * texH)
        clouds = [UInt8](repeating: 0, count: texW * texH)

        func mix(_ a: (Float, Float, Float), _ b: (Float, Float, Float), _ k: Float) -> (Float, Float, Float) {
            (a.0 + (b.0 - a.0) * k, a.1 + (b.1 - a.1) * k, a.2 + (b.2 - a.2) * k)
        }
        func rgb(_ hex: UInt32) -> (Float, Float, Float) { (Float((hex >> 16) & 0xFF), Float((hex >> 8) & 0xFF), Float(hex & 0xFF)) }
        let deep = rgb(0x0E2F7A), mid = rgb(0x1B56B5), shallow = rgb(0x3D9AD6)
        let jungle = rgb(0x2D6E27), green = rgb(0x4C8C34), steppe = rgb(0x8E9A4C), desert = rgb(0xCDAA6E), tundra = rgb(0x6B6E4E), ice = rgb(0xEEF3F8)

        for y in 0..<texH {
            let v = Float(y) / Float(texH)
            let lat = 90 - v * 180
            let absLat = abs(lat)
            for x in 0..<texW {
                let u = Float(x) / Float(texW)
                let i = y * texW + x
                let n = Self.fbm(u, v, base: 16, octaves: 5, seed: 7)
                // Düzensiz kenarlı kutup buzu (kara ve deniz): kıta çokgenlerinin düz kuzey/güney kenarlarını örter.
                let capEdge: Float = lat > 0 ? 63 + n * 12 : 60 + n * 8
                var col: (Float, Float, Float)
                if land[i] > 127 {
                    // İklim kuşakları + gürültü
                    if absLat < 14 { col = mix(jungle, green, n * 0.6) }
                    else if absLat < 34 { col = mix(green, desert, min(1, max(0, (n - 0.35) * 2.6))) }
                    else if absLat < 56 { col = mix(green, steppe, n) }
                    else if absLat < 68 { col = mix(tundra, steppe, n * 0.5) }
                    else { col = ice }
                    let lon = u * 360 - 180
                    if lat > 58 && lon > -62 && lon < -18 { col = ice } // Grönland
                    if lat < -62 { col = ice }
                    let shadeNoise = 0.85 + Self.fbm(u, v, base: 64, octaves: 3, seed: 3) * 0.3
                    col = (col.0 * shadeNoise, col.1 * shadeNoise, col.2 * shadeNoise)
                } else {
                    let depthNoise = Self.fbm(u, v, base: 8, octaves: 4, seed: 11)
                    col = mix(deep, mid, depthNoise)
                    let c = Float(coast[i]) / 255
                    col = mix(col, shallow, min(1, c * 1.4))
                    if absLat > 72 { col = mix(col, ice, min(1, (absLat - 72) / 6)) }
                }
                if absLat > capEdge { col = mix(ice, rgb(0xD6E4F2), Self.fbm(u, v, base: 32, octaves: 2, seed: 5)) }
                surface[i] = (UInt32(max(0, min(255, col.0))) << 16) | (UInt32(max(0, min(255, col.1))) << 8) | UInt32(max(0, min(255, col.2)))

                // Bulutlar: girdaplı gürültü + ekvator kuşağı
                let warp = Self.fbm(u, v, base: 6, octaves: 2, seed: 41) * 0.08
                var cn = Self.fbm(u + warp, v, base: 12, octaves: 5, seed: 23)
                cn += max(0, 0.12 - abs(lat - 5) / 120)
                let cloud = min(1, max(0, (cn - 0.53) / 0.17))
                clouds[i] = UInt8(cloud * 255)
            }
        }
    }

    // MARK: İzdüşüm tablosu

    private func buildLookup() {
        let n = size
        let r = Float(n) / 2
        lutLon = [Float](repeating: 0, count: n * n)
        lutRow = [Int32](repeating: 0, count: n * n)
        lutShade = [Float](repeating: 0, count: n * n)
        lutRim = [Float](repeating: 0, count: n * n)
        lutAlpha = [Float](repeating: 0, count: n * n)
        let tilt: Float = 0.38, lean: Float = 0.30   // eksen eğikliği (düzlemde) ve kuzeyin izleyiciye dönüklüğü
        let light: (Float, Float, Float) = { let v: (Float, Float, Float) = (-0.55, 0.5, 0.67); let l = (v.0 * v.0 + v.1 * v.1 + v.2 * v.2).squareRoot(); return (v.0 / l, v.1 / l, v.2 / l) }()
        for py in 0..<n {
            for px in 0..<n {
                let i = py * n + px
                let x = (Float(px) + 0.5 - r) / r
                let y = -(Float(py) + 0.5 - r) / r
                let d2 = x * x + y * y
                let dist = d2.squareRoot() * r
                let alpha = max(0, min(1, r - dist))
                lutAlpha[i] = alpha
                guard alpha > 0 else { continue }
                let z = max(0, 1 - min(1, d2)).squareRoot()
                // Düzlem içi eğiklik
                let x1 = x * cos(tilt) + y * sin(tilt)
                let y1 = -x * sin(tilt) + y * cos(tilt)
                // Kuzeyi izleyiciye doğru eğ
                let y2 = y1 * cos(lean) + z * sin(lean)
                let z2 = -y1 * sin(lean) + z * cos(lean)
                let lat = asin(max(-1, min(1, y2)))
                let lon = atan2(x1, z2)
                lutLon[i] = (lon / (2 * .pi) + 0.5) * Float(texW)
                lutRow[i] = Int32(max(0, min(Float(texH - 1), (0.5 - lat / .pi) * Float(texH))))
                let diffuse = max(0, x * light.0 + y * light.1 + z * light.2)
                lutShade[i] = 0.28 + 0.9 * diffuse
                lutRim[i] = pow(1 - z, 2.6) * 0.75
            }
        }
    }
}

// MARK: - Geliştirme ekranı

/// `-debugScreen retro` canlı oynatır, `-promoT 5` belirli anı gösterir, `-debugScreen retroexport` MP4 yazar.
struct PromoRetroDebugScreen: View {
    let export: Bool
    @State private var status = "Hazırlanıyor…"

    var body: some View {
        Group {
            if let raw = UserDefaults.standard.string(forKey: "promoT"), let fixed = Double(raw) {
                PromoRetroScene(t: fixed)
            } else if export {
                VStack(spacing: 12) {
                    Text("Video yazılıyor").font(.headline)
                    Text(status).monospacedDigit()
                }
                .frame(width: PromoRetroScene.size.width, height: PromoRetroScene.size.height)
                .background(Color.white)
            } else {
                TimelineView(.animation) { ctx in
                    PromoRetroScene(t: ctx.date.timeIntervalSince(Self.start).truncatingRemainder(dividingBy: PromoRetroScene.duration))
                }
            }
        }
        .scaleEffect(UIScreen.main.bounds.width / PromoRetroScene.size.width)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .ignoresSafeArea()
        .task {
            guard export else { return }
            do {
                let url = try await PromoVideoExporter.export(fileName: "geonaut_retro.mp4", duration: PromoRetroScene.duration,
                                                              size: PromoRetroScene.size, progress: { status = String(format: "%%%.0f", $0 * 100) }) {
                    PromoRetroScene(t: $0)
                }
                status = "Bitti: \(url.lastPathComponent)"
                print("RETRO_EXPORT_DONE \(url.path)")
            } catch {
                status = "Hata: \(error.localizedDescription)"
            }
        }
    }

    private static let start = Date()
}
#endif
