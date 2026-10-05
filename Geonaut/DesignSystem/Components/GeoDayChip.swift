import SwiftUI

/// Figma Design System / Bileşenler / Day Chip (node 105:383) — haftalık seri takvimi.
/// State=Completed/Active/Upcoming.
struct GeoDayChip: View {
    enum State { case completed, active, upcoming }

    let dayLabel: String
    var state: State = .upcoming

    private var diameter: CGFloat { state == .active ? 32 : 28 }

    var body: some View {
        VStack(spacing: GeoSpacing.sm) {
            Text(dayLabel)
                .font(GeoTypography.caption)
                .foregroundStyle(GeoColor.textMuted)

            Circle()
                .fill(fillColor)
                .overlay {
                    if state == .upcoming {
                        Circle().strokeBorder(GeoColor.borderSubtle, lineWidth: 1.5)
                    }
                }
                .frame(width: diameter, height: diameter)
        }
        .animation(.easeOut(duration: 0.15), value: state)
    }

    private var fillColor: Color {
        switch state {
        case .completed: GeoColor.accentSuccess
        case .active: GeoColor.accentPrimary
        case .upcoming: .clear
        }
    }
}

#Preview {
    HStack(spacing: GeoSpacing.md) {
        GeoDayChip(dayLabel: "Pt", state: .completed)
        GeoDayChip(dayLabel: "Sa", state: .active)
        GeoDayChip(dayLabel: "Ça", state: .upcoming)
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
