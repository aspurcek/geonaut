import SwiftUI
import SceneKit
import CoreImage

/// İlk açılışta, giriş ekranından ÖNCE gösterilen 3 sayfalık hareketli tanıtım (Figma FLOW8 "Onboarding 1-3").
/// Fikir: tek bir 3B nesne (dünya) sayfadan sayfaya büyür; kullanıcı okumak yerine bir şey yapar
/// (1. sayfada gerçek bir bayrak sorusunu cevaplar). Renkler/yazı tipleri tasarım sisteminden.
/// "Hareketi azalt" açıksa tüm döngüler durur, her şey statik kalır.
struct IntroView: View {
    /// "Atla" ya da "Apple ile giriş yap" — giriş ekranına geçer.
    var onFinish: () -> Void
    /// Son sayfa: giriş yapmadan ilk seviyeyi dene.
    var onTryAsGuest: () -> Void

    @State private var page = 0
    private let pageCount = 3

    var body: some View {
        ZStack {
            GeoColor.bgCanvas.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Atla", action: onFinish)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(GeoColor.textMuted)
                        .padding(.horizontal, GeoSpacing.xl)
                        .padding(.top, GeoSpacing.md)
                }

                Spacer(minLength: 0)

                ZStack {
                    switch page {
                    case 0: IntroPageQuiz()
                    case 1: IntroPageMedal()
                    default: IntroPageWorld()
                    }
                }
                .id(page)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

                Spacer(minLength: 0)

                VStack(spacing: GeoSpacing.lg) {
                    pageDots

                    Button(page == pageCount - 1 ? "Hemen bir seviye dene" : "İleri") {
                        if page == pageCount - 1 {
                            onTryAsGuest()
                        } else {
                            withAnimation(.spring(duration: 0.5)) { page += 1 }
                        }
                    }
                    .buttonStyle(.kasifPrimary)
                    .frame(maxWidth: .infinity)

                    // Son sayfada görünür; diğerlerinde yer tutar ki düğme yerinden oynamasın.
                    Button("Apple ile giriş yap", action: onFinish)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(GeoColor.textSecondary)
                        .opacity(page == pageCount - 1 ? 1 : 0)
                        .disabled(page != pageCount - 1)
                }
                .padding(.horizontal, GeoSpacing.xl)
                .padding(.bottom, GeoSpacing.lg)
                .frame(maxWidth: 520)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 30).onEnded { value in
                withAnimation(.spring(duration: 0.5)) {
                    if value.translation.width < -40, page < pageCount - 1 { page += 1 }
                    if value.translation.width > 40, page > 0 { page -= 1 }
                }
            }
        )
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == page ? GeoColor.accentPrimary : GeoColor.borderSubtle)
                    .frame(width: index == page ? 24 : 8, height: 8)
            }
        }
        .animation(.spring(duration: 0.4), value: page)
        .accessibilityHidden(true)
    }
}

// MARK: - Sayfa iskeleti

private struct IntroPageLayout<Hero: View>: View {
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    @ViewBuilder var hero: Hero

    var body: some View {
        VStack(spacing: GeoSpacing.xl) {
            hero
                .frame(width: 342, height: 300)
            VStack(spacing: GeoSpacing.sm) {
                Text(title)
                    .font(.custom(GeoFontName.balooBold, size: 26))
                    .foregroundStyle(GeoColor.textPrimary)
                Text(message)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(GeoColor.textSecondary)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, GeoSpacing.xxl)
        }
    }
}

// MARK: - 1. sayfa: dünya + etkileşimli bayrak sorusu

