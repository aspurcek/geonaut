import SwiftUI

/// Soru ekranının altındaki pas çubuğu (kullanıcı kararı 2026-11-14): seviye başına
/// GameRules.passesPerStage hak, her pas GameRules.passCost puan. Pas geçilen soru seviyenin
/// sonunda tekrar sorulur — o sırada çubuk bunu söyler.
struct GeoPassBar: View {
    let passesLeft: Int
    let isRetry: Bool
    let canPass: Bool
    let hasEnoughPoints: Bool
    var onPass: () -> Void

    private var enabled: Bool { canPass && hasEnoughPoints }

    var body: some View {
        Group {
            if isRetry {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .foregroundStyle(GeoColor.accentInfoStrong)
                    Text("Pas geçtiğin soru: puan kazandırmaz")
                        .foregroundStyle(GeoColor.textSecondary)
                }
                .font(GeoTypography.bodyBold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, GeoSpacing.md)
            } else {
                HStack(spacing: GeoSpacing.md) {
                    HStack(spacing: 4) {
                        ForEach(0..<GameRules.passesPerStage, id: \.self) { i in
                            Image(systemName: "forward.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(i < passesLeft ? GeoColor.accentInfoStrong : GeoColor.iconInactive)
                        }
                        Text("\(passesLeft) pas hakkı")
                            .font(GeoTypography.bodyBold)
                            .foregroundStyle(GeoColor.textSecondary)
                            .padding(.leading, 2)
                    }
                    .accessibilityElement(children: .combine)

                    Spacer(minLength: 0)

                    if passesLeft > 0 && !hasEnoughPoints {
                        Text("Yetersiz puan")
                            .font(GeoTypography.caption)
                            .foregroundStyle(GeoColor.textMuted)
                    }

                    Button(action: onPass) {
                        HStack(spacing: 6) {
                            Text("Pas geç")
                                .font(GeoTypography.bodyBold)
                                .foregroundStyle(GeoColor.textPrimary)
                            HStack(spacing: 3) {
                                GeoGemIcon(size: 14)
                                Text(verbatim: "\(GameRules.passCost)")
                                    .font(GeoTypography.bodyBold)
                                    .foregroundStyle(GeoColor.accentInfoStrong)
                                    .monospacedDigit()
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(GeoColor.accentInfo.opacity(0.3), in: Capsule())
                        }
                        .padding(.leading, GeoSpacing.md)
                        .padding(.trailing, 6)
                        .padding(.vertical, 6)
                        .background(GeoColor.bgSurface, in: Capsule())
                        .overlay { Capsule().strokeBorder(GeoColor.borderSubtle, lineWidth: 1.5) }
                        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
                    }
                    .buttonStyle(.plain)
                    .disabled(!enabled)
                    .opacity(enabled ? 1 : 0.45)
                    .accessibilityHint(Text("Doğru cevap gösterilir, soru seviyenin sonunda tekrar sorulur"))
                }
                .padding(.vertical, GeoSpacing.sm)
            }
        }
        .padding(.horizontal, GeoSpacing.xl)
        .background(GeoColor.bgCanvas)
    }
}

#Preview {
    VStack {
        Spacer()
        GeoPassBar(passesLeft: 2, isRetry: false, canPass: true, hasEnoughPoints: true, onPass: {})
        GeoPassBar(passesLeft: 1, isRetry: false, canPass: true, hasEnoughPoints: false, onPass: {})
        GeoPassBar(passesLeft: 0, isRetry: true, canPass: false, hasEnoughPoints: true, onPass: {})
    }
    .background(GeoColor.bgCanvas)
}
