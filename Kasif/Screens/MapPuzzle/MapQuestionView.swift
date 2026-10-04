import SwiftUI

/// Figma "Soru - Kıta Seç" (Tip A: node 330:14385, Tip B: 330:16693, Tip C: 330:17000).
/// Üç soru tipini tek view'da birleştirir — bkz. Harita Bilmece Kural Kitabı böl. 04.
struct MapQuestionView: View {
    let question: MapQuizQuestion
    let questionIndex: Int
    let totalQuestions: Int
    let hearts: Int
    var onAnswer: (Bool) -> Void
    var onBack: () -> Void

    /// Dünya haritası SVG'sinin kendi en/boy oranı (633.982:545.852) — Tip C'deki
    /// dokunma koordinatlarının MapCountry.mapCenter ile aynı kesir uzayında
    /// kalması için harita her zaman bu oranda render edilir.
    private static let mapAspectRatio: CGFloat = 633.982 / 545.852

    @State private var selectedOption: String?
    @State private var isAnswered = false
    @State private var tapPoint: CGPoint?
    @State private var tapWasCorrect = false

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

            if question.kind == .highlightMapSelectName {
                Text("🌍").font(.system(size: 40)).frame(height: 40)
            } else {
                Text(KasifFlagAnswerOption.flagEmoji(for: question.country.code))
                    .font(.system(size: 90))
                    .frame(height: 130)
            }

            mapCard

            if question.kind == .flagTapMap {
                Text(LocalizedStringKey(tapHintText))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(KasifColor.textMuted)
            } else {
                VStack(spacing: KasifSpacing.md) {
                    ForEach(question.continentOptions, id: \.self) { option in
                        KasifAnswerOption(text: option, state: optionState(for: option), action: { select(option) })
                    }
                }
            }

            // .flagTapMap kendi Spacer'ını burada paylaşıyordu; diğer iki tip (metin
            // şıklı) olmadan ekranın altında boş alan kalıyordu (bkz. kullanıcı geri
            // bildirimi "FULL PAGE OLMALI").
            Spacer(minLength: 0)
        }
        .padding(.horizontal, KasifSpacing.xl)
        .padding(.top, KasifSpacing.lg)
        .padding(.bottom, KasifSpacing.xxxl)
        .background { KasifColor.bgCanvas.ignoresSafeArea() }
    }

    private var title: String {
        switch question.kind {
        case .highlightMapSelectName: "Bu kıta hangisi?"
        case .flagWithHintMap: "Bu bayrak hangi kıtada?"
        case .flagTapMap: "Bu bayrak hangi kıtada? Harita'da işaretle"
        }
    }

    private var tapHintText: String {
        guard isAnswered else { return "☝️ Doğru kıtaya dokun" }
        return tapWasCorrect ? "✓ Doğru!" : "✕ Doğru bölge işaretlendi"
    }

    @ViewBuilder
    private var mapCard: some View {
        switch question.kind {
        case .highlightMapSelectName:
            Image("ContinentMap-\(MapQuizQuestion.mapAssetKey(for: question.correctContinent))")
                .resizable()
                .aspectRatio(Self.mapAspectRatio, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: KasifRadius.lg))

        case .flagWithHintMap:
            Image("ContinentMap-\(MapQuizQuestion.mapAssetKey(for: question.correctContinent))")
                .resizable()
                .aspectRatio(Self.mapAspectRatio, contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: 160)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: KasifRadius.lg))

        case .flagTapMap:
            tappableMap
        }
    }

    private var tappableMap: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = w / Self.mapAspectRatio
            ZStack {
                Image("ContinentMap-neutral")
                    .resizable()
                    .frame(width: w, height: h)

                if let tapPoint {
                    Circle()
                        .fill((tapWasCorrect ? KasifColor.accentSuccessStrong : KasifColor.accentDanger).opacity(0.35))
                        .frame(width: 28, height: 28)
                        .position(tapPoint)
                }

                if isAnswered && !tapWasCorrect {
                    // Kenar Durum: yanlış dokunulursa doğru bölge anlık vurgulanır.
                    Ellipse()
                        .fill(KasifColor.accentSuccess.opacity(0.5))
                        .frame(
                            width: question.country.mapHalfSize.width * 2 * w,
                            height: question.country.mapHalfSize.height * 2 * h
                        )
                        .position(x: question.country.mapCenter.x * w, y: question.country.mapCenter.y * h)
                }
            }
            .frame(width: w, height: h)
            .clipShape(RoundedRectangle(cornerRadius: KasifRadius.lg))
            .contentShape(Rectangle())
            .onTapGesture { location in
                guard !isAnswered else { return }
                let fx = location.x / w
                let fy = location.y / h
                let dx = (fx - question.country.mapCenter.x) / question.country.mapHalfSize.width
                let dy = (fy - question.country.mapCenter.y) / question.country.mapHalfSize.height
                let correct = (dx * dx + dy * dy) <= 1
                tapPoint = location
                tapWasCorrect = correct
                isAnswered = true
                onAnswer(correct)
            }
        }
        .aspectRatio(Self.mapAspectRatio, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: KasifRadius.lg))
    }

    private func select(_ option: String) {
        guard !isAnswered else { return }
        selectedOption = option
        isAnswered = true
        onAnswer(option == question.correctContinent)
    }

    private func optionState(for option: String) -> KasifAnswerOption.State {
        guard isAnswered else { return .normal }
        if option == question.correctContinent { return .correct }
        if option == selectedOption { return .wrong }
        return .normal
    }
}

#Preview {
    MapQuestionView(
        question: MapQuizQuestion(kind: .flagTapMap, country: MapCountries.all[0], correctContinent: "Avrupa", continentOptions: []),
        questionIndex: 2, totalQuestions: 10, hearts: 5,
        onAnswer: { _ in }, onBack: {}
    )
}
