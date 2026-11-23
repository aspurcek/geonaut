import SwiftUI

/// Yazarak cevaplanan soruların cevap alanı ("Karışık" bölümleri, bkz. TypedAnswer).
/// Oyuncu cevabı yazar, "Kontrol Et" ya da klavyedeki onay tuşuyla gönderir.
/// Cevaptan sonra alan yeşil/kırmızı olur; yanlışta ya da küçük yazım hatasında doğru yazılış gösterilir.
struct TypedAnswerField: View {
    /// Doğru cevabın ekranda gösterilen (yerelleştirilmiş) yazılışı.
    let correctText: String
    /// Ne yazılacağı: ülke kodu (ülke/başkent) ya da Türkçe dil adı (dil).
    let key: String
    var kind: TypedAnswer.Kind = .country
    var placeholder: LocalizedStringKey = "Ülkenin adını yaz"
    /// Pas geçilince doğru cevap gösterilir.
    var revealAnswer = false
    var onAnswer: (Bool) -> Void

    @State private var text = ""
    @State private var verdict: TypedAnswer.Verdict?
    @State private var submittedText: String?
    @FocusState private var isFocused: Bool

    private var isAnswered: Bool { verdict != nil || revealAnswer }
    private var canSubmit: Bool { !isAnswered && !text.trimmingCharacters(in: .whitespaces).isEmpty }

    private var borderColor: Color {
        switch verdict {
        case .exact, .closeEnough: GeoColor.accentSuccessStrong
        case .wrong: GeoColor.accentDanger
        case nil: revealAnswer ? GeoColor.iconInactive : (isFocused ? GeoColor.accentPrimary : GeoColor.borderSubtle)
        }
    }

    private var background: Color {
        switch verdict {
        case .exact, .closeEnough: GeoColor.accentSuccess
        case .wrong: GeoColor.bgSurface
        case nil: revealAnswer ? GeoColor.bgLocked : GeoColor.bgSurface
        }
    }

    private var textColor: Color {
        switch verdict {
        case .exact, .closeEnough: GeoColor.accentSuccessText
        case .wrong: GeoColor.accentDanger
        case nil: GeoColor.textPrimary
        }
    }

    /// Alanın altındaki doğru cevap satırı (yanlış, yazım hatası ya da pas).
    private var correctionText: LocalizedStringKey? {
        switch verdict {
        case .wrong: "Doğru cevap: \(correctText)"
        case .closeEnough: "Doğru yazılışı: \(correctText)"
        case .exact: nil
        case nil: revealAnswer ? "Doğru cevap: \(correctText)" : nil
        }
    }

    var body: some View {
        VStack(spacing: GeoSpacing.md) {
            HStack(spacing: GeoSpacing.sm) {
                Image(systemName: "keyboard")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isAnswered ? GeoColor.iconInactive : GeoColor.accentPrimaryStrong)
                TextField(placeholder, text: $text)
                    .focused($isFocused)
                    .font(.custom(GeoFontName.balooBold, size: 20))
                    .foregroundStyle(textColor)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .onSubmit(submit)
                    // Cevaptan sonra alan kilitlenir ama klavye kapanmaz (ekran zıplamasın).
                    .onChange(of: text) { _, new in
                        if let submittedText, new != submittedText { text = submittedText }
                    }
                if verdict == .exact || verdict == .closeEnough {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(GeoColor.accentSuccessStrong)
                } else if verdict == .wrong {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(GeoColor.accentDanger)
                }
            }
            .padding(.horizontal, GeoSpacing.lg)
            .frame(height: 60)
            .background(background, in: RoundedRectangle(cornerRadius: GeoRadius.lg))
            .overlay {
                RoundedRectangle(cornerRadius: GeoRadius.lg)
                    .strokeBorder(borderColor, lineWidth: 2)
            }
            .answerStateEffect(isCorrect: verdict == .exact || verdict == .closeEnough, isWrong: verdict == .wrong)

            if let correctionText {
                Text(correctionText)
                    .font(.custom(GeoFontName.balooBold, size: 17))
                    .foregroundStyle(verdict == .closeEnough ? GeoColor.accentSuccessText : GeoColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Button("Kontrol Et", action: submit)
                .buttonStyle(.kasifPrimary)
                .disabled(!canSubmit)
                .opacity(isAnswered ? 0 : 1)
        }
        .animation(.easeOut(duration: 0.2), value: verdict)
        .animation(.easeOut(duration: 0.2), value: revealAnswer)
        .onAppear {
            // Soru geçiş animasyonu bitmeden klavye açılınca titriyordu — kısa gecikme.
            Task {
                try? await Task.sleep(for: .milliseconds(350))
                isFocused = true
                #if DEBUG
                // Ekran görüntüsü/test: `-debugTypedInput <metin>` ilk yazılı soruya bu metni yazıp gönderir.
                if let debugText = UserDefaults.standard.string(forKey: "debugTypedInput"), !Self.debugInputUsed {
                    Self.debugInputUsed = true
                    for ch in debugText {
                        try? await Task.sleep(for: .milliseconds(120))
                        text.append(ch)
                    }
                    try? await Task.sleep(for: .milliseconds(600))
                    if UserDefaults.standard.bool(forKey: "debugTypedSubmit") { submit() }
                }
                #endif
            }
        }
        .onChange(of: revealAnswer) { _, revealed in
            if revealed { isFocused = false }
        }
    }

    #if DEBUG
    private static var debugInputUsed = false
    #endif

    private func submit() {
        guard canSubmit else { return }
        let result = TypedAnswer.check(text, key: key, kind: kind)
        submittedText = text
        verdict = result
        onAnswer(result != .wrong)
    }
}

#Preview {
    VStack {
        TypedAnswerField(correctText: "Arjantin", key: "AR", onAnswer: { _ in })
    }
    .padding(GeoSpacing.xl)
    .background(GeoColor.bgCanvas)
}
