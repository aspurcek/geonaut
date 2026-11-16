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
    @State private var didAnswer = false
    /// Pas geçilince doğru cevap gösterilir (seçim yapılmadan) — bkz. GeoPassPill.
    var revealAnswer = false
    /// Pas hakkı hapı (üst satırda, canın solunda). Önizlemelerde nil.
    var pass: GeoPassState? = nil
    private var isAnswered: Bool { didAnswer || revealAnswer }
    @State private var tapPoint: CGPoint?
    @State private var tapWasCorrect = false

    var body: some View {
        VStack(spacing: GeoSpacing.xxl) {
            HStack(spacing: GeoSpacing.md) {
                GeoBackButton(action: onBack)
                    .padding(.horizontal, -13) // 44 pt dokunma alanı, görsel yer eskisiyle aynı
                GeoProgressBar(progress: Double(questionIndex) / Double(totalQuestions))
                if let pass { GeoPassPill(state: pass) }
                GeoStatPill(icon: .hearts, value: "\(hearts)")
            }

            Text(LocalizedStringKey(title))
                .font(.custom(GeoFontName.balooBold, size: 20))
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            if question.kind == .highlightMapSelectName {
                GeoGlyphCircle(symbol: "globe.europe.africa.fill", background: GeoColor.accentInfo, size: 44)
            } else {
                Text(GeoFlagAnswerOption.flagEmoji(for: question.country.code))
                    .font(.system(size: 90))
                    .frame(height: 130)
            }

            mapCard

            if question.kind == .flagTapMap {
                HStack(spacing: 6) {
                    Image(systemName: tapHint.icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(tapHint.tint)
                    Text(LocalizedStringKey(tapHint.text))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(GeoColor.textMuted)
                }
            } else {
                VStack(spacing: GeoSpacing.md) {
                    ForEach(question.continentOptions, id: \.self) { option in
                        GeoAnswerOption(text: option, state: optionState(for: option), action: { select(option) })
                    }
                }
            }

            // .flagTapMap kendi Spacer'ını burada paylaşıyordu; diğer iki tip (metin
            // şıklı) olmadan ekranın altında boş alan kalıyordu (bkz. kullanıcı geri
            // bildirimi "FULL PAGE OLMALI").
            Spacer(minLength: 0)
        }
        .padding(.horizontal, GeoSpacing.xl)
        .padding(.top, GeoSpacing.lg)
        .padding(.bottom, GeoSpacing.xxxl)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
    }

    private var title: String {
        switch question.kind {
        case .highlightMapSelectName: "Bu kıta hangisi?"
        case .flagWithHintMap: "Bu bayrak hangi kıtada?"
        case .flagTapMap: "Bu bayrak hangi ülkeye ait? Haritada yerini işaretle"
        }
    }

    private var tapHint: (icon: String, tint: Color, text: String) {
        guard isAnswered else { return ("hand.tap.fill", GeoColor.textMuted, "Ülkenin bulunduğu yere dokun") }
        return tapWasCorrect
            ? ("checkmark.circle.fill", GeoColor.accentSuccessStrong, "Doğru!")
            : ("xmark.circle.fill", GeoColor.accentDanger, "Doğru bölge işaretlendi")
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
                .clipShape(RoundedRectangle(cornerRadius: GeoRadius.lg))

        case .flagWithHintMap:
            Image("ContinentMap-\(MapQuizQuestion.mapAssetKey(for: question.correctContinent))")
                .resizable()
                .aspectRatio(Self.mapAspectRatio, contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: 160)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: GeoRadius.lg))

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
                        .fill((tapWasCorrect ? GeoColor.accentSuccessStrong : GeoColor.accentDanger).opacity(0.35))
                        .frame(width: 28, height: 28)
                        .position(tapPoint)
                }

                if isAnswered && !tapWasCorrect {
                    // Kenar Durum: yanlış dokunulursa doğru bölge anlık vurgulanır.
                    Ellipse()
                        .fill(GeoColor.accentSuccess.opacity(0.5))
                        .frame(
                            width: question.country.mapHalfSize.width * 2 * w,
                            height: question.country.mapHalfSize.height * 2 * h
                        )
                        .position(x: question.country.mapCenter.x * w, y: question.country.mapCenter.y * h)
                }
            }
            .frame(width: w, height: h)
            .clipShape(RoundedRectangle(cornerRadius: GeoRadius.lg))
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
                didAnswer = true
                onAnswer(correct)
            }
        }
        .aspectRatio(Self.mapAspectRatio, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: GeoRadius.lg))
    }

    private func select(_ option: String) {
        guard !isAnswered else { return }
        selectedOption = option
        didAnswer = true
        onAnswer(option == question.correctContinent)
    }

    private func optionState(for option: String) -> GeoAnswerOption.State {
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