private struct IntroPageQuiz: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false
    @State private var picked: Int?
    @State private var shaking: Int?
    @State private var hint = false

    private let options: [(flag: String, correct: Bool)] = [("🇯🇵", true), ("🇩🇪", false), ("🇧🇷", false)]

    var body: some View {
        IntroPageLayout(title: "Dünyayı oynayarak keşfet", message: "Bayrakları, ülkeleri, dilleri ve lezzetleri tanıdıkça dünya haritan açılır.") {
            ZStack(alignment: .top) {
                IntroGlobe(size: 190, spins: !reduceMotion)
                    .offset(y: 0)
                    .frame(maxWidth: .infinity)

                // Havada uçuşan oyun öğeleri (puan, can, yıldız) — alttaki bayrak seçeneklerinden ayrışsın diye bayrak değil.
                IntroChip(text: "340", color: .white, symbol: "diamond.fill", symbolColor: GeoColor.accentInfoStrong)
                    .rotationEffect(.degrees(-8))
                    .offset(x: appeared ? -120 : -260, y: appeared ? 44 : -60)
                IntroChip(text: "5", color: GeoColor.accentPrimarySoft.opacity(0.55), symbol: "heart.fill", symbolColor: GeoColor.accentDanger)
                    .rotationEffect(.degrees(9))
                    .offset(x: appeared ? 124 : 260, y: appeared ? 62 : -60)
                IntroChip(text: nil, color: GeoColor.accentHighlight, symbol: "star.fill", symbolColor: .white, symbolCount: 3)
                    .rotationEffect(.degrees(-6))
                    .offset(x: appeared ? 118 : 260, y: appeared ? 140 : 200)

                VStack(spacing: 26) {
                    Text("Hangisi Japonya'nın bayrağı?")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(GeoColor.textPrimary)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(.white, in: Capsule())
                        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)

                    HStack(spacing: 20) {
                        ForEach(options.indices, id: \.self) { index in
                            optionSticker(index)
                        }
                    }
                }
                .offset(y: 188)
                .opacity(appeared ? 1 : 0)
            }
            .frame(width: 342, height: 300, alignment: .top)
        }
        .onAppear {
            withAnimation(reduceMotion ? nil : .spring(response: 0.7, dampingFraction: 0.65).delay(0.15)) { appeared = true }
        }
        .task {
            // Dokunmazsa 5 sn sonra doğru cevabı nazikçe vurgula.
            try? await Task.sleep(for: .seconds(5))
            if picked == nil { withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) { hint = true } }
        }
    }

    private func optionSticker(_ index: Int) -> some View {
        let option = options[index]
        let isPicked = picked == index
        return ZStack(alignment: .top) {
            IntroSticker(emoji: option.flag, width: 76, height: 54, rotation: 0, fill: isPicked ? GeoColor.accentSuccess.opacity(0.35) : .white)
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(GeoColor.accentSuccess, lineWidth: isPicked || (hint && option.correct && picked == nil) ? 3 : 0)
                }
                .scaleEffect(hint && option.correct && picked == nil ? 1.07 : 1)
                .offset(x: shaking == index ? 6 : 0)
            if isPicked {
                HStack(spacing: 3) {
                    Image(systemName: "checkmark")
                    Text(verbatim: "+10")
                }
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(GeoColor.textPrimary)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(GeoColor.accentSuccess, in: Capsule())
                    .offset(y: -22)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onTapGesture {
            guard picked == nil else { return }
            AnswerFeedback.play(isCorrect: option.correct, showsReward: false)
            if option.correct {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.55)) { picked = index }
            } else {
                withAnimation(.default.repeatCount(4, autoreverses: true).speed(6)) { shaking = index }
                Task {
                    try? await Task.sleep(for: .milliseconds(400))
                    shaking = nil
                }
            }
        }
        .accessibilityLabel(Text(verbatim: option.flag))
    }
}

// MARK: - 2. sayfa: 3B clay maskotlu iridesan ünvan madalyası + ünvan yükseliş animasyonu

