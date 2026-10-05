import SwiftUI

/// Figma Design System / Bileşenler / Map Pin (node 123:354). Harita Bilmece'nin
/// "haritadan işaretle" soru tipinde kullanılır. State=Selected(büyük mint damla +
/// tik)/Default(küçük mavi çember, henüz seçilmemiş nokta).
struct GeoMapPin: View {
    enum State { case selected, normal }
    var state: State = .normal

    var body: some View {
        switch state {
        case .selected:
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 34))
                .foregroundStyle(.white, GeoColor.accentSuccess)
                .overlay(alignment: .center) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .offset(y: -4)
                }
        case .normal:
            Circle()
                .strokeBorder(GeoColor.accentInfoStrong, lineWidth: 2)
                .frame(width: 16, height: 16)
        }
    }
}

#Preview {
    HStack(spacing: GeoSpacing.xxxl) {
        GeoMapPin(state: .selected)
        GeoMapPin(state: .normal)
    }
    .padding(GeoSpacing.xxxl)
    .background(GeoColor.bgCanvas)
}
