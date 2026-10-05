import SwiftUI

/// Figma Design System / Bileşenler / Answer Option (node 171:911). Soru ekranlarındaki
/// çoktan seçmeli şıklar. State=Default/Correct/Wrong.
struct GeoAnswerOption: View {
    enum State { case normal, correct, wrong }

    let text: String
    var state: State = .normal
    var action: (() -> Void)? = nil

    private var background: Color {
        state == .correct ? GeoColor.accentSuccess : GeoColor.bgSurface
    }

    private var borderColor: Color {
        switch state {
        case .normal: GeoColor.borderSubtle
        case .correct: GeoColor.accentSuccessStrong
        case .wrong: GeoColor.accentDanger
        }
    }

    private var textColor: Color {
        switch state {
        case .normal: GeoColor.textPrimary
        case .correct: GeoColor.accentSuccessText
        case .wrong: GeoColor.accentDanger
        }
    }

    var body: some View {
        Button {
            action?()
        } label: {
            Text(D(text))
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
    }
}

#Preview {
    VStack(spacing: GeoSpacing.md) {
        GeoAnswerOption(text: "Ülke Adı", state: .normal) {}
        GeoAnswerOption(text: "Ülke Adı", state: .correct) {}
        GeoAnswerOption(text: "Ülke Adı", state: .wrong) {}
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
