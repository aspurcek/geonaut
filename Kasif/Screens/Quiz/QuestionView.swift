import SwiftUI

/// Bir soru — bkz. Bayrak Tahmin Kural Kitabı böl. 03: etap 1-5 bayrak→isim (tanıma),
/// etap 6-8 karışık yön (bayrak→isim ya da isim→bayrak, hatırlama).
struct FlagQuestion {
    enum Direction { case flagToName, nameToFlag }
    let direction: Direction
    let countryCode: String
    let countryName: String
    let options: [String] // flagToName: 4 ülke adı. nameToFlag: 4 ülke kodu (options ihmal, flagOptions kullanılır)
    var flagOptions: [String] = [] // nameToFlag için 4 ülke kodu
}

/// Figma "Soru" (node 271:5716) — tek bir quiz sorusu. Doğru/Yanlış seçildiğinde
/// Answer Option/Flag Answer Option state'leri değişir (bkz. node 271:5652, 271:5760).
struct QuestionView: View {
    let question: FlagQuestion
    let questionIndex: Int // 0...9
    let totalQuestions: Int
    let hearts: Int
    var onAnswer: (Bool) -> Void
    var onBack: () -> Void

    @State private var selectedOption: String?
    @State private var isAnswered = false

    private var isCorrect: (String) -> Bool {
        { option in
            question.direction == .flagToName ? option == question.countryName : option == question.countryCode
        }
    }

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

            Text(question.direction == .flagToName ? "Bu hangi ülkenin bayrağı?" : "\"\(question.countryName)\" bayrağı hangisi?")
                .font(.custom(KasifFontName.balooBold, size: 20))
                .foregroundStyle(KasifColor.textPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            if question.direction == .flagToName {
                Text(KasifFlagAnswerOption.flagEmoji(for: question.countryCode))
                    .font(.system(size: 130))
                    .frame(height: 220)
            }

            if question.direction == .flagToName {
                VStack(spacing: KasifSpacing.md) {
                    ForEach(question.options, id: \.self) { option in
                        KasifAnswerOption(text: option, state: state(for: option), action: { select(option) })
                    }
                }
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: KasifSpacing.md) {
                    ForEach(question.flagOptions, id: \.self) { code in
                        KasifFlagAnswerOption(countryCode: code, state: flagState(for: code), action: { select(code) })
                    }
                }
                Spacer()
            }
        }
        .padding(.horizontal, KasifSpacing.xl)
        .padding(.top, KasifSpacing.lg)
        .padding(.bottom, KasifSpacing.xxxl)
        .background(KasifColor.bgCanvas)
    }

    private func select(_ option: String) {
        guard !isAnswered else { return }
        selectedOption = option
        isAnswered = true
        onAnswer(isCorrect(option))
    }

    private func state(for option: String) -> KasifAnswerOption.State {
        guard isAnswered else { return .normal }
        if isCorrect(option) { return .correct }
        if option == selectedOption { return .wrong }
        return .normal
    }

    private func flagState(for code: String) -> KasifFlagAnswerOption.State {
        guard isAnswered else { return .normal }
        if isCorrect(code) { return .correct }
        if code == selectedOption { return .wrong }
        return .normal
    }
}

#Preview {
    QuestionView(
        question: FlagQuestion(direction: .flagToName, countryCode: "DE", countryName: "Almanya", options: ["Almanya", "Hollanda", "Belçika", "Avusturya"]),
        questionIndex: 5, totalQuestions: 10, hearts: 5,
        onAnswer: { _ in }, onBack: {}
    )
}
