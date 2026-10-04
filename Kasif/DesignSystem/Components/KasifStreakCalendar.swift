import SwiftUI

/// Figma Design System / Bileşenler / Streak Calendar (node 162:418). Profil ekranındaki
/// haftalık seri takvimi — 7 gün için KasifDayChip'leri bir kartta birleştirir.
struct KasifStreakCalendar: View {
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
    let dayStates: [KasifDayChip.State]

    var body: some View {
        VStack(alignment: .leading, spacing: KasifSpacing.xl) {
            Text("Bu haftaki serin")
                .font(.custom(KasifFontName.balooBold, size: 14))
                .foregroundStyle(KasifColor.textPrimary)

            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    KasifDayChip(
                        dayLabel: Self.dayLabels[index],
                        state: index < dayStates.count ? dayStates[index] : .upcoming
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(KasifSpacing.lg)
        .background(KasifColor.bgSurface, in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 4)
    }
}

#Preview {
    KasifStreakCalendar(dayStates: [.completed, .completed, .completed, .active, .upcoming, .upcoming, .upcoming])
        .padding(KasifSpacing.xxxl)
        .background(KasifColor.bgCanvas)
}
