import SwiftUI

// MARK: - Ortak parçalar

/// Düello avatarı: oyuncunun kendi Geonaut avatarı (maç verisinden), istenen boyutta.
struct DuelAvatar: View {
    let info: DuelPlayerInfo?
    var size: CGFloat = 84

    var body: some View {
        GeoAvatar(backgroundColor: Color(hex: info?.avatarColorHex ?? GeoColor.avatarSwatches[2].hex),
                  character: info?.character ?? AvatarCharacter())
            .scaleEffect(size / 104)
            .frame(width: size, height: size)
    }
}

private struct DuelChip: View {
    let text: LocalizedStringKey
    var background: Color
    var foreground: Color = GeoColor.textPrimary

    var body: some View {
        Text(text)
            .font(.custom(GeoFontName.balooExtraBold, size: 13))
            .foregroundStyle(foreground)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(background, in: Capsule())
    }
}

// MARK: - Akış (tam ekran): Sıra sende → Sorular → Sonuç / Gönderildi

/// Bir düellonun baştan sona akışı — Arkadaşlar ekranının üstünde tam ekran açılır.
/// "Geri Dön" / geri okları Arkadaşlar ekranına döner (kullanıcı kararı 2026-11-15).
struct DuelFlowView: View {
    let context: DuelManager.PlayContext
    var onClose: () -> Void
    /// Rövanş: aynı rakibe yeni düello.
    var onRematch: (DuelManager.PlayContext, String) -> Void

    private enum Step { case intro, playing, submitting, sent, result }
    @State private var step: Step = .intro
    private var manager = DuelManager.shared

    init(context: DuelManager.PlayContext, onClose: @escaping () -> Void, onRematch: @escaping (DuelManager.PlayContext, String) -> Void) {
        self.context = context
        self.onClose = onClose
        self.onRematch = onRematch
    }

    var body: some View {
        Group {
            switch step {
            case .intro:
                DuelIntroView(context: context, onBack: onClose, onStart: { withAnimation { step = .playing } })
            case .playing:
                DuelPlayView(context: context) { result in
                    step = .submitting
                    Task {
                        await manager.submit(context, result: result)
                        withAnimation { step = manager.resultToShow?.id == context.id ? .result : .sent }
                    }
                }
            case .submitting:
                ZStack {
                    GeoColor.bgCanvas.ignoresSafeArea()
                    ProgressView().tint(GeoColor.accentPrimary)
                }
            case .sent:
                DuelSentView(opponentName: context.opponentName, onBack: onClose)
            case .result:
                if let result = manager.resultToShow {
                    DuelResultView(result: result,
                                   onRematch: { manager.resultToShow = nil; onRematch(context, result.opponentID) },
                                   onBack: { manager.resultToShow = nil; onClose() })
                }
            }
        }
        .onAppear { manager.activeFlowID = context.id }
        .onDisappear { if manager.activeFlowID == context.id { manager.activeFlowID = nil } }
    }
}

// MARK: - Sıra sende

struct DuelIntroView: View {
    let context: DuelManager.PlayContext
    var onBack: () -> Void
    var onStart: () -> Void

    private var categories: [String] {
        var seen: [String] = []
        for q in context.questions {
            let title: String = switch q.kind {
            case .flag: "Bayraklar"
            case .capital: "Başkentler"
            case .language: "Diller"
            case .food: "Lezzetler"
            case .continent: "Haritalar"
            }
            if !seen.contains(title) { seen.append(title) }
        }
        return seen
    }

