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
    @State private var isAnswered = false

    var body: some View {
        VStack(spacing: KasifSpacing.xxl) {
            HStack(spacing: KasifSpacing.md) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(KasifColor.textPrimary)
                }
                KasifProgressBar(progress: Double(questionIndex) / Double(totalQuestions))
                KasifStatPill(icon: .hearts, value: "\(hearts)")
            }

            Text(question.stimulus == .flag ? "Bu ülkenin ana dili nedir?" : "Haritadaki ülkenin ana dili nedir?")
                .font(.custom(KasifFontName.balooBold, size: 20))
                .foregroundStyle(KasifColor.textPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            switch question.stimulus {
            case .flag:
                Text(KasifFlagAnswerOption.flagEmoji(for: question.countryCode))
                    .font(.system(size: 130))
                    .frame(height: 220)
            case .map:
                mapCard
                    .frame(height: 220)
            }

            VStack(spacing: KasifSpacing.md) {
                ForEach(question.options, id: \.self) { option in
                    KasifAnswerOption(text: option, state: state(for: option), action: { select(option) })
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, KasifSpacing.xl)
        .padding(.top, KasifSpacing.lg)
        .padding(.bottom, KasifSpacing.xxxl)
        .background(KasifColor.bgCanvas)
    }

    /// Önce elle hazırlanmış `CountryMap-<kod>` varsa onu gösterir (17 ülke, oyunun
    /// çizgi-illüstrasyon diliyle uyumlu); yoksa CountryCoordinates'teki gerçek
    /// enlem/boylamla canlı bir MapKit haritası gösterir (bkz. KasifLiveCountryMap) —
    /// bu, tüm 249 ülkeyi kapsadığı için ikinci dal pratikte hep bir sonuç bulur.
    @ViewBuilder
    private var mapCard: some View {
        Group {
            if UIImage(named: "CountryMap-\(question.countryCode)") != nil {
                Image("CountryMap-\(question.countryCode)")
                    .resizable()
                    .scaledToFill()
            } else if let coordinate = CountryCoordinates.coordinate(for: question.countryCode) {
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

    private func select(_ option: String) {
        guard !isAnswered else { return }
        selectedOption = option
        isAnswered = true
        onAnswer(option == question.correctLanguage)
    }

    private func state(for option: String) -> KasifAnswerOption.State {
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
