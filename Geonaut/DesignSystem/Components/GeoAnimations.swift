import SwiftUI

/// Kazanma ekranlarında (rozet/kupa/tur tamamlandı) içeriğin ARKASINDA yavaşça dönen
/// yumuşak ışık huzmeleri + nefes alan bir parıltı — kullanıcı kararı: "her rozet ya da
/// kupa kazandığında kazanma ekranında arkada küçük bir ışık olsun". "Hareketi azalt"
/// erişilebilirlik ayarı açıksa dönme/nefes alma kapanır, statik parıltı kalır.
struct GeoWinGlow: View {
    var color: Color = GeoColor.accentHighlight
    var size: CGFloat = 260

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isRotating = false
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            // Dönen ışık huzmeleri: 12 dilimli, kenarlara doğru sönen açısal degrade.
            Circle()
                .fill(
                    AngularGradient(
                        gradient: Gradient(stops: (0..<12).flatMap { i -> [Gradient.Stop] in
                            let start = Double(i) / 12
                            return [
                                .init(color: color.opacity(0.0), location: start),
                                .init(color: color.opacity(0.45), location: start + 0.02),
                                .init(color: color.opacity(0.0), location: start + 0.06)
                            ]
                        } + [.init(color: color.opacity(0.0), location: 1)]),
                        center: .center
                    )
                )
                .mask(
                    RadialGradient(colors: [.black, .black.opacity(0)], center: .center, startRadius: 10, endRadius: size / 2)
                )
                .rotationEffect(.degrees(isRotating ? 360 : 0))

            // Merkezde nefes alan yumuşak parıltı.
            Circle()
                .fill(RadialGradient(colors: [color.opacity(0.55), color.opacity(0)], center: .center, startRadius: 0, endRadius: size * 0.36))
                .scaleEffect(isPulsing ? 1.08 : 0.92)
        }
        .frame(width: size, height: size)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) { isRotating = true }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) { isPulsing = true }
        }
    }
}

extension View {
    /// İçeriğin arkasına GeoWinGlow ekler (içerik boyutunu değiştirmez).
    func kasifWinGlow(color: Color = GeoColor.accentHighlight, size: CGFloat = 260) -> some View {
        background { GeoWinGlow(color: color, size: size) }
    }
}

/// Giriş ekranındaki maskot — açılırken zıplar, sonra birkaç saniyede bir tekrar zıplar;
/// dokunulunca da zıplar. Hafif "squash & stretch" (basılıp uzama) ile canlı görünür.
/// Kullanıcı kararı: ALTINDAKİ GÖLGE zıplamaz, sadece dünya zıplar — bu yüzden gölge
/// maskot görselinden ayrı (MascotBody gölgesiz görsel, gölge burada sabit bir elips).
struct GeoBouncingMascot: View {
    var size: CGFloat = 176

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var lift: CGFloat = 0
    @State private var squash: CGFloat = 1

    var body: some View {
        ZStack {
            // Sabit gölge — Figma'daki maskotun gölgesiyle aynı konum/boyut/renk (176'lık
            // kutuda merkez (88,160), 92×16, #7D8086 %15).
            Ellipse()
                .fill(Color(hex: 0x7D8086).opacity(0.15))
                .frame(width: size * 92 / 176, height: size * 16 / 176)
                .position(x: size / 2, y: size * 160 / 176)

            Image("MascotBody")
                .resizable()
                .frame(width: size, height: size)
                .scaleEffect(x: 1 / squash, y: squash, anchor: .bottom)
                .offset(y: lift)
        }
        .frame(width: size, height: size)
        .contentShape(Rectangle())
        .accessibilityHidden(true)
        .onTapGesture { Task { await jump() } }
        .task {
            guard !reduceMotion else { return }
            try? await Task.sleep(nanoseconds: 400_000_000)
            while !Task.isCancelled {
                await jump()
                try? await Task.sleep(nanoseconds: 3_500_000_000)
            }
        }
    }