    var body: some View {
        VStack(spacing: GeoSpacing.lg) {
            GeoScreenHeader(title: "Düello", onBack: onBack)

            VStack(spacing: GeoSpacing.lg) {
                HStack(alignment: .top, spacing: 18) {
                    player(context.me, name: L("Sen"), chip: "Sıra sende", chipColor: GeoColor.accentPrimaryStrong)
                    Text(verbatim: "VS")
                        .font(.custom(GeoFontName.balooExtraBold, size: 17))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(GeoColor.accentPrimary, in: Circle())
                        .overlay { Circle().strokeBorder(GeoColor.bgSurface, lineWidth: 3) }
                        .padding(.top, 18)
                    player(context.opponent, name: context.opponentName,
                           chip: context.opponentResult == nil ? "Bekliyor" : "Oynadı",
                           chipColor: context.opponentResult == nil ? GeoColor.textMuted : GeoColor.accentSuccessStrong)
                }
                Text(context.opponentResult == nil
                     ? LocalizedStringKey("Önce sen oyna; sıra sonra \(context.opponentName)'e geçecek.")
                     : LocalizedStringKey("\(context.opponentName) düellosunu bitirdi. Skorunu görmek için sen de oyna!"))
                    .font(GeoTypography.bodySemibold)
                    .foregroundStyle(GeoColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, GeoSpacing.xl)
            .padding(.horizontal, GeoSpacing.lg)
            .frame(maxWidth: .infinity)
            .background(GeoColor.accentTertiary, in: RoundedRectangle(cornerRadius: GeoRadius.xl))

            VStack(alignment: .leading, spacing: GeoSpacing.sm) {
                Label("\(DuelRules.questionCount) soru · soru başına \(DuelRules.secondsPerQuestion) saniye", systemImage: "timer")
                    .labelStyle(DuelRuleLabelStyle(tint: GeoColor.accentInfoStrong))
                Label("Önce doğru sayısı, eşitse süre kazandırır", systemImage: "trophy.fill")
                    .labelStyle(DuelRuleLabelStyle(tint: GeoColor.accentPrimaryStrong))
                Text("Sorular ikinizin de tamamladığı kategorilerden:")
                    .font(GeoTypography.caption)
                    .foregroundStyle(GeoColor.textMuted)
                GeoFlowLayout(horizontalSpacing: GeoSpacing.sm, verticalSpacing: GeoSpacing.sm) {
                    ForEach(categories, id: \.self) { title in
                        DuelChip(text: LocalizedStringKey(title), background: GeoColor.bgCanvas)
                    }
                }
            }
            .padding(GeoSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: GeoRadius.lg))

            Spacer(minLength: 0)

            Button(action: onStart) {
                Label("Düelloya başla", systemImage: "bolt.fill").frame(maxWidth: .infinity)
            }
            .buttonStyle(.kasifPrimary)

            Text("Can ve pas yok, puan kaybetmezsin. Kazanana +\(DuelRules.winReward), oynayana +\(DuelRules.playReward) puan.")
                .font(GeoTypography.caption)
                .foregroundStyle(GeoColor.textMuted)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, GeoSpacing.xl)
        .padding(.top, GeoSpacing.md)
        .padding(.bottom, GeoSpacing.sm)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
    }

    private func player(_ info: DuelPlayerInfo?, name: String, chip: LocalizedStringKey, chipColor: Color) -> some View {
        VStack(spacing: 6) {
            DuelAvatar(info: info, size: 84)
            Text(name)
                .font(GeoTypography.title)
                .foregroundStyle(GeoColor.textPrimary)
                .lineLimit(1)
            DuelChip(text: chip, background: chipColor, foreground: .white)
        }
        .frame(width: 110)
    }
}

private struct DuelRuleLabelStyle: LabelStyle {
    let tint: Color
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: GeoSpacing.sm) {
            configuration.icon.foregroundStyle(tint).font(.system(size: 15, weight: .bold))
            configuration.title.font(GeoTypography.bodySemibold).foregroundStyle(GeoColor.textPrimary)
        }
    }
}

// MARK: - Sorular (15 sn)

struct DuelPlayView: View {
    let context: DuelManager.PlayContext
    var onFinished: (DuelResult) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var index = 0
    @State private var answers: [Bool] = []
    @State private var totalMs = 0
    @State private var questionStart = Date()
    @State private var selected: String?
    @State private var remaining = DuelRules.secondsPerQuestion
    @State private var confirmingExit = false
    @State private var finished = false

