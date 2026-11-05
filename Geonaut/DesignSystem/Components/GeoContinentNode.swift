import SwiftUI

/// Figma Design System / Bileşenler / Continent Node (node 23:37). Ana Sayfa'daki
/// kıta yolunun düğümleri. State=Completed/Active/Locked — accentPrimary rengiyle
/// dikkat çeken active dışında hepsi AYNI boyutta (72pt); kullanıcı kararı: active
/// eskiden daha büyüktü (84pt), bu da "Öğren" durağıyla ilk düğüm arası boşluğun ve
/// düğümler arası ritmin state'e göre değişmesine yol açıyordu (bkz. ContinentPathView).
struct GeoContinentNode: View {
    enum State { case completed, active, locked }

    let title: String
    var systemImage: String = "globe"
    var state: State = .locked

    private let diameter: CGFloat = 72
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse = false

    private var background: Color {
        switch state {
        case .completed: GeoColor.accentSuccess
        case .active: GeoColor.accentPrimary
        case .locked: GeoColor.bgLocked
        }
    }

    private var iconAndText: Color {
        state == .locked ? GeoColor.textMuted : (state == .completed ? .white : .white)
    }

    var body: some View {
        VStack(spacing: GeoSpacing.sm) {
            Circle()
                .fill(background)
                .frame(width: diameter, height: diameter)
                .background {
                    // Sıradaki düğüm: yavaşça yayılıp sönen halka (nabız) — "buradan devam et" ipucu.
                    if state == .active && !reduceMotion {
                        Circle()
                            .stroke(GeoColor.accentPrimary.opacity(0.45), lineWidth: 3)
                            .frame(width: diameter, height: diameter)
                            .scaleEffect(pulse ? 1.45 : 1)
                            .opacity(pulse ? 0 : 1)
                            .onAppear {
                                withAnimation(.easeOut(duration: 1.6).repeatForever(autoreverses: false)) { pulse = true }
                            }
                    }
                }
                .overlay {
                    Image(systemName: state == .completed ? "checkmark" : (state == .locked ? "lock.fill" : systemImage))
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(state == .locked ? GeoColor.textMuted : .white)
                }

            Text(LocalizedStringKey(title))
                .font(.custom(GeoFontName.balooBold, size: 14))
                .foregroundStyle(state == .locked ? GeoColor.textMuted : GeoColor.textPrimary)
        }
        .animation(.spring(duration: 0.25), value: state)
    }
}

#Preview {
    HStack(spacing: GeoSpacing.lg) {
        GeoContinentNode(title: "Avrupa", state: .completed)
        GeoContinentNode(title: "Asya", systemImage: "globe", state: .active)
        GeoContinentNode(title: "Afrika", state: .locked)
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
