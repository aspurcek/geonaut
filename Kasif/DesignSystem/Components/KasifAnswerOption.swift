import SwiftUI

/// Figma Design System / Bileşenler / Answer Option (node 171:911). Soru ekranlarındaki
/// çoktan seçmeli şıklar. State=Default/Correct/Wrong.
struct KasifAnswerOption: View {
    enum State { case normal, correct, wrong }

    let text: String
    var state: State = .normal
    var action: (() -> Void)? = nil

    private var background: Color {
        state == .correct ? KasifColor.accentSuccess : KasifColor.bgSurface
    }

    private var borderColor: Color {
        switch state {
        case .normal: KasifColor.borderSubtle
        case .correct: KasifColor.accentSuccessStrong
        case .wrong: KasifColor.accentDanger
        }
    }

    private var textColor: Color {
        switch state {
        case .normal: KasifColor.textPrimary
        case .correct: KasifColor.accentSuccessText
        case .wrong: KasifColor.accentDanger
        }
    }

    var body: some View {
        Button {
            action?()
        } label: {
            Text(D(text))
                .font(.custom(KasifFontName.balooBold, size: 15))
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(background, in: RoundedRectangle(cornerRadius: KasifRadius.lg))
                .overlay {
                    RoundedRectangle(cornerRadius: KasifRadius.lg)
                        .strokeBorder(borderColor, lineWidth: 2)
                }
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
        .animation(.easeOut(duration: 0.15), value: state)
    }
}

#Preview {
    VStack(spacing: KasifSpacing.md) {
        KasifAnswerOption(text: "Ülke Adı", state: .normal) {}
        KasifAnswerOption(text: "Ülke Adı", state: .correct) {}
        KasifAnswerOption(text: "Ülke Adı", state: .wrong) {}
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