private struct IntroPageMedal: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dragAngle: Double = 0
    /// Gösterilen ünvan (GeoLevel.allCases sırası) ve içinde bulunduğu ünvan aralığındaki doluluk (0...1).
    @State private var levelIndex = 1
    @State private var progress: Double = 0.5

    /// Animasyon Çaylak → Gezgin → Maceracı → Yol Ustası'nı gezer; sonra başa döner.
    private let shownLevels = 4
    private let fillDuration = 2.6

    private var level: GeoLevel { GeoLevel.allCases[levelIndex] }
    private var nextLevel: GeoLevel { GeoLevel.allCases[min(levelIndex + 1, GeoLevel.allCases.count - 1)] }
    private var lowerBound: Int { levelIndex == 0 ? 0 : GameRules.levelThresholds[levelIndex - 1] }
    private var upperBound: Int { GameRules.levelThresholds[min(levelIndex, GameRules.levelThresholds.count - 1)] }

    var body: some View {
        IntroPageLayout(title: "Her gün biraz daha usta", message: "Serini koru, rozet ve kupa topla, Çaylak'tan Efsanevi Geonaut'a yüksel.") {
            TimelineView(.animation(paused: reduceMotion)) { context in
                let t = reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate
                let sway = 16 * sin(t * 1.5)

                ZStack(alignment: .top) {
                    medal
                        .rotation3DEffect(.degrees(sway + dragAngle), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
                        .shadow(color: .black.opacity(0.18), radius: 14, y: 10)

                    IntroChip(text: "7 gün", color: .white, symbol: "flame.fill", symbolColor: GeoColor.accentPrimary)
                        .rotationEffect(.degrees(-8))
                        .offset(x: -116, y: 30 + 5 * sin(t * 1.3))
                    IntroChip(text: "+100 puan", color: GeoColor.accentHighlight)
                        .rotationEffect(.degrees(7))
                        .offset(x: 112, y: 62 + 5 * sin(t * 1.1 + 1))

                    levelCard
                        .offset(y: 186)
                }
                .frame(width: 342, height: 300, alignment: .top)
            }
            .gesture(
                DragGesture()
                    .onChanged { dragAngle = Double($0.translation.width) * 0.5 }
                    .onEnded { _ in withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) { dragAngle = 0 } }
            )
        }
        .task { await runLevelUpLoop() }
    }

    /// Çubuk pürüzsüzce dolar; dolunca ünvan (ve rengi) değişir, çubuk sıfırlanıp sıradaki ünvana doğru yeniden dolar.
    private func runLevelUpLoop() async {
        guard !reduceMotion else { return }
        var index = 1
        levelIndex = index
        progress = 0.35
        while !Task.isCancelled {
            let remaining = 1 - progress
            withAnimation(.easeInOut(duration: fillDuration * remaining)) { progress = 1 }
            try? await Task.sleep(for: .seconds(fillDuration * remaining + 0.3))
            if Task.isCancelled { return }
            index = (index + 1) % shownLevels
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                levelIndex = index
            }
            withAnimation(.none) { progress = 0 }
            try? await Task.sleep(for: .milliseconds(250))
        }
    }

    /// Ünvan kartı: şimdiki ünvan rozeti (ünvanın rengi), altında soluk ipucu metni, simli dolan çubuk ve puan.
    private var levelCard: some View {
        VStack(spacing: 6) {
            Text(verbatim: L(level.title))
                .font(.custom(GeoFontName.balooBold, size: 16))
                .foregroundStyle(GeoColor.textPrimary)
                .padding(.horizontal, 16).padding(.vertical, 3)
                .background(level.accentColor, in: Capsule())
                .id(levelIndex)
                .transition(.scale(scale: 0.6).combined(with: .opacity))

            Text("Sıradaki ünvan: \(L(nextLevel.title))")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(GeoColor.textMuted)
                .contentTransition(.opacity)
                .id("next-\(levelIndex)")

            GlitterBar(progress: progress, color: level.accentColor, animated: !reduceMotion)
                .frame(height: 12)
                .padding(.top, 4)

            AnimatedPointsText(progress: progress, lower: lowerBound, upper: upperBound)
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
        .frame(width: 290)
        .clayBackground(.white, corner: 22)
        .animation(.easeInOut(duration: 0.4), value: levelIndex)
    }

    private var medal: some View {
        ZStack {
            Circle()
                .fill(AngularGradient(colors: [Color(hex: 0xFF9AC8), GeoColor.accentInfo, GeoColor.accentSuccess, GeoColor.accentHighlight, GeoColor.accentPrimary, Color(hex: 0xFF9AC8)], center: .center))
                .frame(width: 168, height: 168)
            Circle()
                .fill(RadialGradient(colors: [Color(hex: 0xFFF3B8), Color(hex: 0xEBC95A)], center: .topLeading, startRadius: 4, endRadius: 130))
                .frame(width: 132, height: 132)
                .overlay { Circle().strokeBorder(.white.opacity(0.7), lineWidth: 3) }
            ClayMascotView(animated: !reduceMotion)
                .frame(width: 128, height: 128)
                .offset(y: 2)
        }
    }
}

