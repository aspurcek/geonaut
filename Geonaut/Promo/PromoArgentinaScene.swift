#if DEBUG
import SwiftUI
import AVFoundation

/// TikTok/Story tanıtım videosu (kullanıcı isteği 2026-11-19), yalnızca geliştirme derlemesinde.
/// Sıcak bir ev: anne kanepede Geonaut oynuyor, Arjantin bayrağı geliyor, doğru cevabı seçiyor;
/// yanındaki küçük oğlu "Anne, bu Messi'nin bayrağı mı?" diyor, anne şaşkın şaşkın ona bakıyor.
/// Karakterler uygulamanın kendi avatar çizimi (GeoAvatarCharacterView). Sahne `t` saniyesine göre
/// tamamen belirlenir; `PromoVideoExporter` her kareyi çizip 1080×1920 MP4 yazar.
struct PromoArgentinaScene: View {
    let t: Double
    static let duration: Double = 17
    static let size = CGSize(width: 360, height: 640)

    // MARK: Zaman yardımcıları

    private func p(_ a: Double, _ b: Double) -> Double { min(max((t - a) / (b - a), 0), 1) }
    private func ease(_ x: Double) -> Double { x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2 }
    private func spring(_ x: Double) -> Double {
        guard x > 0 else { return 0 }
        guard x < 1 else { return 1 }
        return 1 - exp(-6 * x) * cos(10 * x)
    }

    private let line = "Anne, bu Messi'nin bayrağı mı?"
    private var typed: String {
        let n = Int(Double(line.count) * p(7.2, 9.6))
        return String(line.prefix(n))
    }

    var body: some View {
        ZStack {
            room
            characters
                .scaleEffect(1 + 0.12 * ease(p(10.6, 12.2)), anchor: UnitPoint(x: 0.55, y: 0.62))
            hookCaption
            phoneInsert
            speechBubble
            surpriseMarks
            endCard
        }
        .frame(width: Self.size.width, height: Self.size.height)
        .clipped()
        .environment(\.locale, Locale(identifier: "tr_TR"))
    }

    // MARK: Oda

