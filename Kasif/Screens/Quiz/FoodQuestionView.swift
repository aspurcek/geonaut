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

            Text(promptText)
                .font(.custom(KasifFontName.balooBold, size: 20))
                .foregroundStyle(KasifColor.textPrimary)
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
                    Text(KasifFlagAnswerOption.flagEmoji(for: question.countryCode))
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
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: KasifSpacing.md) {
                    ForEach(question.flagOptions, id: \.self) { code in
                        KasifFlagAnswerOption(countryCode: code, state: flagState(for: code), action: { select(code) })
                    }
                }
                Spacer()

            default:
                VStack(spacing: KasifSpacing.md) {
                    ForEach(question.options, id: \.self) { option in
                        KasifAnswerOption(text: option, state: state(for: option), action: { select(option) })
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
                    .foregroundStyle(KasifColor.iconInactive)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: KasifRadius.lg))
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
        onAnswer(option == question.correctAnswer)
    }

    private func state(for option: String) -> KasifAnswerOption.State {
        guard isAnswered else { return .normal }
        if option == question.correctAnswer { return .correct }
        if option == selectedOption { return .wrong }
        return .normal
    }

    private func flagState(for code: String) -> KasifFlagAnswerOption.State {
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
