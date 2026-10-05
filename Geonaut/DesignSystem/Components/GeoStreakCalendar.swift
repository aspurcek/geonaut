import SwiftUI

/// Figma Design System / Bileşenler / Streak Calendar (node 162:418). Profil ekranındaki
/// haftalık seri takvimi — 7 gün için GeoDayChip'leri bir kartta birleştirir.
struct GeoStreakCalendar: View {
    /// Pazartesi'den Pazar'a 7 kısa gün adı — uygulamanın diline göre.
    static let dayLabels: [String] = {
        let locale = DisplayName.locale
        if locale.language.languageCode?.identifier == "tr" { return ["Pt", "Sa", "Ça", "Pe", "Cu", "Ct", "Pa"] }
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        let sundayFirst = calendar.shortStandaloneWeekdaySymbols
        let mondayFirst = Array(sundayFirst.dropFirst()) + [sundayFirst[0]]
        return mondayFirst.map { symbol in
            let trimmed = symbol.replacingOccurrences(of: ".", with: "")
            return String(trimmed.prefix(2)).prefix(1).uppercased(with: locale) + String(trimmed.prefix(2)).dropFirst()
        }
    }()

    /// 7 elemanlı dizi, Pazartesi'den Pazar'a.
    let dayStates: [GeoDayChip.State]

    var body: some View {
        VStack(alignment: .leading, spacing: GeoSpacing.xl) {
            Text("Bu haftaki serin")
                .font(.custom(GeoFontName.balooBold, size: 14))
                .foregroundStyle(GeoColor.textPrimary)

            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    GeoDayChip(
                        dayLabel: Self.dayLabels[index],
                        state: index < dayStates.count ? dayStates[index] : .upcoming
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(GeoSpacing.lg)
        .background(GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 4)
    }
}

#Preview {
    GeoStreakCalendar(dayStates: [.completed, .completed, .completed, .active, .upcoming, .upcoming, .upcoming])
        .padding(GeoSpacing.xxxl)
        .background(GeoColor.bgCanvas)
}