    private var room: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0xF7E3CF), GeoColor.bgCanvas], startPoint: .top, endPoint: .bottom)
            // Akşam penceresi: lavanta gökyüzü, ay ve yıldızlar
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(colors: [Color(hex: 0x6F5FA3), GeoColor.accentTertiaryStrong, GeoColor.accentTertiary], startPoint: .top, endPoint: .bottom))
                ForEach(0..<9, id: \.self) { i in
                    let x = [22, 60, 98, 130, 40, 112, 80, 18, 140][i], y = [20, 34, 18, 46, 70, 82, 58, 96, 110][i]
                    Image(systemName: "sparkle")
                        .font(.system(size: CGFloat(5 + (i % 3) * 2)))
                        .foregroundStyle(.white.opacity(0.55 + 0.35 * sin(t * 2.2 + Double(i))))
                        .position(x: CGFloat(x), y: CGFloat(y))
                }
                Image(systemName: "moon.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(GeoColor.accentHighlight)
                    .shadow(color: GeoColor.accentHighlight.opacity(0.7), radius: 10)
                    .position(x: 116, y: 38)
                Rectangle().fill(GeoColor.bgSurface).frame(width: 6)
                Rectangle().fill(GeoColor.bgSurface).frame(height: 6).offset(y: 6)
            }
            .frame(width: 160, height: 150)
            .overlay { RoundedRectangle(cornerRadius: 18).strokeBorder(GeoColor.bgSurface, lineWidth: 8) }
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            .position(x: 100, y: 150)

            // Duvarda dünya haritası çerçevesi
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(GeoColor.bgSurface)
                Image("ContinentMap-neutral")
                    .resizable().scaledToFit()
                    .padding(8)
                    .opacity(0.85)
            }
            .frame(width: 112, height: 76)
            .overlay { RoundedRectangle(cornerRadius: 10).strokeBorder(Color(hex: 0xC9A27E), lineWidth: 5) }
            .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
            .rotationEffect(.degrees(-2))
            .position(x: 270, y: 132)

            // Lambanın sıcak ışığı
            RadialGradient(colors: [GeoColor.accentHighlight.opacity(0.55), .clear], center: .center, startRadius: 4, endRadius: 150)
                .frame(width: 300, height: 300)
                .position(x: 330, y: 250)
            lamp.position(x: 330, y: 330)

            // Zemin ve halı
            Rectangle().fill(Color(hex: 0xE9C9A6)).frame(height: 120).position(x: 180, y: 600)
            Ellipse().fill(GeoColor.accentTertiary.opacity(0.7)).frame(width: 330, height: 60).position(x: 180, y: 610)

            sofa
            plant.position(x: 30, y: 520)
        }
    }

    private var lamp: some View {
        ZStack {
            Rectangle().fill(Color(hex: 0x8A6A52)).frame(width: 4, height: 210).offset(y: 70)
            Path { p in
                p.move(to: CGPoint(x: 14, y: 0)); p.addLine(to: CGPoint(x: 46, y: 0))
                p.addLine(to: CGPoint(x: 60, y: 40)); p.addLine(to: CGPoint(x: 0, y: 40)); p.closeSubpath()
            }
            .fill(LinearGradient(colors: [GeoColor.accentHighlight, Color(hex: 0xF6C978)], startPoint: .top, endPoint: .bottom))
            .frame(width: 60, height: 40)
            .offset(y: -40)
        }
    }

    private var sofa: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34)
                .fill(LinearGradient(colors: [GeoColor.accentPrimarySoft, GeoColor.accentPrimary], startPoint: .top, endPoint: .bottom))
                .frame(width: 340, height: 150)
                .position(x: 180, y: 470)
            RoundedRectangle(cornerRadius: 24)
                .fill(GeoColor.accentPrimarySoft.geoMixed(with: .white, by: 0.12))
                .frame(width: 300, height: 70)
                .position(x: 180, y: 520)
            ForEach([14.0, 346.0], id: \.self) { x in
                RoundedRectangle(cornerRadius: 22)
                    .fill(GeoColor.accentPrimary.geoMixed(with: .black, by: 0.06))
                    .frame(width: 46, height: 110)
                    .position(x: x, y: 505)
            }
            // Yastık
            RoundedRectangle(cornerRadius: 16)
                .fill(GeoColor.accentHighlight)
                .frame(width: 58, height: 48)
                .rotationEffect(.degrees(-10))
                .position(x: 52, y: 452)
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(hex: 0x8A6A52))
                .frame(width: 300, height: 14)
                .position(x: 180, y: 556)
        }
    }

    private var plant: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { i in
                Capsule().fill(GeoColor.accentSuccessStrong.geoMixed(with: .white, by: Double(i) * 0.06))
                    .frame(width: 16, height: 60)
                    .rotationEffect(.degrees(Double(i - 2) * 22 + sin(t * 1.4 + Double(i)) * 2), anchor: .bottom)
                    .offset(y: -30)
            }
            RoundedRectangle(cornerRadius: 6).fill(GeoColor.bgSurface).frame(width: 40, height: 36).offset(y: 14)
        }
    }

    // MARK: Karakterler

    private var momGaze: CGPoint {
        let toSon = ease(p(10.4, 10.9))
        return CGPoint(x: -0.1 + 1.1 * toSon, y: 0.7 - 0.7 * toSon)
    }

    private var characters: some View {
        let lean = ease(p(6.4, 7.0)) - ease(p(13.6, 14.0)) * 0
        let talking = t > 7.2 && t < 9.8
        let mouth = talking ? CGFloat(0.5 + 0.5 * sin(t * 18)) : 0
        let surprise = CGFloat(ease(p(10.7, 11.1)))
        return ZStack {
            // Anne
            GeoAvatarCharacterView(
                skinTone: .bugday, hairStyle: .uzun, hairColor: Color(hex: 0x5A3826),
                shirtColor: GeoColor.accentTertiary,
                surprise: surprise, mouthOpen: 0, gaze: momGaze
            )
            .scaleEffect(2.15)
            .rotationEffect(.degrees(4 * ease(p(10.4, 10.9))))
            .position(x: 138, y: 392 - 4 * sin(t * 1.6) * 0.3)

            // Annenin elindeki telefon
            ZStack {
                RoundedRectangle(cornerRadius: 9).fill(GeoColor.textPrimary).frame(width: 40, height: 72)
                RoundedRectangle(cornerRadius: 6).fill(GeoColor.bgCanvas).frame(width: 34, height: 64)
                Text(GeoFlagAnswerOption.flagEmoji(for: "AR")).font(.system(size: 16)).offset(y: -10)
                VStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(i == 1 && t > 4.3 ? GeoColor.accentSuccess : GeoColor.borderSubtle)
                            .frame(width: 26, height: 5)
                    }
                }.offset(y: 14)
            }
            .shadow(color: GeoColor.accentInfo.opacity(0.6), radius: 8)
            .rotationEffect(.degrees(-8))
            .position(x: 182, y: 472)
            // Eller
            ForEach([162.0, 200.0], id: \.self) { x in
                Ellipse().fill(SkinTone.bugday.color).frame(width: 18, height: 14).position(x: x, y: 492)
            }

            // Oğlu
            GeoAvatarCharacterView(
                skinTone: .bugday, hairStyle: .kivircik, hairColor: Color(hex: 0x3B2A20),
                shirtColor: GeoColor.accentInfo,
                surprise: 0, mouthOpen: mouth,
                gaze: t < 10.2 ? CGPoint(x: -0.8, y: 0.5) : CGPoint(x: -0.9, y: 0)
            )
            .scaleEffect(1.45)
            .rotationEffect(.degrees(-9 * lean))
            .position(x: 262 - 16 * lean, y: 432 - 4 * lean + abs(sin(t * 3)) * (talking ? 1.5 : 0))
        }
    }

    // MARK: Telefon (yakın plan)

    private var phoneInsert: some View {
        let inP = spring(p(1.2, 2.2)), out = ease(p(5.8, 6.5))
        let y = 640 + 400 - 650 * inP + 700 * out
        let correct = t > 4.3
        let tap = p(3.95, 4.5)
        return ZStack {
            RoundedRectangle(cornerRadius: 44).fill(GeoColor.textPrimary)
            RoundedRectangle(cornerRadius: 36).fill(GeoColor.bgCanvas).padding(9)
            VStack(spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left").font(.system(size: 13, weight: .bold)).foregroundStyle(GeoColor.textPrimary)
                    GeoProgressBar(progress: 0.4)
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill").font(.system(size: 12)).foregroundStyle(GeoColor.accentDanger)
                        Text(verbatim: "5").font(.custom(GeoFontName.balooBold, size: 14)).foregroundStyle(GeoColor.textPrimary)
                    }
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(GeoColor.bgSurface, in: Capsule())
                }
                Text("Bu hangi ülkenin bayrağı?")
                    .font(.custom(GeoFontName.balooBold, size: 17))
                    .foregroundStyle(GeoColor.textPrimary)
                Text(GeoFlagAnswerOption.flagEmoji(for: "AR"))
                    .font(.system(size: 92))
                    .scaleEffect(0.6 + 0.4 * spring(p(1.8, 2.8)))
                    .frame(height: 110)
                VStack(spacing: 8) {
                    ForEach(Array(["Uruguay", "Arjantin", "Şili", "Paraguay"].enumerated()), id: \.offset) { i, name in
                        GeoAnswerOption(text: name, state: correct && i == 1 ? .correct : .normal)
                            .scaleEffect(i == 1 && tap > 0 && tap < 1 ? 0.96 : 1)
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 30)
            .frame(maxHeight: .infinity, alignment: .top)

            // Dokunuş halkası
            if tap > 0 && tap < 1 {
                Circle()
                    .strokeBorder(GeoColor.accentPrimary, lineWidth: 3)
                    .frame(width: 30 + 40 * tap, height: 30 + 40 * tap)
                    .opacity(1 - tap)
                    .position(x: 150, y: 344)
            }
            // +10 puan
            if correct {
                HStack(spacing: 4) {
                    GeoGemIcon(size: 16)
                    Text(verbatim: "+10").font(.custom(GeoFontName.balooExtraBold, size: 18)).foregroundStyle(GeoColor.accentInfoStrong)
                }
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(GeoColor.bgSurface, in: Capsule())
                .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                .offset(y: -30 * ease(p(4.3, 5.2)))
                .opacity(1 - p(5.2, 5.7))
                .position(x: 230, y: 300)
            }
        }
        .frame(width: 270, height: 520)
        .shadow(color: .black.opacity(0.25), radius: 24, y: 12)
        .rotationEffect(.degrees(-3 + 3 * inP))
        .position(x: 180, y: y)
    }

    // MARK: Yazılar

    private var hookCaption: some View {
        let a = p(0.2, 0.8) * (1 - p(1.0, 1.4))
        return Text("Akşam evde, Geonaut'ta\nbir bayrak sorusu…")
            .font(.custom(GeoFontName.balooExtraBold, size: 22))
            .multilineTextAlignment(.center)
            .foregroundStyle(GeoColor.textPrimary)
            .padding(.horizontal, 18).padding(.vertical, 10)
            .background(GeoColor.bgSurface.opacity(0.92), in: RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            .opacity(a)
            .offset(y: -8 * (1 - p(0.2, 0.8)))
            .position(x: 180, y: 70)
    }

    private var speechBubble: some View {
        let show = spring(p(7.0, 7.6)) * (1 - ease(p(13.6, 14.1)))
        return VStack(alignment: .leading, spacing: 0) {
            Text(typed.isEmpty ? " " : typed)
                .font(.custom(GeoFontName.balooExtraBold, size: 21))
                .foregroundStyle(GeoColor.textPrimary)
                .frame(width: 210, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minHeight: 56, alignment: .topLeading)
        }
        .padding(.horizontal, 18).padding(.vertical, 14)
        .background(GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: 22))
        .overlay(alignment: .bottomTrailing) {
            Triangle().fill(GeoColor.bgSurface).frame(width: 22, height: 18).offset(x: -40, y: 14)
        }
        .shadow(color: .black.opacity(0.12), radius: 10, y: 5)
        .scaleEffect(show, anchor: .bottomTrailing)
        .opacity(show > 0.02 ? 1 : 0)
        .position(x: 190, y: 250)
    }

    private var surpriseMarks: some View {
        let a = spring(p(11.0, 11.5)) * (1 - ease(p(13.6, 14.1)))
        return HStack(spacing: 2) {
            Text(verbatim: "?").rotationEffect(.degrees(-12))
            Text(verbatim: "!").rotationEffect(.degrees(10)).offset(y: -6)
        }
        .font(.custom(GeoFontName.balooExtraBold, size: 46))
        .foregroundStyle(GeoColor.accentPrimary)
        .shadow(color: .white, radius: 0, x: 2, y: 2)
        .scaleEffect(a)
        .opacity(a > 0.02 ? 1 : 0)
        .position(x: 44, y: 330 + 4 * sin(t * 5))
    }

    private var endCard: some View {
        let a = ease(p(14.0, 14.6))
        return ZStack {
            GeoColor.bgCanvas.opacity(0.94)
            RadialGradient(colors: [GeoColor.accentTertiary.opacity(0.8), .clear], center: .center, startRadius: 10, endRadius: 260)
            VStack(spacing: 14) {
                Image("MascotBody")
                    .resizable().scaledToFit()
                    .frame(width: 150, height: 150)
                    .offset(y: -10 * abs(sin(t * 3)))
                    .scaleEffect(0.7 + 0.3 * spring(p(14.1, 15.0)))
                Text(verbatim: "Geonaut")
                    .font(.custom(GeoFontName.balooExtraBold, size: 44))
                    .foregroundStyle(GeoColor.textPrimary)
                Text("Oyna, öğren, dünyayı keşfet!")
                    .font(.custom(GeoFontName.balooBold, size: 19))
                    .foregroundStyle(GeoColor.textSecondary)
                HStack(spacing: 8) {
                    Image(systemName: "apple.logo").font(.system(size: 17, weight: .bold))
                    Text("App Store'da").font(.custom(GeoFontName.balooExtraBold, size: 18))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 22).padding(.vertical, 12)
                .background(GeoColor.textPrimary, in: Capsule())
                .padding(.top, 8)
                .opacity(p(14.8, 15.3))
            }
        }
        .opacity(a)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.midX + rect.width * 0.3, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Dışa aktarma

/// Sahneyi 30 kare/sn, 1080×1920 H.264 MP4 olarak uygulamanın Documents klasörüne yazar.
@MainActor
enum PromoVideoExporter {
    static func export(fps: Int = 30, progress: @escaping (Double) -> Void) async throws -> URL {
        try await export(fileName: "geonaut_tiktok_argentina.mp4", duration: PromoArgentinaScene.duration,
                         size: PromoArgentinaScene.size, fps: fps, progress: progress) { PromoArgentinaScene(t: $0) }
    }

    /// Herhangi bir zamana bağlı sahneyi (t saniye → View) 1080×1920 MP4'e yazar.
    static func export<V: View>(fileName: String, duration: Double, size: CGSize, fps: Int = 30,
                                progress: @escaping (Double) -> Void, frame: @escaping (Double) -> V) async throws -> URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: url)
        let width = 1080, height = 1920
        let writer = try AVAssetWriter(outputURL: url, fileType: .mp4)
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width, AVVideoHeightKey: height,
            AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: 10_000_000, AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel]
        ])
        input.expectsMediaDataInRealTime = false
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: width, kCVPixelBufferHeightKey as String: height
        ])
        writer.add(input)
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)
        let frames = Int(duration * Double(fps))
        for i in 0..<frames {
            let t = Double(i) / Double(fps)
            let renderer = ImageRenderer(content: frame(t))
            renderer.scale = CGFloat(width) / size.width
            guard let cg = renderer.cgImage else { continue }
            while !input.isReadyForMoreMediaData { try await Task.sleep(for: .milliseconds(5)) }
            if let buffer = pixelBuffer(from: cg, pool: adaptor.pixelBufferPool, width: width, height: height) {
                adaptor.append(buffer, withPresentationTime: CMTime(value: CMTimeValue(i), timescale: CMTimeScale(fps)))
            }
            if i % 10 == 0 { progress(Double(i) / Double(frames)) }
        }
        input.markAsFinished()
        await writer.finishWriting()
        progress(1)
        return url
    }

    private static func pixelBuffer(from image: CGImage, pool: CVPixelBufferPool?, width: Int, height: Int) -> CVPixelBuffer? {
        guard let pool else { return nil }
        var buffer: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(nil, pool, &buffer)
        guard let buffer else { return nil }
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        guard let ctx = CGContext(data: CVPixelBufferGetBaseAddress(buffer), width: width, height: height, bitsPerComponent: 8,
                                  bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue) else { return nil }
        ctx.setFillColor(red: 0.98, green: 0.96, blue: 0.9, alpha: 1)
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return buffer
    }
}

