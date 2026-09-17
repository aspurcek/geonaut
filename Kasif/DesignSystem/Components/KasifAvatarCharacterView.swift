import SwiftUI

/// Katmanlı avatar karakteri — Figma "Design System / 6. Avatar Karakter Sistemi"
/// (node 555:12299) ile birebir aynı 100x100 koordinat uzayı. Katmanlar (alttan üste):
/// Saç → Kafa/Yüz → Sakal → Bıyık → Çil → Gözlük → Küpe → Piercing → Şapka.
/// Saçın "kep" görünümü kasıtlı: saç şekli kafa dairesinin ALTINDA çizilir, opak kafa
/// dairesi sacın yüzle çakışan alt kısmını gizler (bkz. Figma'daki aynı teknik notu).
struct KasifAvatarCharacterView: View {
    var skinTone: SkinTone = .acik
    var hairStyle: HairStyle = .kisa
    var hairColor: Color = KasifColor.textPrimary
    /// Kullanıcı kararı: aynı anda yalnızca BİR aksesuar / BİR yüz detayı — bkz.
    /// AvatarAccessory/AvatarFacialFeature.
    var accessory: AvatarAccessory? = nil
    var facialFeature: AvatarFacialFeature? = nil

    private let darkLine = Color(hex: 0x222938)

    var body: some View {
        ZStack {
            hairLayer
            head
            face
            if facialFeature == .sakal { beard }
            if facialFeature == .biyik { mustache }
            if facialFeature == .cil { freckles }
            if accessory == .gozluk { glasses }
            if accessory == .kupe { earring }
            if accessory == .piercing { nosePiercing }
            if accessory == .sapka { hat }
        }
        .frame(width: 100, height: 100)
    }

    // MARK: - Taban

    private var head: some View {
        Circle()
            .fill(skinTone.color)
            .frame(width: 70, height: 70)
            .position(x: 50, y: 55)
    }

    private var face: some View {
        ZStack {
            Circle().fill(darkLine).frame(width: 7, height: 7).position(x: 38, y: 50)
            Circle().fill(darkLine).frame(width: 7, height: 7).position(x: 62, y: 50)
            Path { p in
                p.move(to: CGPoint(x: 40, y: 64))
                p.addQuadCurve(to: CGPoint(x: 60, y: 64), control: CGPoint(x: 50, y: 72))
            }
            .stroke(darkLine, style: StrokeStyle(lineWidth: 3, lineCap: .round))
        }
    }

    // MARK: - Saç

    @ViewBuilder private var hairLayer: some View {
        switch hairStyle {
        case .kisa:
            ellipse(50, 35, 78, 50)
        case .uzun:
            ellipse(50, 35, 78, 50)
            roundedRect(20, 72.5, 16, 45, radius: 8)
            roundedRect(80, 72.5, 16, 45, radius: 8)
        case .kivircik:
            ellipse(50, 39, 70, 42)
            ellipse(27, 27, 18, 18)
            ellipse(38, 17, 18, 18)
            ellipse(50, 12, 18, 18)
            ellipse(62, 17, 18, 18)
            ellipse(73, 27, 18, 18)
        case .atKuyrugu:
            ellipse(50, 35, 78, 50)
            ellipse(82, 58, 16, 30, rotation: -20)
        case .topuz:
            ellipse(50, 33, 72, 34)
            ellipse(50, 8, 24, 24)
        }
    }

    private func ellipse(_ cx: CGFloat, _ cy: CGFloat, _ w: CGFloat, _ h: CGFloat, rotation: Double = 0) -> some View {
        Ellipse()
            .fill(hairColor)
            .frame(width: w, height: h)
            .rotationEffect(.degrees(rotation))
            .position(x: cx, y: cy)
    }

    private func roundedRect(_ cx: CGFloat, _ cy: CGFloat, _ w: CGFloat, _ h: CGFloat, radius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(hairColor)
            .frame(width: w, height: h)
            .position(x: cx, y: cy)
    }