    private static let timedOut = "∅"
    private var question: DuelQuestion { context.questions[min(index, context.questions.count - 1)] }
    private var isAnswered: Bool { selected != nil }

    var body: some View {
        VStack(spacing: GeoSpacing.lg) {
            // Üst satır: geri | skor | soru sayacı (tek ilerleme göstergesi süre halkası — kullanıcı kararı)
            HStack {
                GeoBackButton { confirmingExit = true }
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 8) {
                    DuelAvatar(info: context.me, size: 26)
                    Text(verbatim: "\(answers.filter { $0 }.count)")
                        .font(.custom(GeoFontName.balooExtraBold, size: 16))
                    Text(verbatim: "–").foregroundStyle(GeoColor.textMuted)
                    Text(verbatim: "?")
                        .font(.custom(GeoFontName.balooExtraBold, size: 16))
                        .foregroundStyle(GeoColor.textMuted)
                    DuelAvatar(info: context.opponent, size: 26)
                }
                .foregroundStyle(GeoColor.textPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(GeoColor.bgSurface, in: Capsule())
                .fixedSize()
                .layoutPriority(1)
                HStack(spacing: 1) {
                    Text(verbatim: "\(index + 1)").font(.custom(GeoFontName.balooExtraBold, size: 16)).foregroundStyle(GeoColor.textPrimary)
                    Text(verbatim: "/\(context.questions.count)").font(.custom(GeoFontName.balooBold, size: 14)).foregroundStyle(GeoColor.textMuted)
                }
                .monospacedDigit()
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(GeoColor.bgSurface, in: Capsule())
                .overlay { Capsule().strokeBorder(GeoColor.borderSubtle, lineWidth: 1.5) }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }

            timerRing

            Text(LocalizedStringKey(question.prompt))
                .font(.custom(GeoFontName.balooBold, size: 20))
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)

            stimulus
                .frame(height: 150)

            VStack(spacing: GeoSpacing.md) {
                ForEach(question.options, id: \.self) { option in
                    GeoAnswerOption(text: question.label(for: option), state: state(for: option)) { select(option) }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, GeoSpacing.xl)
        .padding(.top, GeoSpacing.md)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
        .id(index)
        .task(id: index) { await runTimer() }
        .alert("Düellodan çıkılsın mı?", isPresented: $confirmingExit) {
            Button("Devam et", role: .cancel) {}
            Button("Çık", role: .destructive) { quit() }
        } message: {
            Text("Düellodan çıkarsan cevaplamadığın sorular yanlış sayılır.")
        }
    }

    private var timerRing: some View {
        ZStack {
            Circle().stroke(GeoColor.bgLocked, lineWidth: 6)
            Circle()
                .trim(from: 0, to: Double(remaining) / Double(DuelRules.secondsPerQuestion))
                .stroke(remaining <= 5 ? GeoColor.accentDanger : GeoColor.accentPrimary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : .linear(duration: 1), value: remaining)
            VStack(spacing: -4) {
                Text(verbatim: "\(remaining)")
                    .font(.custom(GeoFontName.balooExtraBold, size: 22))
                    .foregroundStyle(GeoColor.textPrimary)
                    .contentTransition(.numericText())
                Text("sn")
                    .font(GeoTypography.captionSmall)
                    .foregroundStyle(GeoColor.textMuted)
            }
        }
        .frame(width: 64, height: 64)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Kalan süre: \(remaining) saniye"))
    }

    @ViewBuilder
    private var stimulus: some View {
        switch question.kind {
        case .flag:
            Text(GeoFlagAnswerOption.flagEmoji(for: question.code)).font(.system(size: 100))
        case .capital, .language, .continent:
            VStack(spacing: GeoSpacing.sm) {
                Text(GeoFlagAnswerOption.flagEmoji(for: question.code)).font(.system(size: 76))
                Text(question.countryName)
                    .font(.custom(GeoFontName.balooExtraBold, size: 24))
                    .foregroundStyle(GeoColor.textPrimary)
            }
        case .food:
            if let image = WorldFoods.image(for: question.code, type: .yemek) {
                Image(image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: 150)
                    .clipShape(RoundedRectangle(cornerRadius: GeoRadius.lg))
            } else {
                VStack(spacing: GeoSpacing.sm) {
                    GeoGlyphCircle(symbol: "fork.knife", background: GeoColor.accentPrimary, size: 56)
                    Text(D(WorldFoods.item(for: question.code, type: .yemek) ?? ""))
                        .font(.custom(GeoFontName.balooExtraBold, size: 26))
                        .foregroundStyle(GeoColor.textPrimary)
                }
            }
        }
    }

    private func state(for option: String) -> GeoAnswerOption.State {
        guard isAnswered else { return .normal }
        // Süre bitti (cevap yok): doğru şık gri ve onaylı gösterilir, başarı gibi yeşil değil.
        if option == question.answer { return selected == Self.timedOut ? .revealed : .correct }
        if option == selected { return .wrong }
        return .normal
    }

    private func select(_ option: String) {
        guard !isAnswered, !finished else { return }
        record(option)
    }

    /// Cevap (ya da süre doldu: nil) — süreyi ekle, doğru cevabı göster, sıradakine geç.
    private func record(_ option: String?) {
        let elapsed = min(Int(Date().timeIntervalSince(questionStart) * 1000), DuelRules.secondsPerQuestion * 1000)
        let correct = option == question.answer
        selected = option ?? Self.timedOut
        totalMs += option == nil ? DuelRules.secondsPerQuestion * 1000 : elapsed
        answers.append(correct)
        AnswerFeedback.play(isCorrect: correct, showsReward: false)
        Task {
            try? await Task.sleep(for: .milliseconds(900))
            next()
        }
    }

    private func next() {
        if index + 1 >= context.questions.count {
            finish()
        } else {
            selected = nil
            remaining = DuelRules.secondsPerQuestion
            questionStart = Date()
            index += 1
        }
    }

    private func runTimer() async {
        questionStart = Date()
        remaining = DuelRules.secondsPerQuestion
        while remaining > 0 {
            try? await Task.sleep(for: .seconds(1))
            if Task.isCancelled || isAnswered || finished { return }
            remaining -= 1
        }
        if !isAnswered && !finished { record(nil) }
    }

    /// Çıkış: cevaplanmayanlar yanlış ve tam süre sayılır.
    private func quit() {
        let left = context.questions.count - answers.count
        answers += Array(repeating: false, count: max(0, left))
        totalMs += max(0, left) * DuelRules.secondsPerQuestion * 1000
        finish()
    }

    private func finish() {
        guard !finished else { return }
        finished = true
        onFinished(DuelResult(answers: Array(answers.prefix(context.questions.count)), totalMilliseconds: totalMs))
    }
}

// MARK: - Gönderildi (rakibin sırası)

struct DuelSentView: View {
    let opponentName: String
    var onBack: () -> Void

