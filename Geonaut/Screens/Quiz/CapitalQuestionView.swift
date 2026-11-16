import SwiftUI

/// Başkentler'in soru ekranı (Figma FLOW9) — soru biçimi seviyeye göre değişir, bkz. CapitalQuestion.Format:
/// bayrak (+ ülke adı) / harita → başkent şıkları; başkent adı → ülke adı ya da bayrak şıkları.
struct CapitalQuestionView: View {
    let question: CapitalQuestion
    let questionIndex: Int
    let totalQuestions: Int
    let hearts: Int
    var onAnswer: (Bool) -> Void
    var onBack: () -> Void

    @State private var selectedOption: String?
    @State private var didAnswer = false
    /// Pas geçilince doğru cevap gösterilir (seçim yapılmadan) — bkz. GeoPassPill.
    var revealAnswer = false
    /// Pas hakkı hapı (üst satırda, canın solunda). Önizlemelerde nil.
    var pass: GeoPassState? = nil
    private var isAnswered: Bool { didAnswer || revealAnswer }

    private var promptText: LocalizedStringKey {
        switch question.format {
        case .flagWithNameToCapital, .flagToCapital: "Bu ülkenin başkenti neresidir?"
        case .mapToCapital: "Haritadaki ülkenin başkenti neresidir?"
        case .capitalToCountry, .capitalToFlag: "Bu şehir hangi ülkenin başkentidir?"
        }
    }

    var body: some View {
        VStack(spacing: GeoSpacing.xxl) {
            HStack(spacing: GeoSpacing.md) {
                GeoBackButton(action: onBack)
                    .padding(.horizontal, -13) // 44 pt dokunma alanı, görsel yer eskisiyle aynı
                GeoProgressBar(progress: Double(questionIndex) / Double(totalQuestions))
                if let pass { GeoPassPill(state: pass) }
                GeoStatPill(icon: .hearts, value: "\(hearts)")
            }

            Text(promptText)
                .font(.custom(GeoFontName.balooBold, size: 20))
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            stimulus
                .frame(height: 220)

            options

            Spacer(minLength: 0)
        }
        .padding(.horizontal, GeoSpacing.xl)
        .padding(.top, GeoSpacing.lg)
        .padding(.bottom, GeoSpacing.xxxl)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
    }

    // MARK: - Soru görseli

    @ViewBuilder private var stimulus: some View {
        switch question.format {
        case .flagToCapital:
            Text(GeoFlagAnswerOption.flagEmoji(for: question.countryCode))
                .font(.system(size: 130))
        case .flagWithNameToCapital:
            VStack(spacing: GeoSpacing.md) {
                Text(GeoFlagAnswerOption.flagEmoji(for: question.countryCode))
                    .font(.system(size: 110))
                Text(D(question.countryName))
                    .font(.custom(GeoFontName.balooExtraBold, size: 26))
                    .foregroundStyle(GeoColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)
            }
        case .mapToCapital:
            mapCard
        case .capitalToCountry, .capitalToFlag:
            VStack(spacing: GeoSpacing.md) {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(GeoColor.accentHighlightStrong)
                Text(question.capitalName)
                    .font(.custom(GeoFontName.balooExtraBold, size: 32))
                    .foregroundStyle(GeoColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white, in: RoundedRectangle(cornerRadius: GeoRadius.lg))
        }
    }

    /// Önce elle hazırlanmış `CountryMap-<kod>` varsa onu, yoksa CountryCoordinates'teki gerçek enlem/boylamla canlı harita.
    @ViewBuilder private var mapCard: some View {
        Group {
            if UIImage(named: "CountryMap-\(question.countryCode)") != nil {
                Image("CountryMap-\(question.countryCode)").resizable().scaledToFill()
            } else if let coordinate = CountryCoordinates.coordinate(for: question.countryCode) {
                GeoLiveCountryMap(latitude: coordinate.lat, longitude: coordinate.lon)
            } else {
                Image(systemName: "map.fill").font(.system(size: 60)).foregroundStyle(GeoColor.iconInactive)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: GeoRadius.lg))
        .clipped()
    }

    // MARK: - Şıklar

    @ViewBuilder private var options: some View {
        if question.format == .capitalToFlag {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: GeoSpacing.md) {
                ForEach(question.options, id: \.self) { code in
                    GeoFlagAnswerOption(countryCode: code, state: flagState(for: code), action: { select(code) })
                }
            }
        } else {
            VStack(spacing: GeoSpacing.md) {
                ForEach(question.options, id: \.self) { option in
                    GeoAnswerOption(text: option, state: state(for: option), action: { select(option) })
                }
            }
        }
    }

    private func select(_ option: String) {
        guard !isAnswered else { return }
        selectedOption = option
        didAnswer = true
        onAnswer(option == question.correct)
    }

    private func state(for option: String) -> GeoAnswerOption.State {
        guard isAnswered else { return .normal }
        if option == question.correct { return .correct }
        if option == selectedOption { return .wrong }
        return .normal
    }

    private func flagState(for code: String) -> GeoFlagAnswerOption.State {
        guard isAnswered else { return .normal }
        if code == question.correct { return .correct }
        if code == selectedOption { return .wrong }
        return .normal
    }
}

#Preview {
    CapitalQuestionView(
        question: CapitalQuestion(format: .capitalToCountry, countryCode: "DE", countryName: "Almanya", capitalName: "Berlin", options: ["Almanya", "Fransa", "İtalya", "İspanya"], correct: "Almanya"),
        questionIndex: 5, totalQuestions: 10, hearts: 5,
        onAnswer: { _ in }, onBack: {}
    )
}
