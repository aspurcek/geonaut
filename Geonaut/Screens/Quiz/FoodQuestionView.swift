import SwiftUI

/// Figma "Soru - Yemek → Ülke" / "Soru - Bayrak → Yemek" / "Soru - Harita → Yemek"
/// (Dünya Yemekleri bölümü, FLOW6). Bkz. GameRules.WorldFoodStructure etap notu: etap
/// 1-4 görsel→ülke adı (isim verilmez), etap 5 isim→4 bayrak şık, etap 6 isim→ülke adı
/// (görsel yok), etap 7-8 hepsi karışık (ülke→yemek dahil).
struct FoodQuestionView: View {
    let question: FoodQuestion
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

            Text(promptText)
                .font(.custom(GeoFontName.balooBold, size: 20))
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            switch question.style {
            case .foodImageToCountry:
                // Kullanıcı kararı (bkz. WorldFoodStructure etap 1-4 notu): isim
                // VERİLMEZ, yalnızca görsel gösterilir. makeFoodImageToCountryQuestion
                // bu stili yalnızca o TÜRDE görseli olan ülkelerden ürettiği için
                // foodImage burada garanti dolu, ama savunmacı olarak nil'e de bakılıyor.
                foodImageCard

            case .countryToFood:
                switch question.countryStimulus {
                case .flag:
                    Text(GeoFlagAnswerOption.flagEmoji(for: question.countryCode))
                        .font(.system(size: 130))
                        .frame(height: 220)
                case .map:
                    mapCard
                        .frame(height: 220)
                }

            case .foodNameToCountryFlags, .foodNameToCountryText:
                // İsim zaten promptText'te — ayrı bir uyarım kartına gerek yok
                // (bkz. WorldFoodStructure etap 5-6 notu).
                EmptyView()
            }

            switch question.style {
            case .foodNameToCountryFlags:
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: GeoSpacing.md) {
                    ForEach(question.flagOptions, id: \.self) { code in
                        GeoFlagAnswerOption(countryCode: code, state: flagState(for: code), action: { select(code) })
                    }
                }
                Spacer()

            default:
                VStack(spacing: GeoSpacing.md) {
                    ForEach(question.options, id: \.self) { option in
                        GeoAnswerOption(text: option, state: state(for: option), action: { select(option) })
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, GeoSpacing.xl)
        .padding(.top, GeoSpacing.lg)
        .padding(.bottom, GeoSpacing.xxxl)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
    }

    private var promptText: LocalizedStringKey {
        switch question.style {
        // Kullanıcı kararı: görsel gösterilen etaplarda da yemeğin adı soru
        // metninde geçsin — "Görseldeki '...' hangi ülkeye ait?" (bkz. etap 5-6'daki
        // "\"isim\" hangi ülkeye ait?" kalıbıyla aynı aile, yalnızca "Görseldeki"
        // önekiyle görsele atıf yapıyor).
        case .foodImageToCountry: "Görseldeki \"\(D(question.foodItem))\" hangi ülkeye ait?"
        case .foodNameToCountryFlags, .foodNameToCountryText: "\"\(D(question.foodItem))\" hangi ülkeye ait?"
        case .countryToFood:
            question.countryStimulus == .flag
                ? LocalizedStringKey(question.foodType.questionPrompt.flag)
                : LocalizedStringKey(question.foodType.questionPrompt.map)
        }
    }

    @ViewBuilder
    private var foodImageCard: some View {
        Group {
            if let imageName = question.foodImage {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "fork.knife")
                    .font(.system(size: 60))
                    .foregroundStyle(GeoColor.iconInactive)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: GeoRadius.lg))
        .clipped()
    }

    /// LanguageQuestionView.mapCard ile birebir aynı öncelik sırası — bkz. o
    /// dosyadaki not.
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
        onAnswer(option == question.correctAnswer)
    }

    private func state(for option: String) -> GeoAnswerOption.State {
        guard isAnswered else { return .normal }
        if option == question.correctAnswer { return .correct }
        if option == selectedOption { return .wrong }
        return .normal
    }

    private func flagState(for code: String) -> GeoFlagAnswerOption.State {
        guard isAnswered else { return .normal }
        if code == question.correctAnswer { return .correct }
        if code == selectedOption { return .wrong }
        return .normal
    }
}

#Preview {
    FoodQuestionView(
        question: FoodQuestion(
            style: .foodImageToCountry, foodType: .yemek,
            countryCode: "IT", countryName: "İtalya", foodItem: "Pizza",
            foodImage: "Food-IT", options: ["İtalya", "Meksika", "Japonya", "Türkiye"]
        ),
        questionIndex: 5, totalQuestions: 10, hearts: 5,
        onAnswer: { _ in }, onBack: {}
    )
}
