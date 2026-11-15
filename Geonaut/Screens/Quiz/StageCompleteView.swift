import SwiftUI

/// Figma "Etap Tamamlandı" (node 174:1066). Yıldız eşikleri GameRules.stars(correctCount:)
/// ile birebir uyumlu (bkz. Bayrak Tahmin Kural Kitabı böl. 06).
/// 1.0.3: hatasız bitirince "Hatasız!" rozeti; günlük hedef / görevler bu seviyeyle tamamlandıysa
/// altta kısa bir haber kartı (bkz. DailyEngagement.lastStageEvents).
struct StageCompleteView: View {
    let stageIndex: Int // 0-based
    let correctCount: Int
    /// Bu seviyede sorulan soru sayısı (normalde 10).
    var totalQuestions: Int = GameRules.questionsPerStage
    let pointsEarned: Int
    let heartsRemaining: Int
    var onContinue: () -> Void

    private var daily = DailyEngagement.shared

    init(stageIndex: Int, correctCount: Int, totalQuestions: Int = GameRules.questionsPerStage, pointsEarned: Int, heartsRemaining: Int, onContinue: @escaping () -> Void) {
        self.stageIndex = stageIndex
        self.correctCount = correctCount
        self.totalQuestions = totalQuestions
        self.pointsEarned = pointsEarned
        self.heartsRemaining = heartsRemaining
        self.onContinue = onContinue
    }

    private var stars: Int { GameRules.stars(correctCount: correctCount) }
    private var isPerfect: Bool { totalQuestions > 0 && correctCount >= totalQuestions }

    var body: some View {
        // Küçük ekranlarda (iPhone SE) haber kartıyla birlikte taşmasın diye kaydırılabilir; içerik sığıyorsa ortalı durur.
        GeometryReader { proxy in
            ScrollView {
                content
                    .frame(minHeight: proxy.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
    }

    private var content: some View {
        VStack(spacing: GeoSpacing.lg) {
            Spacer(minLength: GeoSpacing.lg)

            GeoAuthIllustration(type: .trophy)
                .kasifWinGlow()

            if isPerfect {
                Label("Hatasız!", systemImage: "checkmark.seal.fill")
                    .font(.custom(GeoFontName.balooBold, size: 17))
                    .foregroundStyle(GeoColor.accentSuccessText)
                    .padding(.horizontal, GeoSpacing.lg)
                    .padding(.vertical, GeoSpacing.xs + 2)
                    .background(GeoColor.accentSuccess, in: Capsule())
                    .accessibilityLabel(Text("Hatasız! Bütün soruları doğru bildin."))
            }

            Text("Seviye \(stageIndex + 1) Tamamlandı!")
                .font(.custom(GeoFontName.balooBold, size: 26))
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)

            HStack(spacing: GeoSpacing.sm) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: index < stars ? "star.fill" : "star")
                        .font(.system(size: 26))
                        .foregroundStyle(GeoColor.accentHighlight)
                }
            }

            Text("\(totalQuestions) sorunun \(correctCount)'ünü doğru bildin!")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(GeoColor.textSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: GeoSpacing.md) {
                GeoStatPill(icon: .points, value: "+\(pointsEarned)")
                GeoStatPill(icon: .hearts, value: "\(heartsRemaining)")
            }
            .padding(.top, GeoSpacing.sm)

            Text("Kazandığın puan  ·  kalan canların")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(GeoColor.textMuted)

            if let events = daily.lastStageEvents, !events.isEmpty {
                DailyEventsCard(events: events, freezes: daily.today().freezes)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            }

            Button("Devam Et", action: onContinue)
                .buttonStyle(.kasifPrimary)
                .frame(maxWidth: .infinity)
                .padding(.top, GeoSpacing.sm)

            Spacer(minLength: GeoSpacing.lg)
        }
        .padding(.horizontal, GeoSpacing.xxl)
        .frame(maxWidth: .infinity)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: daily.lastStageEvents)
    }
}

/// "Seviye Tamamlandı" ekranındaki günlük haberler: hedef tamam / görevler tamam (+ seri koruyucu).
private struct DailyEventsCard: View {
    let events: DailyEngagement.StageEvents
    let freezes: Int

    var body: some View {
        VStack(alignment: .leading, spacing: GeoSpacing.sm) {
            if events.goalReached {
                row(icon: "target", tint: GeoColor.accentPrimaryStrong, text: Text("Günlük hedefini tamamladın!"))
            }
            if events.questsCompleted {
                if events.freezeAwarded {
                    row(icon: "snowflake", tint: GeoColor.accentInfoStrong, text: Text("Bugünün görevleri tamam! +1 seri koruyucu (\(freezes)/\(DailyEngagement.maxFreezes))"))
                } else {
                    row(icon: "checkmark.circle.fill", tint: GeoColor.accentSuccessStrong, text: Text("Bugünün görevleri tamam! Seri koruyucuların zaten dolu (\(freezes)/\(DailyEngagement.maxFreezes))."))
                }
            }
        }
        .padding(GeoSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: GeoRadius.md))
        .shadow(color: .black.opacity(0.06), radius: 3, y: 2)
        .accessibilityElement(children: .combine)
    }

    private func row(icon: String, tint: Color, text: Text) -> some View {
        HStack(alignment: .top, spacing: GeoSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 22)
                .accessibilityHidden(true)
            text
                .font(.custom(GeoFontName.nunitoBold, size: 14))
                .foregroundStyle(GeoColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    StageCompleteView(stageIndex: 0, correctCount: 10, pointsEarned: 100, heartsRemaining: 5, onContinue: {})
}
