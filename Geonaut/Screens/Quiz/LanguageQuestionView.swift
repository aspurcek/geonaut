import SwiftUI

/// Figma "Soru - Bayrak → Dil" / "Soru - Harita → Dil" (Ana Diller bölümü, FLOW5).
/// Her iki uyarımda da (bayrak/harita) 4 dil adı şıkkı var — bkz. LanguageQuestion.
struct LanguageQuestionView: View {
    let question: LanguageQuestion
    let questionIndex: Int
    let totalQuestions: Int
    let hearts: Int
    var onAnswer: (Bool) -> Void
    var onBack: () -> Void

    @State private var selectedOption: String?
    @State private var didAnswer = false
    /// Pas geçilince doğru cevap gösterilir (seçim yapılmadan) — bkz. GeoPassBar.
    var revealAnswer = false
    private var isAnswered: Bool { didAnswer || revealAnswer }

    var body: some View {
        VStack(spacing: GeoSpacing.xxl) {
            HStack(spacing: GeoSpacing.md) {
                GeoBackButton(action: onBack)
                    .padding(.horizontal, -13) // 44 pt dokunma alanı, görsel yer eskisiyle aynı
                GeoProgressBar(progress: Double(questionIndex) / Double(totalQuestions))
                GeoStatPill(icon: .hearts, value: "\(hearts)")
            }

            Text(question.stimulus == .flag ? LocalizedStringKey("Bu ülkenin ana dili nedir?") : LocalizedStringKey("Haritadaki ülkenin ana dili nedir?"))
                .font(.custom(GeoFontName.balooBold, size: 20))
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            switch question.stimulus {
            case .flag:
                Text(GeoFlagAnswerOption.flagEmoji(for: question.countryCode))
                    .font(.system(size: 130))
                    .frame(height: 220)
            case .map:
                mapCard
                    .frame(height: 220)
            }

            VStack(spacing: GeoSpacing.md) {
                ForEach(question.options, id: \.self) { option in
                    GeoAnswerOption(text: option, state: state(for: option), action: { select(option) })
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, GeoSpacing.xl)
        .padding(.top, GeoSpacing.lg)
        .padding(.bottom, GeoSpacing.xxxl)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
    }

    /// Önce elle hazırlanmış `CountryMap-<kod>` varsa onu gösterir (17 ülke, oyunun
    /// çizgi-illüstrasyon diliyle uyumlu); yoksa CountryCoordinates'teki gerçek
    /// enlem/boylamla canlı bir MapKit haritası gösterir (bkz. GeoLiveCountryMap) —
    /// bu, tüm 249 ülkeyi kapsadığı için ikinci dal pratikte hep bir sonuç bulur.
    @ViewBuilder
    private var mapCard: some View {
        Group {
            if UIImage(named: "CountryMap-\(question.countryCode)") != nil {
                Image("CountryMap-\(question.countryCode)")
                    .resizable()
                    .scaledToFill()
            } else if let coordinate = CountryCoordinates.coordinate(for: question.countryCode) {
                GeoLiveCountryMap(latitude: coordinate.lat, longitude: coordinate.lon)
            } else {
                Image(systemName: "map.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(GeoColor.iconInactive)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: GeoRadius.lg))
        .clipped()
    }

    private func select(_ option: String) {
        guard !isAnswered else { return }
        selectedOption = option
        didAnswer = true
        onAnswer(option == question.correctLanguage)
    }

    private func state(for option: String) -> GeoAnswerOption.State {
        guard isAnswered else { return .normal }
        if option == question.correctLanguage { return .correct }
        if option == selectedOption { return .wrong }
        return .normal
    }
}

#Preview {
    LanguageQuestionView(
        question: LanguageQuestion(stimulus: .flag, countryCode: "DE", countryName: "Almanya", correctLanguage: "Almanca", options: ["Almanca", "Flamanca", "Fransızca", "İtalyanca"]),
        questionIndex: 5, totalQuestions: 10, hearts: 5,
        onAnswer: { _ in }, onBack: {}
    )
}
