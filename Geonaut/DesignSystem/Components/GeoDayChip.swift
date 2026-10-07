import SwiftUI

/// Figma Design System / Bileşenler / Day Chip (node 105:383) — haftalık seri takvimi.
/// State=Completed/Active/Upcoming.
struct GeoDayChip: View {
    enum State { case completed, playedToday, active, missed, upcoming }

    let dayLabel: String
    var state: State = .upcoming

    private var diameter: CGFloat { (state == .active || state == .playedToday) ? 32 : 28 }

    var body: some View {
        VStack(spacing: GeoSpacing.sm) {
            Text(dayLabel)
                .font(GeoTypography.caption)
                .foregroundStyle(state == .active || state == .playedToday ? GeoColor.textSecondary : GeoColor.textMuted)

            Circle()
                .fill(fillColor)
                .overlay {
                    switch state {
                    case .upcoming:
                        Circle().strokeBorder(GeoColor.borderSubtle, lineWidth: 1.5)
                    case .active:
                        Circle().strokeBorder(GeoColor.accentPrimary, lineWidth: 3)
                    case .completed:
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundStyle(.white.opacity(0.9))
                    case .playedToday:
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(.white)
                    case .missed:
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(GeoColor.textMuted)
                    }
                }
                .frame(width: diameter, height: diameter)
        }
        .animation(.easeOut(duration: 0.15), value: state)
    }

    private var fillColor: Color {
        switch state {
        case .completed: GeoColor.accentSuccess.opacity(0.5)
        case .playedToday: GeoColor.accentSuccessStrong
        case .active, .upcoming: .clear
        case .missed: GeoColor.borderSubtle.opacity(0.55)
        }
    }
}

#Preview {
    HStack(spacing: GeoSpacing.md) {
        GeoDayChip(dayLabel: "Pt", state: .completed)
        GeoDayChip(dayLabel: "Sa", state: .completed)
        GeoDayChip(dayLabel: "Ça", state: .playedToday)
        GeoDayChip(dayLabel: "Pe", state: .active)
        GeoDayChip(dayLabel: "Cu", state: .missed)
        GeoDayChip(dayLabel: "Ct", state: .upcoming)
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
