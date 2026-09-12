import SwiftUI

/// Figma Design System / Bileşenler / Etap Node (node 171:848). Etap Haritası'ndaki
/// zikzak yolun düğümleri — 56pt. State=Completed(yeşil tik)/Active(mercan yıldız)/Locked(gri kilit).
struct KasifEtapNode: View {
    enum State { case completed, active, locked }

    var state: State = .locked

    private var background: Color {
        switch state {
        case .completed: KasifColor.accentSuccess
        case .active: KasifColor.accentPrimary
        case .locked: KasifColor.bgLocked
        }
    }

    private var systemImage: String {
        switch state {
        case .completed: "checkmark"
        case .active: "star.fill"
        case .locked: "lock.fill"
        }
    }

    var body: some View {
        Circle()
            .fill(background)
            .frame(width: 56, height: 56)
            .overlay {
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(state == .locked ? KasifColor.textMuted : .white)
            }
    }
}

#Preview {
    HStack(spacing: KasifSpacing.lg) {
        KasifEtapNode(state: .completed)
        KasifEtapNode(state: .active)
        KasifEtapNode(state: .locked)
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
