import SwiftUI

// MARK: - Gece uçuşu teması (günlük hedef)

/// Günlük hedef kartları için ortak renkler — yalnızca uygulamanın paleti (GeoColor):
/// Profil başlığındaki gibi lavanta zemin + beyaz yıldızlar; hedef halkası mercan→sarı bir
/// yörünge gibi dolar, ucunda küçük bir uçak ilerler (Geonaut = dünya turu). Tamamlanınca nane yeşili.
enum DailyTheme {
    static let orbit: [Color] = [GeoColor.accentPrimarySoft, GeoColor.accentPrimary, GeoColor.accentHighlight, GeoColor.accentPrimarySoft]
    static let orbitDone: [Color] = [GeoColor.accentSuccess, GeoColor.accentSuccessStrong, GeoColor.accentHighlight, GeoColor.accentSuccess]
    static let shadow = GeoColor.accentTertiaryStrong.opacity(0.3)

    static var background: LinearGradient {
        LinearGradient(colors: [GeoColor.accentTertiary, GeoColor.accentTertiary.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

/// Lavanta zeminde yavaşça parıldayan beyaz yıldızlar (Profil başlığındaki gibi). "Hareketi azalt" açıksa durur.
struct DailyNightSky: View {
    var count = 18
    var seed: UInt64 = 7
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private struct Star { let x, y, size, phase, speed: Double }

    private var stars: [Star] {
        var state = seed &+ 0x9E3779B97F4A7C15
        func next() -> Double {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Double(state >> 11) / Double(1 << 53)
        }
        return (0..<count).map { _ in
            Star(x: next(), y: next(), size: 1.5 + next() * 2.5, phase: next() * 6.28, speed: 0.5 + next())
        }
    }

    var body: some View {
        let stars = self.stars
        TimelineView(.animation(minimumInterval: 1.0 / 15, paused: reduceMotion)) { timeline in
            let t = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                for star in stars {
                    let twinkle = reduceMotion ? 0.7 : 0.25 + 0.75 * (0.5 + 0.5 * sin(t * star.speed + star.phase))
                    let r = star.size * 1.4
                    let c = CGPoint(x: star.x * size.width, y: star.y * size.height)
                    var path = Path()
                    path.move(to: CGPoint(x: c.x, y: c.y - r))
                    path.addQuadCurve(to: CGPoint(x: c.x + r, y: c.y), control: CGPoint(x: c.x + r * 0.18, y: c.y - r * 0.18))
                    path.addQuadCurve(to: CGPoint(x: c.x, y: c.y + r), control: CGPoint(x: c.x + r * 0.18, y: c.y + r * 0.18))
                    path.addQuadCurve(to: CGPoint(x: c.x - r, y: c.y), control: CGPoint(x: c.x - r * 0.18, y: c.y + r * 0.18))
                    path.addQuadCurve(to: CGPoint(x: c.x, y: c.y - r), control: CGPoint(x: c.x - r * 0.18, y: c.y - r * 0.18))
                    context.opacity = twinkle * 0.9
                    context.fill(path, with: .color(.white))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// Soluk enlem/boylam çizgileriyle bir küre silueti — kartların sağ kenarında dekor.
struct DailyGlobeLines: View {
    var body: some View {
        Canvas { context, size in
            let d = min(size.width, size.height)
            let rect = CGRect(x: (size.width - d) / 2, y: (size.height - d) / 2, width: d, height: d)
            var path = Path(ellipseIn: rect)
            for f in [0.35, 0.7] {
                let w = d * f
                path.addEllipse(in: CGRect(x: rect.midX - w / 2, y: rect.minY, width: w, height: d))
            }
            for f in [0.25, 0.5, 0.75] {
                let y = rect.minY + d * f
                let half = sqrt(max(0, pow(d / 2, 2) - pow(y - rect.midY, 2)))
                path.move(to: CGPoint(x: rect.midX - half, y: y))
                path.addLine(to: CGPoint(x: rect.midX + half, y: y))
            }
            context.stroke(path, with: .color(.white.opacity(0.45)), lineWidth: 1.2)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// Hedef halkası: renkli yörünge dolar, ucunda küçük bir ay dünyanın etrafında döner; hedef
/// tamamlanınca nane yeşiline döner. Dolu kısım, Profil'deki Geonaut seviyesi çubuğu (GlitterBar)
/// gibi parlar: üzerinden kayan bir ışık şeridi ve göz kırpan küçük parıltılar.
struct GoalOrbit: View {
    let progress: Double
    var lineWidth: CGFloat = 8
    var done = false
    var moonSize: CGFloat = 14

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown: Double = 0

    private var target: Double { max(0, min(progress, 1)) }

    /// Parıltıların yay üzerindeki yeri (dolu kısmın oranı olarak) ve göz kırpma fazı.
    private static let sparkleSpots: [(at: Double, phase: Double)] = [
        (0.08, 0.0), (0.26, 1.1), (0.44, 2.3), (0.62, 0.7), (0.80, 1.7), (0.95, 2.9)
    ]

    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            ZStack {
                Circle().stroke(.white.opacity(0.65), lineWidth: lineWidth)
                Circle()
                    .trim(from: 0, to: shown)
                    .stroke(
                        AngularGradient(colors: done ? DailyTheme.orbitDone : DailyTheme.orbit, center: .center),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: (done ? GeoColor.accentSuccessStrong : GeoColor.accentPrimary).opacity(0.35), radius: lineWidth * 0.5)
                if shown > 0.015 {
                    glitter(diameter: d)
                }
                if !done {
                    Image(systemName: "moon.fill")
                        .font(.system(size: moonSize, weight: .bold))
                        .foregroundStyle(GeoColor.accentHighlight)
                        .shadow(color: GeoColor.accentHighlightStrong.opacity(0.7), radius: 0, x: 0.8, y: 0.8)
                        .shadow(color: .white.opacity(0.9), radius: moonSize * 0.35)
                        .rotationEffect(.degrees(-360 * shown - 25))
                        .offset(y: -d / 2)
                        .rotationEffect(.degrees(360 * shown))
                }
            }
            .frame(width: d, height: d)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            guard !reduceMotion else { shown = target; return }
            withAnimation(.easeOut(duration: 1.1).delay(0.15)) { shown = target }
        }
        .onChange(of: progress) {
            withAnimation(reduceMotion ? nil : .spring(duration: 0.7)) { shown = target }
        }
        .accessibilityHidden(true)
    }

    /// Dolu yayın üstünde kayan ışık + göz kırpan parıltılar; yalnızca dolu kısmın içinde görünür.
    private func glitter(diameter d: CGFloat) -> some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30, paused: reduceMotion)) { context in
            let t = reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate
            let cycle = (t * 0.32).truncatingRemainder(dividingBy: 1)
            let head = -0.1 + cycle * (shown + 0.2)
            ZStack {
                if !reduceMotion {
                    Circle()
                        .trim(from: max(0, head - 0.09), to: max(0, min(shown, head)))
                        .stroke(.white.opacity(0.75), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .blur(radius: lineWidth * 0.35)
                }
                ForEach(Self.sparkleSpots.indices, id: \.self) { i in
                    let spot = Self.sparkleSpots[i]
                    let angle = (360 * shown * spot.at - 90) * .pi / 180
                    Image(systemName: "sparkle")
                        .font(.system(size: max(5, lineWidth * 0.95), weight: .bold))
                        .foregroundStyle(.white)
                        .opacity(reduceMotion ? 0.8 : 0.25 + 0.75 * abs(sin(t * 2.2 + spot.phase)))
                        .offset(x: cos(angle) * d / 2, y: sin(angle) * d / 2)
                }
            }
            .frame(width: d, height: d)
            .mask {
                Circle()
                    .trim(from: 0, to: shown)
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
        }
    }
}

// MARK: - Ana Sayfa şeridi

/// Ana Sayfa'daki günlük hedef kartı: hedef halkası, kalan doğru sayısı, görevler ve seri koruyucu.
/// Dokununca DailySheet açılır.
struct DailyStrip: View {
    var daily = DailyEngagement.shared
    var onTap: () -> Void

    var body: some View {
        let day = daily.today()
        let shown = min(day.correct, day.goal)
        let left = max(day.goal - day.correct, 0)
        Button(action: onTap) {
            HStack(spacing: GeoSpacing.md) {
                GoalOrbit(progress: Double(shown) / Double(max(day.goal, 1)), lineWidth: 6, done: day.goalReached, moonSize: 14)
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: day.goalReached ? "checkmark" : "globe.europe.africa.fill")
                            .font(.system(size: day.goalReached ? 20 : 22, weight: .bold))
                            .foregroundStyle(day.goalReached ? GeoColor.accentSuccessStrong : GeoColor.accentTertiaryStrong)
                    }

                VStack(alignment: .leading, spacing: 0) {
                    Text("Günlük hedef")
                        .font(GeoTypography.caption)
                        .textCase(.uppercase)
                        .tracking(0.8)
                        .foregroundStyle(GeoColor.textSecondary)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(verbatim: "\(shown)")
                            .font(.custom(GeoFontName.balooExtraBold, size: 28))
                            .contentTransition(.numericText())
                        Text(verbatim: "/\(day.goal)")
                            .font(.custom(GeoFontName.balooBold, size: 17))
                            .foregroundStyle(GeoColor.textSecondary)
                    }
                    .foregroundStyle(GeoColor.textPrimary)
                    .monospacedDigit()
                    .frame(height: 32)
                    HStack(spacing: 4) {
                        Image(systemName: day.goalReached ? "checkmark.circle.fill" : "flag.checkered")
                            .font(.system(size: 10, weight: .bold))
                        if day.goalReached {
                            Text("Hedef tamam!")
                        } else {
                            Text("\(left) doğru kaldı")
                        }
                    }
                    .font(GeoTypography.bodyBold)
                    .foregroundStyle(day.goalReached ? GeoColor.accentSuccessText : GeoColor.textMuted)
                    .padding(.horizontal, GeoSpacing.sm)
                    .padding(.vertical, 3)
                    .background(day.goalReached ? GeoColor.accentSuccess : Color.white.opacity(0.55), in: Capsule())
                    .padding(.top, 2)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.8)

                Spacer(minLength: GeoSpacing.xs)

                VStack(alignment: .trailing, spacing: GeoSpacing.sm) {
                    questDots(day)
                    freezeSlots(day)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(GeoColor.textSecondary)
            }
            .padding(.horizontal, GeoSpacing.lg)
            .padding(.vertical, GeoSpacing.md)
            .background {
                ZStack(alignment: .trailing) {
                    DailyTheme.background
                    DailyGlobeLines()
                        .frame(width: 150, height: 150)
                        .offset(x: 40, y: 10)
                    DailyNightSky(count: 16, seed: 3)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: GeoRadius.lg))
            .shadow(color: DailyTheme.shadow, radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Günlük hedef: \(min(day.correct, day.goal)) / \(day.goal) doğru. Görevler: \(day.questsDone) / \(day.quests.count). Seri koruyucu: \(day.freezes)."))
        .accessibilityHint(Text("Günlük hedefi ve görevleri gösterir"))
    }

    private func questDots(_ day: DailyEngagement.Day) -> some View {
        HStack(spacing: 5) {
            Image(systemName: "checklist")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(GeoColor.textSecondary)
                .padding(.trailing, 1)
            ForEach(day.quests) { quest in
                let done = day.isDone(quest)
                ZStack {
                    Circle()
                        .fill(done ? GeoColor.accentSuccessStrong : .white.opacity(0.55))
                    Circle()
                        .stroke(done ? GeoColor.accentSuccessStrong : GeoColor.accentTertiaryStrong.opacity(0.6), lineWidth: 1.5)
                    if done {
                        Image(systemName: "checkmark")
                            .font(.system(size: 8, weight: .black))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 16, height: 16)
            }
        }
    }

    private func freezeSlots(_ day: DailyEngagement.Day) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<DailyEngagement.maxFreezes, id: \.self) { i in
                Image(systemName: "snowflake")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(i < day.freezes ? GeoColor.accentInfoStrong : GeoColor.accentTertiaryStrong.opacity(0.45))
            }
        }
    }
}

// MARK: - Hedef temposu kartları

/// Günlük hedef temposu kartları: "Bugün" sayfası ve ilk seviye sonrası tempo sorusu
/// (GoalPromptSheet) ortak kullanır. Renkler GeoColor açık/koyu ton çiftleri.
struct DailyGoalPicker: View {
    let selected: Int
    var onSelect: (Int) -> Void

    struct Pace {
        let goal: Int
        let icon: String
        let soft: Color
        let strong: Color
    }

    static func pace(for goal: Int) -> Pace {
        switch goal {
        case ..<8: Pace(goal: goal, icon: "cup.and.saucer.fill", soft: GeoColor.accentInfo, strong: GeoColor.accentInfoStrong)
        case ..<15: Pace(goal: goal, icon: "leaf.fill", soft: GeoColor.accentSuccess, strong: GeoColor.accentSuccessStrong)
        case ..<30: Pace(goal: goal, icon: "flame.fill", soft: GeoColor.accentPrimarySoft, strong: GeoColor.accentPrimaryStrong)
        default: Pace(goal: goal, icon: "bolt.fill", soft: GeoColor.accentTertiary, strong: GeoColor.accentTertiaryStrong)
        }
    }

    static func name(_ goal: Int) -> LocalizedStringKey {
        switch goal {
        case ..<8: "Hafif"
        case ..<15: "Rahat"
        case ..<30: "Normal"
        default: "Ciddi"
        }
    }

    var body: some View {
        HStack(spacing: GeoSpacing.sm) {
            ForEach(DailyEngagement.goalOptions, id: \.self) { goal in
                tile(Self.pace(for: goal), selected: goal == selected)
            }
        }
    }

    private func tile(_ pace: Pace, selected: Bool) -> some View {
        Button {
            withAnimation(.spring(duration: 0.35, bounce: 0.35)) { onSelect(pace.goal) }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: pace.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(selected ? Color.white : pace.strong)
                    .frame(width: 38, height: 38)
                    .background(selected ? pace.strong : pace.soft.opacity(0.35), in: Circle())
                    .padding(.bottom, 2)
                Text(Self.name(pace.goal))
                    .font(GeoTypography.title)
                    .foregroundStyle(GeoColor.textPrimary)
                Text("\(pace.goal) doğru")
                    .font(GeoTypography.bodyBold)
                    .foregroundStyle(GeoColor.textPrimary)
                    .monospacedDigit()
                Group {
                    if pace.goal < GameRules.questionsPerStage {
                        Text("≈ yarım seviye")
                    } else {
                        Text("≈ \(pace.goal / GameRules.questionsPerStage) seviye")
                    }
                }
                .font(GeoTypography.caption)
                .foregroundStyle(GeoColor.textSecondary)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity)
            .padding(.vertical, GeoSpacing.md + 2)
            .padding(.horizontal, 4)
            .background(selected ? pace.soft.opacity(0.45) : GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: GeoRadius.md))
            .overlay {
                RoundedRectangle(cornerRadius: GeoRadius.md)
                    .strokeBorder(selected ? pace.strong : GeoColor.borderSubtle, lineWidth: selected ? 2.5 : 1.5)
            }
            .overlay(alignment: .topTrailing) {
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white, pace.strong)
                        .padding(5)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .shadow(color: selected ? pace.strong.opacity(0.25) : .black.opacity(0.04), radius: selected ? 8 : 2, x: 0, y: selected ? 4 : 1)
            .scaleEffect(selected ? 1 : 0.96)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

// MARK: - "Bugün" sayfası

private struct DailySheetHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = max(value, nextValue()) }
}

/// "Bugün" sayfası: büyük hedef halkası, hedef temposu seçimi, 3 görev, seri koruyucu.
struct DailySheet: View {
    var daily = DailyEngagement.shared
    @Environment(\.dismiss) private var dismiss
    @State private var contentHeight: CGFloat = 760
    /// Seçilen ama henüz kaydedilmemiş hedef (kullanıcı kararı 2026-11-14: hedef "Kaydet" ile değişir).
    @State private var draftGoal: Int?

    var body: some View {
        let saved = daily.today()
        // Önizleme: halka, görev ve tempo kartları seçilen (taslak) hedefle görünür.
        let day: DailyEngagement.Day = {
            var preview = saved
            preview.goal = draftGoal ?? saved.goal
            return preview
        }()
        let hasChanges = draftGoal != nil && draftGoal != saved.goal
        ScrollView {
            VStack(spacing: GeoSpacing.xl) {
                Text("Bugün")
                    .font(GeoTypography.headingL)
                    .foregroundStyle(GeoColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)

                hero(day)
                goalPicker(day)
                questSection(day)
                freezeSection(day)

                Button {
                    // Değişiklik yoksa da çağrılır: tempo sayfası görüldü, ilk seviye sonrası tempo sorusu bir daha gelmez.
                    daily.setGoal(draftGoal ?? saved.goal)
                    dismiss()
                } label: {
                    // Hedef değiştiyse "Kaydet", değişmediyse "Anladım" (kullanıcı kararı 2026-11-14).
                    Group {
                        if hasChanges { Text("Kaydet") } else { Text("Anladım") }
                    }
                    .frame(maxWidth: .infinity)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: hasChanges)
                }
                .buttonStyle(.kasifPrimary)
            }
            .padding(.horizontal, GeoSpacing.xl)
            .padding(.top, GeoSpacing.xxl)
            .padding(.bottom, GeoSpacing.xxxl)
            .background {
                GeometryReader { proxy in
                    Color.clear.preference(key: DailySheetHeightKey.self, value: proxy.size.height)
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .onPreferenceChange(DailySheetHeightKey.self) { if $0 > 0 { contentHeight = $0 } }
        .presentationBackground(GeoColor.bgCanvas)
        .presentationDetents([.height(contentHeight), .large])
        .presentationDragIndicator(.visible)
        .sensoryFeedback(.selection, trigger: draftGoal)
        .onAppear { daily.markEventsSeen() }
    }

    // MARK: Büyük halka

    private func hero(_ day: DailyEngagement.Day) -> some View {
        let shown = min(day.correct, day.goal)
        let left = max(day.goal - day.correct, 0)
        return VStack(spacing: GeoSpacing.md) {
            ZStack {
                if day.goalReached {
                    GeoWinGlow(color: .white, size: 250)
                }
                GoalOrbit(progress: Double(shown) / Double(max(day.goal, 1)), lineWidth: 14, done: day.goalReached, moonSize: 26)
                    .frame(width: 168, height: 168)
                VStack(spacing: -6) {
                    Text(verbatim: "\(shown)")
                        .font(.custom(GeoFontName.balooExtraBold, size: 54))
                        .foregroundStyle(GeoColor.textPrimary)
                        .contentTransition(.numericText())
                    Text("/ \(day.goal) doğru")
                        .font(GeoTypography.bodyBold)
                        .foregroundStyle(GeoColor.textSecondary)
                }
                .monospacedDigit()
            }
            .frame(height: 190)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Günlük hedef: \(shown) / \(day.goal) doğru"))

            Group {
                if day.goalReached {
                    Text("Bugünkü hedefini tamamladın!")
                } else {
                    Text("Hedefe \(left) doğru kaldı. Her doğru cevap sayılır.")
                }
            }
            .font(GeoTypography.bodyBold)
            .foregroundStyle(day.goalReached ? GeoColor.accentSuccessText : GeoColor.textPrimary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, GeoSpacing.lg)
        }
        .padding(.vertical, GeoSpacing.xl)
        .frame(maxWidth: .infinity)
        .background {
            ZStack {
                DailyTheme.background
                DailyGlobeLines()
                    .frame(width: 300, height: 300)
                    .offset(x: 120, y: 60)
                DailyNightSky(count: 34, seed: 11)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: GeoRadius.xl))
        .shadow(color: DailyTheme.shadow, radius: 12, x: 0, y: 6)
    }

    // MARK: Hedef temposu

    private func goalPicker(_ day: DailyEngagement.Day) -> some View {
        VStack(alignment: .leading, spacing: GeoSpacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Temponu seç")
                    .font(GeoTypography.headingM)
                    .foregroundStyle(GeoColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text("Sana uyan hedefi seç, istediğin zaman değiştirebilirsin.")
                    .font(GeoTypography.bodySemibold)
                    .foregroundStyle(GeoColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            DailyGoalPicker(selected: day.goal) { draftGoal = $0 }
        }
    }

    // MARK: Görevler

    private static let questTints: [(Color, Color)] = [
        (GeoColor.accentPrimary, GeoColor.accentPrimaryStrong),
        (GeoColor.accentInfo, GeoColor.accentInfoStrong),
        (GeoColor.accentTertiary, GeoColor.accentTertiaryStrong)
    ]

    private func questSection(_ day: DailyEngagement.Day) -> some View {
        VStack(alignment: .leading, spacing: GeoSpacing.md) {
            HStack(alignment: .firstTextBaseline) {
                Text("Günlük görevler")
                    .font(GeoTypography.headingM)
                    .foregroundStyle(GeoColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Text(verbatim: "\(day.questsDone)/\(day.quests.count)")
                    .font(GeoTypography.bodyBold)
                    .foregroundStyle(GeoColor.textSecondary)
                    .monospacedDigit()
            }
            VStack(spacing: GeoSpacing.sm) {
                ForEach(Array(day.quests.enumerated()), id: \.element) { index, quest in
                    questRow(quest, day: day, tint: Self.questTints[index % Self.questTints.count])
                }
            }
            Text("Görevler her gece yarısı yenilenir.")
                .font(GeoTypography.caption)
                .foregroundStyle(GeoColor.textMuted)
        }
    }

    private func questRow(_ quest: DailyEngagement.Quest, day: DailyEngagement.Day, tint: (Color, Color)) -> some View {
        let done = day.isDone(quest)
        let progress = day.progress(quest), target = day.target(quest)
        let fraction = Double(progress) / Double(max(target, 1))
        return HStack(spacing: GeoSpacing.md) {
            Image(systemName: done ? "checkmark" : quest.icon)
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(
                    LinearGradient(colors: done ? [GeoColor.accentSuccess, GeoColor.accentSuccessStrong] : [tint.0, tint.1],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 12)
                )
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 7) {
                Text(quest.title)
                    .font(GeoTypography.bodyBold)
                    .foregroundStyle(GeoColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(GeoColor.bgLocked)
                        Capsule()
                            .fill(LinearGradient(colors: done ? [GeoColor.accentSuccess, GeoColor.accentSuccessStrong] : [tint.0, tint.1],
                                                 startPoint: .leading, endPoint: .trailing))
                            .frame(width: max(fraction > 0 ? 8 : 0, geo.size.width * fraction))
                    }
                }
                .frame(height: 8)
                .accessibilityHidden(true)
            }
            Group {
                if done {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(GeoColor.accentSuccessStrong)
                } else {
                    Text(verbatim: "\(progress)/\(target)")
                        .font(GeoTypography.bodyBold)
                        .foregroundStyle(GeoColor.textSecondary)
                        .monospacedDigit()
                }
            }
            .frame(minWidth: 40, alignment: .trailing)
        }
        .padding(GeoSpacing.md)
        .background(done ? GeoColor.accentSuccess.opacity(0.22) : GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: GeoRadius.md))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "\(quest.title): \(progress)/\(target)"))
        .accessibilityValue(done ? Text("Tamamlandı") : Text(verbatim: ""))
    }

    // MARK: Seri koruyucu

    private func freezeSection(_ day: DailyEngagement.Day) -> some View {
        VStack(alignment: .leading, spacing: GeoSpacing.md) {
            HStack(spacing: GeoSpacing.md) {
                ForEach(0..<DailyEngagement.maxFreezes, id: \.self) { i in
                    freezeSlot(filled: i < day.freezes)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Seri koruyucu")
                        .font(GeoTypography.title)
                        .foregroundStyle(GeoColor.textPrimary)
                    Text(verbatim: "\(day.freezes)/\(DailyEngagement.maxFreezes)")
                        .font(GeoTypography.bodyBold)
                        .foregroundStyle(GeoColor.accentInfoStrong)
                        .monospacedDigit()
                }
                Spacer(minLength: 0)
            }
            Text("Bugünün 3 görevini bitirince 1 seri koruyucu kazanırsın (en fazla 2).")
                .font(GeoTypography.bodySemibold)
                .foregroundStyle(GeoColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Text("Bir gün oynamayı unutursan seri koruyucu kendiliğinden devreye girer, serin bozulmaz.")
                .font(GeoTypography.bodySemibold)
                .foregroundStyle(GeoColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(GeoSpacing.lg)
        .background(
            LinearGradient(colors: [GeoColor.accentInfo.opacity(0.38), GeoColor.bgSurface], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: GeoRadius.md)
        )
        .accessibilityElement(children: .combine)
    }

    private func freezeSlot(filled: Bool) -> some View {
        Image(systemName: "snowflake")
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(filled ? Color.white : GeoColor.accentInfoStrong.opacity(0.35))
            .frame(width: 46, height: 46)
            .background {
                if filled {
                    Circle().fill(LinearGradient(colors: [GeoColor.accentInfo, GeoColor.accentInfoStrong], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: GeoColor.accentInfoStrong.opacity(0.35), radius: 5, y: 3)
                } else {
                    Circle().strokeBorder(GeoColor.accentInfoStrong.opacity(0.35), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                }
            }
            .accessibilityHidden(true)
    }
}

#if DEBUG
/// `-debugScreen daily|daily_done|daily_sheet|daily_sheet_done`: günlük hedef tasarımını sahte verilerle gösterir.
struct DailyDebugScreen: View {
    let variant: String
    @State private var ready = false
    @State private var showSheet = false
    @State private var showGoalPrompt = false

    var body: some View {
        ZStack(alignment: .top) {
            GeoColor.bgCanvas.ignoresSafeArea()
            GeoStarfield().ignoresSafeArea()
            if ready {
                DailyStrip(onTap: { showSheet = true })
                    .padding(.horizontal, GeoSpacing.xl)
                    .padding(.top, 90)
            }
        }
        .sheet(isPresented: $showSheet) { DailySheet() }
        .sheet(isPresented: $showGoalPrompt) { GoalPromptSheet(onDone: { showGoalPrompt = false }) }
        .onAppear {
            let done = variant.hasSuffix("done")
            DailyEngagement.shared.debugSetDay(correct: done ? 23 : 7, goal: 20, freezes: done ? 2 : 1, stages: done ? 3 : 1, perfect: done ? 1 : 0)
            ready = true
            showSheet = variant.contains("sheet")
            showGoalPrompt = variant == "goalprompt"
        }
    }
}
#endif

#Preview("Şerit") {
    DailyStrip(onTap: {}).padding().background(GeoColor.bgCanvas)
}
