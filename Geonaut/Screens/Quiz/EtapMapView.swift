import SwiftUI

/// Figma "Etap Haritası - Avrupa" (node 271:5549) — bir bölümün 8 etaplık zikzak yolu.
/// Bkz. Bayrak Tahmin Kural Kitabı böl. 02: "Bir etap ancak öncekinin bitirilmesiyle açılır."
struct EtapMapView: View {
    let sectionName: String
    let categoryName: String
    /// 0 = Tur 1 — bkz. TourStructure.
    var tour: Int = 0
    let etapStates: [GeoEtapNode.State] // her zaman GameRules.questionsPerStage/etap yapısına göre 8 eleman
    var onSelectEtap: (Int) -> Void
    var onBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                GeoScreenHeader(
                    title: LocalizedStringKey(sectionName),
                    subtitle: "\(L(categoryName)) · Tur \(tour + 1) · \(etapStates.count) seviye · \(GameRules.questionsPerStage) soru",
                    titleFontName: GeoFontName.balooBold, titleSize: 28, onBack: onBack
                )
                .padding(.bottom, GeoSpacing.lg)

                GeoZigzagPath(count: etapStates.count, rowHeight: 118) { index in
                    let state = etapStates[index]
                    Button {
                        onSelectEtap(index)
                    } label: {
                        VStack(spacing: GeoSpacing.sm) {
                            GeoEtapNode(state: state)
                            Text("Seviye \(index + 1)")
                                .font(.custom(GeoFontName.balooBold, size: 12))
                                .foregroundStyle(state == .locked ? GeoColor.textMuted : GeoColor.textPrimary)
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(state == .locked)
                }
            }
            .padding(.horizontal, GeoSpacing.xl)
            .padding(.top, GeoSpacing.md)
        }
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
    }
}

#Preview {
    EtapMapView(
        sectionName: "Avrupa",
        categoryName: "Bayraklar",
        etapStates: [.completed, .active, .locked, .locked, .locked, .locked, .locked, .locked],
        onSelectEtap: { _ in },
        onBack: {}
    )
}
