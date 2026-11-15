import SwiftUI

/// Figma Design System / Bileşenler / Answer Option (node 171:911). Soru ekranlarındaki
/// çoktan seçmeli şıklar. State=Default/Correct/Wrong/Revealed.
/// `.revealed`: oyuncu cevap veremeden (ör. düelloda süre bitti) doğru şıkkın gösterilmesi —
/// başarı gibi yeşil değil, gri ve onay işaretli (kullanıcı kararı 2026-11-15).
struct GeoAnswerOption: View {
    enum State { case normal, correct, wrong, revealed }

    let text: String
    var state: State = .normal
    var action: (() -> Void)? = nil

    private var background: Color {
        switch state {
        case .correct: GeoColor.accentSuccess
        case .revealed: GeoColor.bgLocked
        default: GeoColor.bgSurface
        }
    }

    private var borderColor: Color {
        switch state {
        case .normal: GeoColor.borderSubtle
        case .correct: GeoColor.accentSuccessStrong
        case .wrong: GeoColor.accentDanger
        case .revealed: GeoColor.iconInactive
        }
    }

    private var textColor: Color {
        switch state {
        case .normal: GeoColor.textPrimary
        case .correct: GeoColor.accentSuccessText
        case .wrong: GeoColor.accentDanger
        case .revealed: GeoColor.textSecondary
        }
    }

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 6) {
                if state == .revealed {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 15, weight: .bold))
                }
                Text(D(text))
            }
                .font(.custom(GeoFontName.balooBold, size: 15))
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(background, in: RoundedRectangle(cornerRadius: GeoRadius.lg))
                .overlay {
                    RoundedRectangle(cornerRadius: GeoRadius.lg)
                        .strokeBorder(borderColor, lineWidth: 2)
                }
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
        .animation(.easeOut(duration: 0.15), value: state)
        .answerStateEffect(isCorrect: state == .correct, isWrong: state == .wrong)
    }
}

#Preview {
    VStack(spacing: GeoSpacing.md) {
        GeoAnswerOption(text: "Ülke Adı", state: .normal) {}
        GeoAnswerOption(text: "Ülke Adı", state: .correct) {}
        GeoAnswerOption(text: "Ülke Adı", state: .wrong) {}
        GeoAnswerOption(text: "Ülke Adı", state: .revealed) {}
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