    // MARK: - Yüz detayları

    private var beard: some View {
        Ellipse().fill(hairColor).frame(width: 46, height: 18).position(x: 50, y: 85)
    }

    private var mustache: some View {
        ZStack {
            Ellipse().fill(hairColor).frame(width: 15, height: 7).rotationEffect(.degrees(-15)).position(x: 42.5, y: 61.5)
            Ellipse().fill(hairColor).frame(width: 15, height: 7).rotationEffect(.degrees(15)).position(x: 57.5, y: 61.5)
        }
    }

    private var freckles: some View {
        let freckleColor = Color(hex: 0xBF734F)
        let points: [(CGFloat, CGFloat)] = [
            (31.5, 59.5), (35.5, 63.5), (29.5, 64.5),
            (71.5, 59.5), (67.5, 63.5), (73.5, 64.5),
        ]
        return ZStack {
            ForEach(points.indices, id: \.self) { i in
                Circle().fill(freckleColor).frame(width: 3, height: 3).position(x: points[i].0, y: points[i].1)
            }
        }
    }

    // MARK: - Aksesuar

    private var hat: some View {
        // Kanvasın (0-100) dışına taşmaması için tam dairesel bir yuvaya sığacak şekilde
        // daraltıldı (bkz. KasifAvatar/AvatarBuilderView'daki clipShape(Circle())).
        ZStack {
            Ellipse().fill(Color(hex: 0xBF9452)).frame(width: 68, height: 18).position(x: 50, y: 29)
            Ellipse().fill(Color(hex: 0xBF9452)).frame(width: 44, height: 24).position(x: 50, y: 16)
            Rectangle().fill(Color(hex: 0x8F662E)).frame(width: 44, height: 5).position(x: 50, y: 26.5)
        }
    }

    private var glasses: some View {
        ZStack {
            Circle().stroke(darkLine, lineWidth: 3).frame(width: 20, height: 20).position(x: 38, y: 50)
            Circle().stroke(darkLine, lineWidth: 3).frame(width: 20, height: 20).position(x: 62, y: 50)
            Rectangle().fill(darkLine).frame(width: 6, height: 3).position(x: 50, y: 50)
        }
    }

    private var earring: some View {
        Circle().fill(KasifColor.accentHighlight).frame(width: 9, height: 9).position(x: 83.5, y: 60.5)
    }

    private var nosePiercing: some View {
        Circle().stroke(Color(hex: 0x999EA6), lineWidth: 2).frame(width: 7, height: 7).position(x: 58.5, y: 61.5)
    }
}

#Preview {
    VStack(spacing: KasifSpacing.lg) {
        HStack(spacing: KasifSpacing.md) {
            KasifAvatarCharacterView(skinTone: .acik, hairStyle: .kisa, hairColor: KasifColor.textPrimary)
            KasifAvatarCharacterView(skinTone: .bugday, hairStyle: .uzun, hairColor: KasifColor.accentHighlightStrong)
            KasifAvatarCharacterView(skinTone: .esmer, hairStyle: .kivircik, hairColor: KasifColor.accentDanger)
            KasifAvatarCharacterView(skinTone: .siyahi, hairStyle: .atKuyrugu, hairColor: KasifColor.accentTertiaryStrong)
        }
        HStack(spacing: KasifSpacing.md) {
            KasifAvatarCharacterView(skinTone: .bugday, hairStyle: .topuz, hairColor: KasifColor.accentSuccessStrong, accessory: .sapka, facialFeature: .sakal)
            KasifAvatarCharacterView(skinTone: .acik, hairStyle: .kisa, hairColor: KasifColor.accentDanger, accessory: .gozluk, facialFeature: .biyik)
            KasifAvatarCharacterView(skinTone: .esmer, hairStyle: .uzun, hairColor: KasifColor.accentHighlightStrong, accessory: .kupe, facialFeature: .cil)
        }
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
