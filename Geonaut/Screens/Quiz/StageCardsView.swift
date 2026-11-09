import SwiftUI

/// Etap başı bilgi kartları — bkz. Figma "FLOW10- Bilgi Kartları" ve StageCards.
/// Her kart bir ülkeyi tanıtır (bayrak / başkent / dil / yemek). Yana kaydırılır ya da "Sonraki" ile
/// ilerlenir; "Hepsini atla" doğrudan oyunu başlatır, son kartta buton "Başla" olur.
struct StageCardsView: View {
    let cards: [InfoCard]
    var onFinish: () -> Void
    var onBack: () -> Void

    @State private var index = 0

    private var isLast: Bool { index >= cards.count - 1 }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                GeoBackButton(action: onBack)
                    .padding(.leading, -13)
                Spacer()
                Button("Hepsini atla", action: onFinish)
                    .font(.custom(GeoFontName.nunitoBold, size: 15))
                    .foregroundStyle(GeoColor.accentPrimaryStrong)
                    .frame(minHeight: 44)
                    .accessibilityHint(Text("Kartları geçip oyunu başlatır"))
            }

            progressDots
                .padding(.top, GeoSpacing.sm)
                .padding(.bottom, GeoSpacing.md)

            TabView(selection: $index) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { offset, card in
                    InfoCardPage(card: card)
                        .padding(.bottom, GeoSpacing.sm)
                        .tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            Text("\(index + 1) / \(cards.count)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(GeoColor.textMuted)
                .padding(.top, GeoSpacing.sm)

            Button {
                if isLast {
                    onFinish()
                } else {
                    withAnimation(.easeInOut(duration: 0.25)) { index += 1 }
                }
            } label: {
                // Genişlik etiketin içinde: stil zemini (hap) etiketi sardığı için dışarıdan frame verilirse buton dar kalır.
                Text(isLast ? "Başla" : "Sonraki").frame(maxWidth: .infinity)
            }
            .buttonStyle(.kasifPrimary)
            .padding(.top, GeoSpacing.sm)
            .padding(.bottom, GeoSpacing.lg)
        }
        .padding(.horizontal, GeoSpacing.xl)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
    }

    private var progressDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<cards.count, id: \.self) { i in
                Capsule()
                    .fill(i == index ? GeoColor.accentPrimary : GeoColor.bgLocked)
                    .frame(width: i == index ? 22 : 8, height: 8)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: index)
        .accessibilityHidden(true)
    }
}

/// Tek bir ülkenin kartı.
private struct InfoCardPage: View {
    let card: InfoCard

    var body: some View {
        VStack(spacing: GeoSpacing.lg) {
            Text("YENİ")
                .font(.custom(GeoFontName.nunitoBold, size: 12))
                .foregroundStyle(GeoColor.accentSuccessText)
                .padding(.horizontal, GeoSpacing.md)
                .padding(.vertical, GeoSpacing.xs)
                .background(GeoColor.accentSuccess, in: Capsule())

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(GeoSpacing.xxl)
        // Gölge yalnızca kartın zeminine: tüm görünüme verilirse içindeki yazılar da gölgelenir.
        .background {
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .shadow(color: GeoColor.textPrimary.opacity(0.08), radius: 14, x: 0, y: 6)
        }
        // Sayfa kenarında gölge kırpılmasın diye iç boşluk.
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var content: some View {
        switch card.content {
        case .flag(let caption):
            flagBlock(size: 150)
            nameText
            if let caption {
                Text(caption)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(GeoColor.textMuted)
            }
        case .capital(let capital):
            flagBlock(size: 110)
            nameText
            detail(label: "Başkent", value: capital)
        case .language(let language):
            flagBlock(size: 110)
            nameText
            detail(label: "Ana dil", value: D(language))
        case .food(let item, let image):
            foodImage(image)
            Text(item)
                .font(.custom(GeoFontName.balooExtraBold, size: 34))
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
            Text("\(GeoFlagAnswerOption.flagEmoji(for: card.code)) \(card.countryName)")
                .font(.custom(GeoFontName.nunitoBold, size: 18))
                .foregroundStyle(GeoColor.textMuted)
        }
    }

    private func flagBlock(size: CGFloat) -> some View {
        Text(GeoFlagAnswerOption.flagEmoji(for: card.code))
            .font(.system(size: size))
            .minimumScaleFactor(0.5)
            .lineLimit(1)
    }

    private var nameText: some View {
        Text(card.countryName)
            .font(.custom(GeoFontName.balooExtraBold, size: 36))
            .foregroundStyle(GeoColor.textPrimary)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.6)
    }

    private func detail(label: LocalizedStringKey, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(GeoColor.textMuted)
            Text(value)
                .font(.custom(GeoFontName.balooBold, size: 30))
                .foregroundStyle(GeoColor.accentPrimaryStrong)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)
        }
    }

    private func foodImage(_ name: String?) -> some View {
        Group {
            if let name {
                Image(name).resizable().scaledToFill()
            } else {
                Image(systemName: "fork.knife")
                    .font(.system(size: 60))
                    .foregroundStyle(GeoColor.iconInactive)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 190)
        .background(GeoColor.bgCanvas)
        .clipShape(RoundedRectangle(cornerRadius: GeoRadius.lg))
    }
}

/// Etap açılırken kart varsa önce kartları, yoksa (ya da atlanınca) oyunu gösterir.
struct StageCardsGate<Content: View>: View {
    let cards: [InfoCard]
    var onBack: () -> Void
    @ViewBuilder var content: () -> Content

    @State private var showingCards: Bool

    init(cards: [InfoCard], onBack: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.cards = cards
        self.onBack = onBack
        self.content = content
        _showingCards = State(initialValue: !cards.isEmpty)
    }

    var body: some View {
        if showingCards {
            StageCardsView(cards: cards, onFinish: { showingCards = false }, onBack: onBack)
        } else {
            content()
        }
    }
}
