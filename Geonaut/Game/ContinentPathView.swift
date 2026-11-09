import SwiftUI

/// Ana Sayfa'daki zikzak kıta yolu (bkz. Figma "Ana Sayfa - Kıta Yolu" node 271:5428).
struct ContinentPathView: View {
    let nodes: [ContinentPathNode]
    var onSelect: (ContinentPathNode) -> Void

    /// GeoContinentNode'un en büyük hali (active, 84pt daire + etiket) kadar sabit
    /// bir alan — bkz. aşağıdaki not.
    private let nodeSlotHeight: CGFloat = 112

    var body: some View {
        // Sağ kolon ekranın tam ortasında: "Tur 2" etiketi ve "Öğren" durağıyla aynı eksende.
        GeoZigzagPath(count: nodes.count, trailingFraction: 0.5) { index in
            let node = nodes[index]
            // Düğüm dairesi active durumda daha büyük (84pt vs 72pt) ve altında
            // "Hadi başlayalım!"/"BAŞLA" balonu VARDIR; bu içerik eskiden aynı VStack
            // içindeydi, yani toplam yükseklik state'e göre değişiyordu — GeoZigzagPath
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
                GeoContinentNode(title: node.name, systemImage: node.systemImage, state: node.state)
            }
            .buttonStyle(.plain)
            .disabled(node.state == .locked)
            .frame(height: nodeSlotHeight, alignment: .top)
            .overlay(alignment: .top) {
                // Balon aktif düğümün ÜSTÜNDE ve ucu aşağı, dokunulacak daireyi gösterir. Eskiden düğümün
                // altındaydı ve aşağıdaki kilitli düğümü işaret ediyor gibi görünüyordu. Yalnızca görsel bir
                // overlay: konumlandırma hesabına katkısı yok (bkz. yukarıdaki not).
                if node.state == .active {
                    // Sıfır yükseklikli bir çapa, düğümün üst kenarında durur; balon bu çapanın ALT kenarına
                    // hizalanır, yani balonun ucu dairenin hemen üstünde, gövdesi yukarıda kalır.
                    Color.clear
                        .frame(width: 1, height: 0)
                        .overlay(alignment: .bottom) {
                            GeoSpeechBubble(text: "Hadi başlayalım!", pointsDown: true)
                                .fixedSize()
                                .offset(y: -2)
                        }
                        .accessibilityHidden(true)
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        ContinentPathView(nodes: ContinentPathNode.flagGuessPath(progress: GameProgress())) { _ in }
            .padding(.top, GeoSpacing.xl)
    }
    .background(GeoColor.bgCanvas)
}
