import SwiftUI

/// Figma Design System / Bileşenler / Day Chip (node 105:383) — haftalık seri takvimi.
/// State=Completed/Active/Upcoming.
struct KasifDayChip: View {
    enum State { case completed, active, upcoming }

    let dayLabel: String
    var state: State = .upcoming

    private var diameter: CGFloat { state == .active ? 32 : 28 }

    var body: some View {
        VStack(spacing: KasifSpacing.sm) {
            Text(dayLabel)
                .font(KasifTypography.caption)
                .foregroundStyle(KasifColor.textMuted)

            Circle()
                .fill(fillColor)
                .overlay {
                    if state == .upcoming {
                        Circle().strokeBorder(KasifColor.borderSubtle, lineWidth: 1.5)
                    }
                }
                .frame(width: diameter, height: diameter)
        }
        .animation(.easeOut(duration: 0.15), value: state)
    }

    private var fillColor: Color {
        switch state {
        case .completed: KasifColor.accentSuccess
        case .active: KasifColor.accentPrimary
        case .upcoming: .clear
        }
    }
}

#Preview {
    HStack(spacing: KasifSpacing.md) {
        KasifDayChip(dayLabel: "Pt", state: .completed)
        KasifDayChip(dayLabel: "Sa", state: .active)
        KasifDayChip(dayLabel: "Ça", state: .upcoming)
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