    var body: some View {
        VStack(spacing: GeoSpacing.lg) {
            Spacer()
            GeoGlyphCircle(symbol: "paperplane.fill", background: GeoColor.accentInfo, size: 88)
            Text("Sonucun gönderildi")
                .font(GeoTypography.headingL)
                .foregroundStyle(GeoColor.textPrimary)
            Text("Sıra \(opponentName)'de. O da oynayınca kazananı birlikte göreceksiniz.")
                .font(GeoTypography.bodySemibold)
                .foregroundStyle(GeoColor.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
            Button("Geri Dön", action: onBack)
                .buttonStyle(.kasifPrimary)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, GeoSpacing.xxl)
        .padding(.bottom, GeoSpacing.lg)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
    }
}

// MARK: - Sonuç (kazandın / kaybettin / berabere)

struct DuelResultView: View {
    let result: DuelManager.ResultPresentation
    var onRematch: () -> Void
    var onBack: () -> Void

    @State private var appeared = false

    private var title: LocalizedStringKey {
        switch result.outcome {
        case .won: "Sen kazandın!"
        case .lost: "Bu sefer \(result.opponent.name) kazandı"
        case .tied: "Berabere!"
        }
    }

    private var chip: (LocalizedStringKey, Color, Color) {
        switch result.outcome {
        case .won: ("DÜELLO KAZANILDI", GeoColor.accentHighlight, GeoColor.textPrimary)
        case .lost: ("DÜELLO BİTTİ", GeoColor.bgLocked, GeoColor.textSecondary)
        case .tied: ("BERABERE", GeoColor.accentTertiary, GeoColor.textPrimary)
        }
    }

