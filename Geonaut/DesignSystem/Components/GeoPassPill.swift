import SwiftUI

/// Pas hakkı (kullanıcı kararı 2026-11-14, yeri 2026-11-16): seviye başına GameRules.passesPerStage
/// hak, her pas GameRules.passCost puan. Soru ekranının üst satırında, can göstergesinin hemen
/// solunda küçük bir hap olarak durur. Yanlışlıkla puan harcanmasın diye iki dokunuşlu:
/// ilk dokunuş hapı açar ("Pas geç · 5"), ikincisi pas geçer; 3 sn dokunulmazsa kapanır.
/// Pas geçilen soru seviyenin sonunda tekrar sorulur; o sırada hap "Tekrar" der.
struct GeoPassState {
    let passesLeft: Int
    let isRetry: Bool
    let canPass: Bool
    let hasEnoughPoints: Bool
    var onPass: () -> Void
}

struct GeoPassPill: View {
    let state: GeoPassState

    @State private var armed = false
    @State private var disarmTask: Task<Void, Never>?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var usable: Bool { state.canPass && state.passesLeft > 0 }
    private var enabled: Bool { usable && state.hasEnoughPoints }

    var body: some View {
        Button(action: tap) {
            HStack(spacing: 5) {
                Image(systemName: state.isRetry ? "arrow.uturn.backward" : "forward.fill")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(iconColor)
                if armed {
                    armedLabel
                        .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .leading)))
                } else if state.isRetry {
                    Text("Tekrar")
                        .font(GeoTypography.bodyBold)
                        .foregroundStyle(GeoColor.accentInfoStrong)
                } else {
                    Text(verbatim: "\(state.passesLeft)")
                        .font(GeoTypography.bodyBoldL)
                        .foregroundStyle(usable ? GeoColor.textPrimary : GeoColor.textMuted)
                        .monospacedDigit()
                }
            }
            .padding(.leading, GeoSpacing.md)
            .padding(.trailing, armed ? 6 : GeoSpacing.lg)
            .padding(.vertical, GeoSpacing.sm)
            .frame(minHeight: 36)
            .background(armed ? GeoColor.accentInfo.opacity(0.35) : GeoColor.bgSurface, in: Capsule())
            .overlay {
                if armed { Capsule().strokeBorder(GeoColor.accentInfoStrong.opacity(0.5), lineWidth: 1.5) }
            }
            .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 2)
            .fixedSize()
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!state.isRetry && !usable)
        .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.75), value: armed)
        .onChange(of: state.canPass) { _, can in if !can { disarm() } }
        .onDisappear { disarmTask?.cancel() }
        .accessibilityLabel(accessibilityText)
        .accessibilityHint(state.isRetry ? Text("Pas geçtiğin soru: puan kazandırmaz")
                                         : Text("Doğru cevap gösterilir, soru seviyenin sonunda tekrar sorulur"))
    }

    @ViewBuilder private var armedLabel: some View {
        if state.isRetry {
            Text("Puan kazandırmaz")
                .font(GeoTypography.bodyBold)
                .foregroundStyle(GeoColor.textSecondary)
                .padding(.trailing, GeoSpacing.sm)
        } else if !state.hasEnoughPoints {
            Text("Yetersiz puan")
                .font(GeoTypography.bodyBold)
                .foregroundStyle(GeoColor.textSecondary)
                .padding(.trailing, GeoSpacing.sm)
        } else {
            HStack(spacing: 5) {
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
                .background(GeoColor.bgSurface, in: Capsule())
            }
        }
    }

    private var iconColor: Color {
        if state.isRetry || usable { return GeoColor.accentInfoStrong }
        return GeoColor.iconInactive
    }

    private var accessibilityText: Text {
        state.isRetry ? Text("Pas geçtiğin soru: puan kazandırmaz") : Text("\(state.passesLeft) pas hakkı")
    }

    private func tap() {
        if armed {
            if !state.isRetry && enabled { state.onPass() }
            disarm()
            return
        }
        armed = true
        disarmTask?.cancel()
        disarmTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            armed = false
        }
    }

    private func disarm() {
        disarmTask?.cancel()
        armed = false
    }
}

#Preview {
    VStack(spacing: 16) {
        GeoPassPill(state: .init(passesLeft: 2, isRetry: false, canPass: true, hasEnoughPoints: true, onPass: {}))
        GeoPassPill(state: .init(passesLeft: 1, isRetry: false, canPass: true, hasEnoughPoints: false, onPass: {}))
        GeoPassPill(state: .init(passesLeft: 0, isRetry: false, canPass: false, hasEnoughPoints: true, onPass: {}))
        GeoPassPill(state: .init(passesLeft: 1, isRetry: true, canPass: false, hasEnoughPoints: true, onPass: {}))
    }
    .padding(40)
    .background(GeoColor.bgCanvas)
}
