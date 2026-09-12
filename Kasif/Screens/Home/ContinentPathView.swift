import SwiftUI

/// Ana Sayfa'daki zikzak kıta yolu (bkz. Figma "Ana Sayfa - Kıta Yolu" node 271:5428).
struct ContinentPathView: View {
    let nodes: [ContinentPathNode]
    var onSelect: (ContinentPathNode) -> Void

    var body: some View {
        KasifZigzagPath(count: nodes.count) { index in
            let node = nodes[index]
            VStack(spacing: KasifSpacing.md) {
                Button {
                    onSelect(node)
                } label: {
                    KasifContinentNode(title: node.name, systemImage: node.systemImage, state: node.state)
                }
                .buttonStyle(.plain)
                .disabled(node.state == .locked)

                if node.state == .active {
                    VStack(spacing: KasifSpacing.sm) {
                        KasifSpeechBubble(text: "Hadi başlayalım!")
                        KasifBadge(text: "BAŞLA", tone: .highlight)
                    }
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
