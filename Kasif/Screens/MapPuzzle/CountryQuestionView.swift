import SwiftUI

/// Figma "Soru - Ülke Seç" (Tip A: node 339:15087 "Bu ülke hangisi?", Tip B: 339:15386
/// "Bu bayrak hangi ülkeye ait?"). Bkz. GameRules.CountryPuzzleStructure.
struct CountryQuestionView: View {
    let question: CountryQuizQuestion
    let questionIndex: Int
    let totalQuestions: Int
    let hearts: Int
    var onAnswer: (Bool) -> Void
    var onBack: () -> Void

    @State private var selectedCode: String?
    @State private var isAnswered = false

    var body: some View {
        VStack(spacing: KasifSpacing.xxl) {
            HStack(spacing: KasifSpacing.md) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .accessibilityLabel("Geri")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(KasifColor.textPrimary)
                }
                KasifProgressBar(progress: Double(questionIndex) / Double(totalQuestions))
                KasifStatPill(icon: .hearts, value: "\(hearts)")
            }

            Text(LocalizedStringKey(title))
                .font(.custom(KasifFontName.balooBold, size: 20))
                .foregroundStyle(KasifColor.textPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            switch question.kind {
            case .highlightMapSelectName:
                mapCard(for: question.country)
                    .frame(height: 200)

                VStack(spacing: KasifSpacing.md) {
                    ForEach(question.options, id: \.code) { option in
                        KasifAnswerOption(text: option.name, state: optionState(for: option), action: { select(option) })
                    }
                }

            case .flagWithMapChoices:
                Text(KasifFlagAnswerOption.flagEmoji(for: question.country.code))
                    .font(.system(size: 90))
                    .frame(height: 130)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: KasifSpacing.md) {
                    ForEach(question.options, id: \.code) { option in
                        KasifCountryMapOption(
                            countryCode: option.code, countryName: option.name,
                            action: { select(option) }
                        )
                        .opacity(optionOpacity(for: option))
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, KasifSpacing.xl)
        .padding(.top, KasifSpacing.lg)
        .padding(.bottom, KasifSpacing.xxxl)
        .background { KasifColor.bgCanvas.ignoresSafeArea() }
    }

    private var title: String {
        switch question.kind {
        case .highlightMapSelectName: "Bu ülke hangisi?"
        case .flagWithMapChoices: "Bu bayrak hangi ülkeye ait?"
        }
    }

    /// Önce elle hazırlanmış `CountryMap-<kod>` varsa onu kullanır (17 ülke, oyunun
    /// çizgi-illüstrasyon diliyle uyumlu); yoksa CountryCoordinates'teki gerçek
    /// enlem/boylamla canlı bir MapKit haritası gösterir (bkz. KasifLiveCountryMap) —
    /// `.extended` havuzundaki 249 ülkenin tamamı için çalışır.
    @ViewBuilder
    private func mapCard(for country: MapCountry) -> some View {
        Group {
            if UIImage(named: "CountryMap-\(country.code)") != nil {
                Image("CountryMap-\(country.code)")
                    .resizable()
                    .scaledToFill()
            } else if let coordinate = CountryCoordinates.coordinate(for: country.code) {
                KasifLiveCountryMap(latitude: coordinate.lat, longitude: coordinate.lon)
            } else {
                Image(systemName: "map.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(KasifColor.iconInactive)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: KasifRadius.lg))
        .clipped()
    }

    private func select(_ option: MapCountry) {
        guard !isAnswered else { return }
        selectedCode = option.code
        isAnswered = true
        onAnswer(option.code == question.country.code)
    }

    private func optionState(for option: MapCountry) -> KasifAnswerOption.State {
        guard isAnswered else { return .normal }
        if option.code == question.country.code { return .correct }
        if option.code == selectedCode { return .wrong }
        return .normal
    }

    private func optionOpacity(for option: MapCountry) -> Double {
        guard isAnswered, option.code != question.country.code, option.code != selectedCode else { return 1 }
        return 0.5
    }
}

#Preview {
    CountryQuestionView(
        question: CountryQuizQuestion(kind: .highlightMapSelectName, country: MapCountries.all[0], options: Array(MapCountries.all.prefix(4))),
        questionIndex: 2, totalQuestions: 10, hearts: 5,
        onAnswer: { _ in }, onBack: {}
    )
}
