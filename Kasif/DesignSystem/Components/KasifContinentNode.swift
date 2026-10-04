import SwiftUI

/// Figma Design System / Bileşenler / Continent Node (node 23:37). Ana Sayfa'daki
/// kıta yolunun düğümleri. State=Completed/Active/Locked — accentPrimary rengiyle
/// dikkat çeken active dışında hepsi AYNI boyutta (72pt); kullanıcı kararı: active
/// eskiden daha büyüktü (84pt), bu da "Öğren" durağıyla ilk düğüm arası boşluğun ve
/// düğümler arası ritmin state'e göre değişmesine yol açıyordu (bkz. ContinentPathView).
struct KasifContinentNode: View {
    enum State { case completed, active, locked }

    let title: String
    var systemImage: String = "globe"
    var state: State = .locked

    private let diameter: CGFloat = 72

    private var background: Color {
        switch state {
        case .completed: KasifColor.accentSuccess
        case .active: KasifColor.accentPrimary
        case .locked: KasifColor.bgLocked
        }
    }

    private var iconAndText: Color {
        state == .locked ? KasifColor.textMuted : (state == .completed ? .white : .white)
    }

    var body: some View {
        VStack(spacing: KasifSpacing.sm) {
            Circle()
                .fill(background)
                .frame(width: diameter, height: diameter)
                .overlay {
                    Image(systemName: state == .completed ? "checkmark" : (state == .locked ? "lock.fill" : systemImage))
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(state == .locked ? KasifColor.textMuted : .white)
                }

            Text(LocalizedStringKey(title))
                .font(.custom(KasifFontName.balooBold, size: 14))
                .foregroundStyle(state == .locked ? KasifColor.textMuted : KasifColor.textPrimary)
        }
        .animation(.spring(duration: 0.25), value: state)
    }
}

#Preview {
    HStack(spacing: KasifSpacing.lg) {
        KasifContinentNode(title: "Avrupa", state: .completed)
        KasifContinentNode(title: "Asya", systemImage: "globe", state: .active)
        KasifContinentNode(title: "Afrika", state: .locked)
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