/// Geliştirme ekranı: `-debugScreen promo` sahneyi canlı oynatır; `-promoT 11.5` belirli bir anı sabit gösterir;
/// `-debugScreen promoexport` MP4'ü yazar.
struct PromoDebugScreen: View {
    let export: Bool
    @State private var status = "Hazırlanıyor…"

    var body: some View {
        Group {
            if let raw = UserDefaults.standard.string(forKey: "promoT"), let fixed = Double(raw) {
                PromoArgentinaScene(t: fixed)
            } else if export {
                VStack(spacing: 12) {
                    Text("Video yazılıyor").font(.headline)
                    Text(status).monospacedDigit()
                }
            } else {
                TimelineView(.animation) { ctx in
                    let start = Self.start
                    PromoArgentinaScene(t: ctx.date.timeIntervalSince(start).truncatingRemainder(dividingBy: PromoArgentinaScene.duration))
                }
            }
        }
        .scaleEffect(UIScreen.main.bounds.width / PromoArgentinaScene.size.width)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .ignoresSafeArea()
        .task {
            guard export else { return }
            do {
                let url = try await PromoVideoExporter.export { status = String(format: "%%%.0f", $0 * 100) }
                status = "Bitti: \(url.lastPathComponent)"
                print("PROMO_EXPORT_DONE \(url.path)")
            } catch {
                status = "Hata: \(error.localizedDescription)"
            }
        }
    }

    private static let start = Date()
}
#endif
