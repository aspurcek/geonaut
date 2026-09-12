import SwiftUI

/// Figma "Etap Haritası - Avrupa" (node 271:5549) — bir bölümün 8 etaplık zikzak yolu.
/// Bkz. Bayrak Tahmin Kural Kitabı böl. 02: "Bir etap ancak öncekinin bitirilmesiyle açılır."
struct EtapMapView: View {
    let sectionName: String
    let categoryName: String
    let etapStates: [KasifEtapNode.State] // her zaman GameRules.questionsPerStage/etap yapısına göre 8 eleman
    var onSelectEtap: (Int) -> Void
    var onBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(KasifColor.textPrimary)
                        .padding(KasifSpacing.sm)
                }

                VStack(alignment: .leading, spacing: KasifSpacing.xs) {
                    Text(sectionName)
                        .font(.custom(KasifFontName.balooBold, size: 28))
                        .foregroundStyle(KasifColor.textPrimary)
                    Text("\(categoryName) · \(etapStates.count) etap · \(GameRules.questionsPerStage) soru")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(KasifColor.textSecondary)
                }
                .padding(.top, KasifSpacing.sm)
                .padding(.bottom, KasifSpacing.lg)

                KasifZigzagPath(count: etapStates.count, rowHeight: 118) { index in
                    let state = etapStates[index]
                    Button {
                        onSelectEtap(index)
                    } label: {
                        VStack(spacing: KasifSpacing.sm) {
                            KasifEtapNode(state: state)
                            Text("Etap \(index + 1)")
                                .font(.custom(KasifFontName.balooBold, size: 12))
                                .foregroundStyle(state == .locked ? KasifColor.textMuted : KasifColor.textPrimary)
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(state == .locked)
                }
            }
            .padding(.horizontal, KasifSpacing.xl)
            .padding(.top, KasifSpacing.md)
        }
        .background(KasifColor.bgCanvas)
    }
}

#Preview {
    EtapMapView(
        sectionName: "Avrupa",
        categoryName: "Bayrak Tahmin",
        etapStates: [.completed, .active, .locked, .locked, .locked, .locked, .locked, .locked],
        onSelectEtap: { _ in },
        onBack: {}
    )
}
