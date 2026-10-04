import SwiftUI

/// Ana Sayfa'daki zikzak kıta yolu (bkz. Figma "Ana Sayfa - Kıta Yolu" node 271:5428).
struct ContinentPathView: View {
    let nodes: [ContinentPathNode]
    var onSelect: (ContinentPathNode) -> Void

    /// KasifContinentNode'un en büyük hali (active, 84pt daire + etiket) kadar sabit
    /// bir alan — bkz. aşağıdaki not.
    private let nodeSlotHeight: CGFloat = 112

    var body: some View {
        KasifZigzagPath(count: nodes.count) { index in
            let node = nodes[index]
            // Düğüm dairesi active durumda daha büyük (84pt vs 72pt) ve altında
            // "Hadi başlayalım!"/"BAŞLA" balonu VARDIR; bu içerik eskiden aynı VStack
            // içindeydi, yani toplam yükseklik state'e göre değişiyordu — KasifZigzagPath
            // bu view'i .position() ile ORTALADIĞI için farklı yükseklikler dairenin
            // kendisini farklı noktalara kaydırıyordu. Sonuç: Ana Sayfa'daki "Öğren"
            // durağıyla yoldaki ilk düğüm arasındaki boşluk, o kategoride ilerleme olup
            // olmamasına göre (düğüm active mi completed/locked mı) kategoriden
            // kategoriye tutarsız görünüyordu. Düzeltme: düğüm sabit yükseklikte bir
            // alana üstten hizalanır (daire her zaman aynı noktada), balon/rozet ise
            // yalnızca görsel bir overlay — konumlandırma hesabına katkısı yok.
            Button {
                onSelect(node)
            } label: {
                KasifContinentNode(title: node.name, systemImage: node.systemImage, state: node.state)
            }
            .buttonStyle(.plain)
            .disabled(node.state == .locked)
            .frame(height: nodeSlotHeight, alignment: .top)
            .overlay(alignment: .top) {
                if node.state == .active {
                    VStack(spacing: KasifSpacing.sm) {
                        KasifSpeechBubble(text: "Hadi başlayalım!")
                        KasifBadge(text: "BAŞLA", tone: .highlight)
                    }
                    // Overlay, temel view'in (düğme — yalnızca daire genişliğinde) sunduğu
                    // genişlikle sınırlanır; .fixedSize() olmadan "Hadi başlayalım!" o dar
                    // alana sıkışıp 2 satıra bölünüyordu. Balonun kendi doğal (tek satır)
                    // genişliğinde ölçülenmesini sağlar.
                    .fixedSize()
                    .offset(y: nodeSlotHeight + KasifSpacing.md)
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        ContinentPathView(nodes: ContinentPathNode.flagGuessPath(progress: GameProgress())) { _ in }
            .padding(.top, KasifSpacing.xl)
    }
    .background(KasifColor.bgCanvas)
}