/// Puan metni: çubukla aynı anda akıcı sayar (Animatable → her karede yeniden hesaplanır).
private struct AnimatedPointsText: View, Animatable {
    var progress: Double
    let lower: Int
    let upper: Int

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        let points = lower + Int(Double(upper - lower) * min(1, max(0, progress)))
        Text("\(points) / \(upper) puan")
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(GeoColor.textSecondary)
            .monospacedDigit()
    }
}

/// Simli ilerleme çubuğu: ünvanın renginde dolgu, üstünde kayan ışık şeridi ve göz kırpan küçük parıltılar.
struct GlitterBar: View {
    var progress: Double
    var color: Color
    var animated: Bool

    private let sparkleSpots: [(x: Double, y: Double, size: CGFloat, phase: Double)] = [
        (0.10, 0.5, 7, 0.0), (0.28, 0.35, 5, 1.1), (0.45, 0.62, 6, 2.3), (0.62, 0.4, 5, 0.7), (0.80, 0.55, 7, 1.7), (0.93, 0.4, 5, 2.9)
    ]

    var body: some View {
        GeometryReader { proxy in
            let fillWidth = max(12, proxy.size.width * progress)
            ZStack(alignment: .leading) {
                Capsule().fill(GeoColor.borderSubtle)

                TimelineView(.animation(paused: !animated)) { context in
                    let t = animated ? context.date.timeIntervalSinceReferenceDate : 0
                    ZStack(alignment: .leading) {
                        Capsule().fill(LinearGradient(colors: [color.opacity(0.85), color], startPoint: .top, endPoint: .bottom))
                        // Kayan ışık şeridi
                        Rectangle()
                            .fill(LinearGradient(colors: [.clear, .white.opacity(0.55), .clear], startPoint: .leading, endPoint: .trailing))
                            .frame(width: 34)
                            .rotationEffect(.degrees(20))
                            .offset(x: CGFloat((t * 70).truncatingRemainder(dividingBy: Double(fillWidth + 60))) - 40)
                        // Parıltılar
                        ForEach(sparkleSpots.indices, id: \.self) { i in
                            let spot = sparkleSpots[i]
                            Image(systemName: "sparkle")
                                .font(.system(size: spot.size, weight: .bold))
                                .foregroundStyle(.white)
                                .opacity(0.25 + 0.75 * abs(sin(t * 2.2 + spot.phase)))
                                .position(x: fillWidth * spot.x, y: proxy.size.height * spot.y)
                        }
                    }
                    .frame(width: fillWidth)
                    .clipShape(Capsule())
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: color)
    }
}

// MARK: - 3. sayfa: dünya + yörüngede kategori çıkartmaları

private struct IntroPageWorld: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Kategori kartlarıyla aynı simge ve renkler (Bayraklar, Haritalar, Diller, Lezzetler).
    private let stickers: [(symbol: String, fill: Color)] = [
        ("flag.fill", GeoColor.accentPrimary),
        ("map.fill", GeoColor.accentInfo),
        ("character.book.closed.fill", GeoColor.accentTertiary),
        ("fork.knife", GeoColor.accentSuccess)
    ]

    var body: some View {
        IntroPageLayout(title: "Hazır mısın, Geonaut?", message: "Giriş yapmadan ilk seviyeyi hemen deneyebilirsin.") {
            TimelineView(.animation(paused: reduceMotion)) { context in
                let t = reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate
                ZStack {
                    Ellipse()
                        .strokeBorder(GeoColor.borderSubtle, style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
                        .frame(width: 320, height: 110)
                        .rotationEffect(.degrees(-14))
                        .offset(y: 70)

                    IntroGlobe(size: 200, spins: !reduceMotion)
                        .offset(y: -30)

                    ForEach(stickers.indices, id: \.self) { index in
                        let angle = t * 0.55 + Double(index) * .pi / 2
                        let depth = (sin(angle) + 1) / 2 // 0 arka, 1 ön
                        IntroSticker(symbol: stickers[index].symbol, width: 52, height: 52, rotation: Double(index * 7 - 10), corner: 26, fill: stickers[index].fill)
                            .scaleEffect(0.82 + 0.25 * depth)
                            .offset(x: 150 * cos(angle), y: 70 + 45 * sin(angle))
                            .zIndex(depth > 0.5 ? 1 : -1)
                    }
                }
            }
        }
    }
}

// MARK: - Ortak parçalar

/// Dönen 3B "clay" dünya: gerçek bir SceneKit küresi, mat (kil gibi) malzeme, yumuşak ışık ve
/// kabartmalı kıtalar. Doku kodla çizilir (ağ/ek dosya/paket yok). "Hareketi azalt" açıksa dönmez.
private struct IntroGlobe: View {
    let size: CGFloat
    var spins: Bool

    var body: some View {
        ZStack {
            Ellipse()
                .fill(.black.opacity(0.18))
                .frame(width: size * 0.62, height: size * 0.09)
                .blur(radius: 8)
                .offset(y: size * 0.56)
            ClayGlobeScene(spins: spins)
                .frame(width: size, height: size)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

private struct ClayGlobeScene: UIViewRepresentable {
    var spins: Bool

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.antialiasingMode = .multisampling4X
        view.isUserInteractionEnabled = false
        view.scene = makeScene()
        view.isPlaying = true
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        guard let globe = view.scene?.rootNode.childNode(withName: "globe", recursively: true) else { return }
        if spins, globe.action(forKey: "spin") == nil {
            globe.runAction(.repeatForever(.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 26)), forKey: "spin")
        } else if !spins {
            globe.removeAction(forKey: "spin")
        }
    }

    private func makeScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.clear

        let textures = ClayGlobeTexture.shared
        let sphere = SCNSphere(radius: 1)
        sphere.segmentCount = 96
        let material = SCNMaterial()
        material.lightingModel = .lambert               // mat, parıltısız = kil
        material.diffuse.contents = textures.color
        material.normal.contents = textures.normal      // kıtalardan üretilen kabartma (normal harita)
        material.normal.intensity = 1.0
        sphere.materials = [material]

        let globe = SCNNode(geometry: sphere)
        globe.name = "globe"
        // Dünya ekseni hafif eğik; Avrupa/Afrika/Asya karşıya bakacak şekilde başlar.
        globe.eulerAngles = SCNVector3(0.32, -0.9, 0.22)
        scene.rootNode.addChildNode(globe)

        let key = SCNNode()
        key.light = SCNLight()
        key.light?.type = .omni
        key.light?.intensity = 850
        key.light?.color = UIColor(white: 1, alpha: 1)
        key.position = SCNVector3(-2.4, 2.6, 3.6)
        scene.rootNode.addChildNode(key)

        let fill = SCNNode()
        fill.light = SCNLight()
        fill.light?.type = .ambient
        fill.light?.intensity = 420
        fill.light?.color = UIColor(red: 1, green: 0.94, blue: 0.86, alpha: 1)
        scene.rootNode.addChildNode(fill)

        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.camera?.fieldOfView = 32
        camera.position = SCNVector3(0, 0, 3.9)
        scene.rootNode.addChildNode(camera)
        return scene
    }
}

/// Equirectangular (enlem/boylam) dünya dokusu: renk + yumuşatılmış kabartma haritası. Kıtalar sadeleştirilmiş çokgenlerdir.
private final class ClayGlobeTexture {
    static let shared = ClayGlobeTexture()

    let color: UIImage
    let normal: UIImage

    private static let continents: [[(Double, Double)]] = [
        // Kuzey Amerika
        [(-168,66),(-140,70),(-95,72),(-80,65),(-62,58),(-55,50),(-67,44),(-76,35),(-81,25),(-97,26),(-97,18),(-87,21),(-83,10),(-78,8),(-92,15),(-105,22),(-117,32),(-124,40),(-125,49),(-135,58),(-150,60),(-165,60)],
        // Grönland
        [(-55,60),(-45,60),(-20,70),(-20,82),(-60,82),(-72,76)],
        // Güney Amerika
        [(-80,10),(-62,11),(-50,2),(-35,-6),(-40,-22),(-48,-28),(-58,-38),(-66,-46),(-70,-54),(-75,-48),(-72,-30),(-70,-18),(-81,-5)],
        // Avrupa
        [(-10,36),(-9,43),(-2,48),(2,51),(8,55),(10,58),(20,60),(30,70),(40,68),(40,50),(28,45),(26,40),(20,40),(14,38),(8,44),(3,43),(-5,36)],
        // Afrika
        [(-17,21),(-10,35),(10,37),(32,31),(35,28),(43,12),(51,12),(40,-5),(40,-15),(33,-26),(20,-35),(12,-18),(9,-1),(9,4),(-8,4),(-17,14)],
        // Asya
        [(40,68),(60,70),(100,76),(140,72),(170,66),(160,55),(140,48),(130,35),(122,30),(120,22),(108,10),(104,1),(98,16),(92,22),(80,8),(73,20),(66,25),(56,26),(48,30),(36,36),(36,45),(40,50)],
        // Arap Yarımadası
        [(36,30),(48,30),(57,24),(52,16),(43,13),(35,28)],
        // Avustralya
        [(114,-22),(122,-18),(137,-12),(146,-19),(153,-27),(146,-39),(135,-35),(116,-35)],
        // Japonya, Birleşik Krallık, Endonezya, Madagaskar
        [(130,31),(135,34),(141,41),(140,45),(136,36)],
        [(-6,50),(1,52),(-3,58),(-6,56)],
        [(95,5),(106,-6),(120,-8),(140,-5),(130,2),(110,2)],
        [(44,-13),(50,-15),(47,-25),(44,-22)],
        // Antarktika
        [(-180,-70),(180,-70),(180,-90),(-180,-90)]
    ]

    private init() {
        let size = CGSize(width: 1024, height: 512)
        func point(_ lon: Double, _ lat: Double) -> CGPoint {
            CGPoint(x: (lon + 180) / 360 * size.width, y: (90 - lat) / 180 * size.height)
        }
        func path() -> UIBezierPath {
            let all = UIBezierPath()
            for polygon in Self.continents {
                let p = UIBezierPath()
                p.move(to: point(polygon[0].0, polygon[0].1))
                for vertex in polygon.dropFirst() { p.addLine(to: point(vertex.0, vertex.1)) }
                p.close()
                all.append(p)
            }
            return all
        }
        let renderer = UIGraphicsImageRenderer(size: size)

        // Renk: mavi okyanus + yeşil kara (tasarım sistemi renkleri), kara kenarına hafif açık ton.
        color = renderer.image { ctx in
            UIColor(red: 0.49, green: 0.74, blue: 0.91, alpha: 1).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            let land = path()
            UIColor(red: 0.59, green: 0.89, blue: 0.76, alpha: 1).setFill()
            land.fill()
            UIColor(red: 0.78, green: 0.97, blue: 0.88, alpha: 1).setStroke()
            land.lineWidth = 3
            land.lineJoinStyle = .round
            land.stroke()
        }

        // Yükseklik: kara beyaz, deniz siyah → bulanıklaştırınca yumuşak, kabarık kil kenarlar.
        let mask = renderer.image { ctx in
            UIColor.black.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            UIColor.white.setFill()
            path().fill()
        }
        let ciContext = CIContext()
        var height = mask
        if let input = CIImage(image: mask),
           let blur = CIFilter(name: "CIGaussianBlur", parameters: [kCIInputImageKey: input, kCIInputRadiusKey: 7]),
           let output = blur.outputImage,
           let cg = ciContext.createCGImage(output, from: input.extent) {
            height = UIImage(cgImage: cg)
        }
        normal = Self.normalMap(from: height, strength: 6)
    }

    /// Gri tonlu yükseklik haritasından (Sobel benzeri farklar) normal harita üretir. Boylam yönünde sarmalanır.
    private static func normalMap(from image: UIImage, strength: Float) -> UIImage {
        guard let cg = image.cgImage else { return image }
        let w = cg.width, h = cg.height
        var gray = [UInt8](repeating: 0, count: w * h)
        gray.withUnsafeMutableBytes { buffer in
            guard let ctx = CGContext(data: buffer.baseAddress, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w,
                                      space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue) else { return }
            ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
        }
        var rgba = [UInt8](repeating: 255, count: w * h * 4)
        for y in 0..<h {
            for x in 0..<w {
                let left = Float(gray[y * w + (x + w - 1) % w]), right = Float(gray[y * w + (x + 1) % w])
                let up = Float(gray[max(y - 1, 0) * w + x]), down = Float(gray[min(y + 1, h - 1) * w + x])
                let nx = -(right - left) / 255 * strength
                let ny = (down - up) / 255 * strength
                let length = (nx * nx + ny * ny + 1).squareRoot()
                let i = (y * w + x) * 4
                rgba[i] = UInt8(max(0, min(255, (nx / length * 0.5 + 0.5) * 255)))
                rgba[i + 1] = UInt8(max(0, min(255, (ny / length * 0.5 + 0.5) * 255)))
                rgba[i + 2] = UInt8(max(0, min(255, (1 / length * 0.5 + 0.5) * 255)))
            }
        }
        guard let provider = CGDataProvider(data: Data(rgba) as CFData),
              let out = CGImage(width: w, height: h, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: w * 4,
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue),
                                provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else { return image }
        return UIImage(cgImage: out)
    }
}

/// Clay (kil) çıkartma: yumuşak, kabarık, üstte ışık yansıması, altta iç gölge ve çift gölge.
private struct IntroSticker: View {
    /// Bayrak emojisi (içerik) — ya da `symbol` verilirse SF Symbol.
    var emoji: String = ""
    var symbol: String? = nil
    var width: CGFloat
    var height: CGFloat
    var rotation: Double
    var corner: CGFloat = 18
    var fill: Color = .white

    var body: some View {
        Group {
            if let symbol {
                Image(systemName: symbol)
                    .font(.system(size: height * 0.42, weight: .bold))
                    .foregroundStyle(GeoGlyph.ink(on: fill))
            } else {
                Text(verbatim: emoji)
                    .font(.system(size: height * 0.62))
            }
        }
            .frame(width: width, height: height)
            .clayBackground(fill, corner: corner)
            .rotationEffect(.degrees(rotation))
    }
}

extension View {
    /// Clay görünümü: dolgu + üst-sol ışık kenarı + alt-sağ iç gölge + yumuşak çift gölge.
    fileprivate func clayBackground(_ fill: Color, corner: CGFloat) -> some View {
        background {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(fill)
                .overlay {
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .strokeBorder(LinearGradient(colors: [.white.opacity(0.95), .white.opacity(0)], startPoint: .topLeading, endPoint: .center), lineWidth: 3)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .strokeBorder(LinearGradient(colors: [.clear, .black.opacity(0.10)], startPoint: .center, endPoint: .bottomTrailing), lineWidth: 4)
                        .blur(radius: 1.5)
                }
                .shadow(color: .white.opacity(0.9), radius: 4, x: -3, y: -3)
                .shadow(color: .black.opacity(0.18), radius: 10, x: 4, y: 8)
        }
    }
}

private struct IntroChip: View {
    let text: LocalizedStringKey?
    var color: Color
    var symbol: String? = nil
    var symbolColor: Color = GeoColor.textPrimary
    var symbolCount = 1

    var body: some View {
        HStack(spacing: 4) {
            if let symbol {
                ForEach(0..<symbolCount, id: \.self) { _ in
                    Image(systemName: symbol).foregroundStyle(symbolColor)
                }
            }
            if let text { Text(text) }
        }
            .font(.system(size: 13, weight: .heavy))
            .foregroundStyle(GeoColor.textPrimary)
            .padding(.horizontal, 14).padding(.vertical, 7)
            .clayBackground(color, corner: 20)
    }
}

#Preview {
    IntroView(onFinish: {}, onTryAsGuest: {})
}
