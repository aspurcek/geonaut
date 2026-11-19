import SwiftUI

/// "YENİ ÜNVAN / YENİ ROZET / YENİ KUPA" etiketi — tebrik ekranlarının en üstünde (Figma FLOW7).
struct AchievementChip: View {
    let text: LocalizedStringKey
    var color: Color = GeoColor.accentSuccess

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .heavy))
            .tracking(1.2)
            .foregroundStyle(GeoColor.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 5)
            .background(color, in: Capsule())
    }
}

/// Ekranın üst kısmına serpiştirilmiş sabit konfeti parçaları (Figma FLOW7). Dokunuşları engellemez.
struct AchievementConfetti: View {
    private struct Piece {
        let x: CGFloat, y: CGFloat, size: CGFloat, color: Color, isBar: Bool, angle: Double
    }

    private let pieces: [Piece] = [
        Piece(x: 0.10, y: 0.09, size: 10, color: GeoColor.accentSuccess, isBar: true, angle: 0),
        Piece(x: 0.23, y: 0.19, size: 8, color: GeoColor.accentInfo, isBar: false, angle: 0),
        Piece(x: 0.82, y: 0.08, size: 12, color: GeoColor.accentHighlight, isBar: false, angle: 0),
        Piece(x: 0.74, y: 0.21, size: 8, color: GeoColor.accentPrimary, isBar: true, angle: 20),
        Piece(x: 0.15, y: 0.30, size: 12, color: GeoColor.accentTertiary, isBar: false, angle: 0),
        Piece(x: 0.87, y: 0.32, size: 9, color: GeoColor.accentSuccess, isBar: false, angle: 0),
        Piece(x: 0.38, y: 0.05, size: 8, color: GeoColor.accentHighlight, isBar: true, angle: 45),
        Piece(x: 0.62, y: 0.14, size: 10, color: GeoColor.accentPrimary, isBar: false, angle: 0),
        Piece(x: 0.05, y: 0.21, size: 9, color: GeoColor.accentInfo, isBar: false, angle: 0),
        Piece(x: 0.92, y: 0.19, size: 8, color: GeoColor.accentHighlight, isBar: true, angle: 70),
        Piece(x: 0.30, y: 0.38, size: 7, color: GeoColor.accentSuccess, isBar: false, angle: 0),
        Piece(x: 0.70, y: 0.37, size: 10, color: GeoColor.accentInfo, isBar: true, angle: 35)
    ]

    @State private var visible = false

    var body: some View {
        GeometryReader { proxy in
            ForEach(pieces.indices, id: \.self) { index in
                let piece = pieces[index]
                Group {
                    if piece.isBar {
                        RoundedRectangle(cornerRadius: 1.5)
                            .frame(width: piece.size * 0.55, height: piece.size * 1.6)
                    } else {
                        Circle().frame(width: piece.size, height: piece.size)
                    }
                }
                .foregroundStyle(piece.color)
                .rotationEffect(.degrees(piece.angle))
                .position(x: proxy.size.width * piece.x, y: proxy.size.height * piece.y + (visible ? 0 : -24))
                .opacity(visible ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.04), value: visible)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear { visible = true }
    }
}

private struct AchievementCelebration: ViewModifier {
    let confetti: Bool
    @State private var soundPlayed = false

    func body(content: Content) -> some View {
        content
            .overlay { if confetti { AchievementConfetti() } }
            .onAppear {
                // Ekran yeniden çizilse de başarı sesi yalnızca bir kez çalar.
                guard !soundPlayed else { return }
                soundPlayed = true
                SoundPlayer.play(.success)
            }
    }
}

extension View {
    /// Tebrik ekranı davranışı: açılırken kısa başarı sesi (Ayarlar'dan kapatılabilir) ve isteğe bağlı konfeti.
    func achievementCelebration(confetti: Bool = false) -> some View {
        modifier(AchievementCelebration(confetti: confetti))
    }
}
