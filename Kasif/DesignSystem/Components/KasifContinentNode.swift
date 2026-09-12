import SwiftUI

/// Figma Design System / Bileşenler / Continent Node (node 23:37). Ana Sayfa'daki
/// kıta yolunun düğümleri. State=Completed/Active/Locked — Active durumu diğerlerinden
/// büyük (84pt vs 72pt) ve accentPrimary renginde, dikkat çekmesi için.
struct KasifContinentNode: View {
    enum State { case completed, active, locked }

    let title: String
    var systemImage: String = "globe"
    var state: State = .locked

    private var diameter: CGFloat { state == .active ? 84 : 72 }

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
                        .font(.system(size: state == .active ? 30 : 26, weight: .semibold))
                        .foregroundStyle(state == .locked ? KasifColor.textMuted : .white)
                }

            Text(title)
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
