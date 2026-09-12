import SwiftUI

/// Figma Design System / Bileşenler / Map Pin (node 123:354). Harita Bilmece'nin
/// "haritadan işaretle" soru tipinde kullanılır. State=Selected(büyük mint damla +
/// tik)/Default(küçük mavi çember, henüz seçilmemiş nokta).
struct KasifMapPin: View {
    enum State { case selected, normal }
    var state: State = .normal

    var body: some View {
        switch state {
        case .selected:
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 34))
                .foregroundStyle(.white, KasifColor.accentSuccess)
                .overlay(alignment: .center) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .offset(y: -4)
                }
        case .normal:
            Circle()
                .strokeBorder(KasifColor.accentInfoStrong, lineWidth: 2)
                .frame(width: 16, height: 16)
        }
    }
}

#Preview {
    HStack(spacing: KasifSpacing.xxxl) {
        KasifMapPin(state: .selected)
        KasifMapPin(state: .normal)
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