    @MainActor
    private func jump() async {
        guard !reduceMotion else { return }
        // Çömel
        withAnimation(.easeIn(duration: 0.12)) { squash = 0.9 }
        try? await Task.sleep(nanoseconds: 120_000_000)
        // Zıpla
        withAnimation(.easeOut(duration: 0.22)) { lift = -26; squash = 1.08 }
        try? await Task.sleep(nanoseconds: 220_000_000)
        // İn ve yaylan
        withAnimation(.interpolatingSpring(stiffness: 260, damping: 11)) { lift = 0; squash = 1 }
    }
}

extension View {
    /// Dekoratif öğenin (yıldız vb.) olduğu yerde çok yavaş, sürekli süzülmesi — kullanıcı
    /// kararı: giriş ekranındaki yıldızlar yavaş yavaş hareket etsin. "Hareketi azalt" açıksa durur.
    func kasifFloat(dx: CGFloat = 0, dy: CGFloat = 8, duration: Double = 4, delay: Double = 0) -> some View {
        modifier(GeoFloatModifier(dx: dx, dy: dy, duration: duration, delay: delay))
    }
}

private struct GeoFloatModifier: ViewModifier {
    let dx: CGFloat, dy: CGFloat, duration: Double, delay: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var moved = false

    func body(content: Content) -> some View {
        content
            .offset(x: moved ? dx : -dx, y: moved ? dy : -dy)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true).delay(delay)) {
                    moved = true
                }
            }
    }
}

#Preview {
    VStack(spacing: 60) {
        GeoBouncingMascot()
        GeoAuthIllustration(type: .trophy).kasifWinGlow()
    }
    .padding(40)
    .background(GeoColor.bgCanvas)
}

// MARK: - Cevap geri bildirimi animasyonları

extension View {
    /// Şık cevaplandığında: doğruysa küçük "pop" (yaylanarak büyüyüp oturur), yanlışsa kısa yatay sallanma.
    /// "Hareketi azalt" açıksa hiçbir şey oynamaz (renk değişimi yine var).
    func answerStateEffect(isCorrect: Bool, isWrong: Bool) -> some View {
        modifier(AnswerStateEffect(isCorrect: isCorrect, isWrong: isWrong))
    }
}

private struct AnswerStateEffect: ViewModifier {
    let isCorrect: Bool
    let isWrong: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var scale: CGFloat = 1
    @State private var shakeX: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .offset(x: shakeX)
            .onChange(of: isCorrect) { _, correct in
                guard correct, !reduceMotion else { return }
                withAnimation(.spring(response: 0.18, dampingFraction: 0.45)) { scale = 1.07 }
                Task {
                    try? await Task.sleep(for: .milliseconds(160))
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { scale = 1 }
                }
            }
            .onChange(of: isWrong) { _, wrong in
                guard wrong, !reduceMotion else { return }
                Task {
                    for x: CGFloat in [-9, 9, -6, 6, -3, 0] {
                        withAnimation(.easeInOut(duration: 0.06)) { shakeX = x }
                        try? await Task.sleep(for: .milliseconds(60))
                    }
                }
            }
    }
}

/// Doğru cevapta "✓ +10" rozetinin yukarı süzülüp kaybolması. AnswerFeedback.play tetikler; tek bir
/// kaplama (bkz. GeonautApp) tüm quiz ekranlarını kapsar.
@Observable
final class RewardFlash {
    static let shared = RewardFlash()
    private(set) var counter = 0
    func trigger() { counter += 1 }
}

struct RewardFloatOverlay: View {
    var flash = RewardFlash.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var visible = false
    @State private var lift: CGFloat = 0

    var body: some View {
        Text("✓ +\(GameRules.pointsPerCorrectAnswer)")
            .font(.custom(GeoFontName.balooBold, size: 20))
            .foregroundStyle(GeoColor.accentSuccessText)
            .padding(.horizontal, 16).padding(.vertical, 6)
            .background(GeoColor.accentSuccess, in: Capsule())
            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
            .opacity(visible ? 1 : 0)
            .offset(y: lift)
            .padding(.top, 138)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .onChange(of: flash.counter) { _, _ in
                guard !reduceMotion else { return }
                lift = 12
                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) { visible = true; lift = 0 }
                Task {
                    try? await Task.sleep(for: .milliseconds(500))
                    withAnimation(.easeIn(duration: 0.4)) { visible = false; lift = -26 }
                }
            }
    }
}