    private var subtitle: LocalizedStringKey {
        let diff = abs(result.myResult.correct - result.theirResult.correct)
        switch result.outcome {
        case .won: return diff > 0 ? "\(result.opponent.name)'yi \(diff) doğruyla geçtin" : "Aynı doğru sayısında daha hızlıydın"
        case .lost: return "Az kaldı! Rövanşta görüşürüz"
        case .tied: return "Doğru sayısı da süre de eşit"
        }
    }

    var body: some View {
        VStack(spacing: GeoSpacing.lg) {
            DuelChip(text: chip.0, background: chip.1, foreground: chip.2)
                .padding(.top, GeoSpacing.xxl)
            Text(title)
                .font(.custom(GeoFontName.balooExtraBold, size: result.outcome == .lost ? 28 : 34))
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)

            HStack(alignment: .bottom, spacing: 22) {
                player(result.me, name: L("Sen"), winner: result.outcome == .won, tied: result.outcome == .tied)
                player(result.opponent, name: result.opponent.name, winner: result.outcome == .lost, tied: result.outcome == .tied)
            }
            .background {
                if result.outcome != .lost { GeoWinGlow(color: GeoColor.accentHighlight, size: 320) }
            }

            VStack(spacing: 0) {
                Text(verbatim: "\(result.myResult.correct) – \(result.theirResult.correct)")
                    .font(.custom(GeoFontName.balooExtraBold, size: 44))
                    .foregroundStyle(GeoColor.textPrimary)
                Text(subtitle)
                    .font(GeoTypography.bodySemibold)
                    .foregroundStyle(GeoColor.textMuted)
            }

            HStack(spacing: 6) {
                GeoGemIcon(size: 20)
                Text(verbatim: "+\(result.outcome.reward)")
                    .font(.custom(GeoFontName.balooExtraBold, size: 18))
                    .foregroundStyle(GeoColor.accentInfoStrong)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(GeoColor.accentInfo.opacity(0.3), in: Capsule())

            Spacer(minLength: 0)

            Button(action: onRematch) {
                Label(result.outcome == .tied ? "Rövanş" : "Rövanş iste", systemImage: "arrow.triangle.2.circlepath")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.kasifPrimary)
            Button(action: onBack) {
                Text("Geri Dön")
                    .font(.custom(GeoFontName.balooExtraBold, size: 17))
                    .foregroundStyle(GeoColor.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(GeoColor.bgSurface, in: Capsule())
                    .overlay { Capsule().strokeBorder(GeoColor.borderSubtle, lineWidth: 2) }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, GeoSpacing.xxl)
        .padding(.bottom, GeoSpacing.sm)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
        .modifier(DuelResultEffects(outcome: result.outcome))
        .scaleEffect(appeared ? 1 : 0.94)
        .opacity(appeared ? 1 : 0)
        .onAppear { withAnimation(.spring(duration: 0.5, bounce: 0.35)) { appeared = true } }
    }

    private func player(_ info: DuelPlayerInfo, name: String, winner: Bool, tied: Bool) -> some View {
        let big = winner || tied
        return VStack(spacing: 6) {
            if winner {
                Image(systemName: "crown.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(LinearGradient(colors: [GeoColor.accentHighlight, GeoColor.accentHighlightStrong], startPoint: .top, endPoint: .bottom))
                    .shadow(color: GeoColor.accentHighlightStrong.opacity(0.4), radius: 4, y: 2)
                    .scaleEffect(appeared ? 1 : 0.2)
                    .offset(y: appeared ? 0 : -40)
                    .animation(.spring(duration: 0.6, bounce: 0.5).delay(0.35), value: appeared)
            }
            DuelAvatar(info: info, size: big ? 118 : 84)
            Text(name)
                .font(.custom(GeoFontName.balooBold, size: big ? 20 : 17))
                .foregroundStyle(big ? GeoColor.textPrimary : GeoColor.textSecondary)
                .lineLimit(1)
        }
        .opacity(big ? 1 : 0.85)
    }
}

/// Sonuç efektleri: kazanınca konfeti + başarı sesi; rakip kazanınca kısa üzgün melodi
/// (kullanıcı isteği 2026-11-15); berabere sessiz.
private struct DuelResultEffects: ViewModifier {
    let outcome: DuelOutcome
    @State private var played = false

    func body(content: Content) -> some View {
        if outcome == .won {
            content.achievementCelebration(confetti: true)
        } else {
            content.onAppear {
                guard !played else { return }
                played = true
                if outcome == .lost { SoundPlayer.play(.lose) }
            }
        }
    }
}

// MARK: - Ana Sayfa kartı: "Düello: sıra sende"

/// Sırası gelen düello varsa Ana Sayfa'da görünen kart; yoksa hiç yer kaplamaz.
struct DuelTurnBanner: View {
    var manager = DuelManager.shared
    var onPlay: (DuelManager.Entry) -> Void
    @State private var opening = false

    private var turns: [DuelManager.Entry] { manager.entries.filter { $0.state == .yourTurn } }

    var body: some View {
        if let entry = turns.first {
            Button {
                guard !opening else { return }
                opening = true
                onPlay(entry)
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    opening = false
                }
            } label: {
                HStack(spacing: GeoSpacing.md) {
                    DuelAvatar(info: entry.opponentInfo, size: 44)
                        .overlay(alignment: .bottomTrailing) {
                            Image(systemName: "flag.2.crossed.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                                .background(GeoColor.accentPrimaryStrong, in: Circle())
                                .overlay { Circle().strokeBorder(GeoColor.bgSurface, lineWidth: 2) }
                                .offset(x: 3, y: 3)
                        }
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Düello: sıra sende")
                            .font(GeoTypography.title)
                            .foregroundStyle(GeoColor.textPrimary)
                        Text(turns.count > 1
                             ? LocalizedStringKey("\(entry.opponentName) ve \(turns.count - 1) düello daha seni bekliyor")
                             : LocalizedStringKey("\(entry.opponentName) seni bekliyor"))
                            .font(GeoTypography.bodySemibold)
                            .foregroundStyle(GeoColor.textSecondary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: GeoSpacing.sm)
                    HStack(spacing: 5) {
                        if opening {
                            ProgressView().tint(.white).controlSize(.mini)
                        } else {
                            Image(systemName: "play.fill").font(.system(size: 11, weight: .bold))
                        }
                        Text("Oyna").font(GeoTypography.bodyBold)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(GeoColor.accentPrimaryStrong, in: Capsule())
                }
                .padding(GeoSpacing.md)
                .background(GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: GeoRadius.lg))
                .overlay {
                    RoundedRectangle(cornerRadius: GeoRadius.lg)
                        .strokeBorder(GeoColor.accentPrimarySoft, lineWidth: 1.5)
                }
                .shadow(color: GeoColor.accentPrimary.opacity(0.15), radius: 8, y: 4)
            }
            .buttonStyle(.plain)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}
