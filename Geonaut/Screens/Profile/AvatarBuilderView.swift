import SwiftUI

/// "Avatarını Oluştur" — Profil'deki avatara dokununca açılır (Figma ilk sürüm: node 566:12128).
/// 2026-11-14 yeniden tasarım (kullanıcı: "avatar düzenlemeyi de güzelleştir"):
/// - Üstte lavanta zeminli, yıldızlı bir sahnede büyük önizleme; her değişiklikte avatar hafifçe zıplar.
/// - Sahnede "Rastgele" (zar) ve değişiklik varsa "Geri al" düğmeleri.
/// - Altı ayrı satır yerine ikonlu sekmeler (Zemin/Ten/Saç/Saç rengi/Aksesuar/Yüz) ve her sekmede
///   adlarıyla büyük seçenek kartları.
/// - "Kaydet" ekranın altına sabit.
/// Ayarlar (ad/e-posta) burada YOK — dişli rozetine dokununca gidilen SettingsView'da.
struct AvatarBuilderView: View {
    let avatarColorHex: UInt32
    let character: AvatarCharacter
    var onBack: () -> Void
    var onSave: (_ avatarColorHex: UInt32, _ character: AvatarCharacter) -> Void

    @State private var draftColorHex: UInt32
    @State private var draft: AvatarCharacter
    @State private var tab: Tab = .background
    @State private var bounce = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(avatarColorHex: UInt32, character: AvatarCharacter, onBack: @escaping () -> Void, onSave: @escaping (UInt32, AvatarCharacter) -> Void) {
        self.avatarColorHex = avatarColorHex
        self.character = character
        self.onBack = onBack
        self.onSave = onSave
        _draftColorHex = State(initialValue: avatarColorHex)
        _draft = State(initialValue: character)
    }

    private var hasChanges: Bool {
        draftColorHex != avatarColorHex || draft != character
    }

    enum Tab: CaseIterable, Hashable {
        case background, skin, hair, hairColor, accessory, face

        var label: LocalizedStringKey {
            switch self {
            case .background: "Zemin"
            case .skin: "Ten"
            case .hair: "Saç"
            case .hairColor: "Saç rengi"
            case .accessory: "Aksesuar"
            case .face: "Yüz"
            }
        }

        var icon: String {
            switch self {
            case .background: "circle.lefthalf.filled"
            case .skin: "hand.raised.fill"
            case .hair: "scissors"
            case .hairColor: "paintbrush.fill"
            case .accessory: "eyeglasses"
            case .face: "face.smiling.inverse"
            }
        }

        /// Panel başlığı (mevcut çevirili metinler).
        var heading: LocalizedStringKey {
            switch self {
            case .background: "Profil rengini seç"
            case .skin: "Ten rengini seç"
            case .hair: "Saç şeklini seç"
            case .hairColor: "Saç rengini seç"
            case .accessory: "Aksesuar seç"
            case .face: "Yüz detayı seç"
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GeoScreenHeader(title: "Avatarını Oluştur", onBack: onBack)
                .padding(.horizontal, GeoSpacing.xl)
                .padding(.bottom, GeoSpacing.lg)

            // Ölü alan kalmasın (kullanıcı geri bildirimi): sekmeler ve panel kendi boylarında,
            // sahne ekranın kalanını doldurur. Panel her sekmede aynı yükseklikte (3 sütun, 2 sıra),
            // bu yüzden sekme değişince sahne zıplamaz.
            VStack(spacing: GeoSpacing.lg) {
                stage
                    .frame(minHeight: 150, maxHeight: .infinity)
                // Yatay kaydırma alanı ve panel dikeyde yalnızca kendi boyları kadar yer alsın.
                tabBar
                    .fixedSize(horizontal: false, vertical: true)
                panel
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, GeoSpacing.xl)
            .padding(.bottom, GeoSpacing.sm)
        }
        .padding(.top, GeoSpacing.md)
        .safeAreaInset(edge: .bottom) {
            Button {
                onSave(draftColorHex, draft)
            } label: {
                Text("Kaydet").frame(maxWidth: .infinity)
            }
            .buttonStyle(.kasifPrimary)
            .frame(maxWidth: .infinity)
            .disabled(!hasChanges)
            .padding(.horizontal, GeoSpacing.xl)
            .padding(.top, GeoSpacing.md)
            .padding(.bottom, GeoSpacing.sm)
            .background(GeoColor.bgCanvas.opacity(0.96).ignoresSafeArea())
        }
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
        .sensoryFeedback(.selection, trigger: bounce)
        .onChange(of: draft) { pop() }
        .onChange(of: draftColorHex) { pop() }
    }

    private func pop() {
        bounce += 1
    }

    // MARK: Sahne

    private var stage: some View {
        // Süsler ve avatar overlay olarak eklenir: sahnenin boyunu yalnızca dışarıdan verilen
        // alan belirler (sabit boyutlu süsler yerleşimi büyütmesin).
        DailyTheme.background
            .overlay {
                DailyGlobeLines()
                    .frame(width: 320, height: 320)
                    .offset(x: 140, y: 70)
            }
            .overlay { DailyNightSky(count: 26, seed: 21) }
            .overlay {
                GeometryReader { proxy in
                    let scale = min(2.1, max(1.3, proxy.size.height * 0.7 / 104))
                    ZStack {
                        GeoWinGlow(color: .white, size: 104 * scale * 1.5)
                        // Zemin rengi yumuşakça değişsin; karakter her değişiklikte hafifçe zıplasın.
                        GeoAvatar(backgroundColor: Color(hex: draftColorHex), character: draft)
                            .scaleEffect(scale)
                            .shadow(color: GeoColor.accentTertiaryStrong.opacity(0.35), radius: 14, y: 10)
                            .keyframeAnimator(initialValue: 1.0, trigger: reduceMotion ? 0 : bounce) { content, value in
                                content.scaleEffect(value)
                            } keyframes: { _ in
                                KeyframeTrack {
                                    CubicKeyframe(1.08, duration: 0.12)
                                    SpringKeyframe(1.0, duration: 0.35, spring: .bouncy)
                                }
                            }
                            .animation(.easeInOut(duration: 0.25), value: draftColorHex)
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
                }
            }
        // Dekor katmanları (küre çizgileri, ışık) sahneden büyük; boyutu dışarıdan verilen yükseklik belirler.
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: GeoRadius.xl))
        .overlay(alignment: .topTrailing) {
            stageButton(icon: "dice.fill", label: "Rastgele") { randomize() }
                .padding(GeoSpacing.md)
        }
        .overlay(alignment: .topLeading) {
            if hasChanges {
                stageButton(icon: "arrow.uturn.backward", label: "Geri al") {
                    withAnimation(.spring(duration: 0.3)) {
                        draftColorHex = avatarColorHex
                        draft = character
                    }
                }
                .padding(GeoSpacing.md)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .shadow(color: DailyTheme.shadow, radius: 12, x: 0, y: 6)
        .animation(.spring(duration: 0.3), value: hasChanges)
    }

    private func stageButton(icon: String, label: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                Text(label)
                    .font(GeoTypography.bodyBold)
            }
            .foregroundStyle(GeoColor.textPrimary)
            .padding(.horizontal, GeoSpacing.md)
            .padding(.vertical, 7)
            .background(.white.opacity(0.85), in: Capsule())
            .shadow(color: .black.opacity(0.08), radius: 3, y: 2)
        }
        .buttonStyle(.plain)
    }

    private func randomize() {
        withAnimation(.spring(duration: 0.35)) {
            draftColorHex = GeoColor.avatarSwatches.randomElement()?.hex ?? draftColorHex
            draft.skinTone = SkinTone.allCases.randomElement() ?? draft.skinTone
            draft.hairStyle = HairStyle.allCases.randomElement() ?? draft.hairStyle
            draft.hairColorHex = GeoHairColor.options.randomElement()?.hex ?? draft.hairColorHex
            draft.accessory = Bool.random() ? AvatarAccessory.allCases.randomElement() : nil
            draft.facialFeature = Int.random(in: 0..<3) == 0 ? AvatarFacialFeature.allCases.randomElement() : nil
        }
    }

    // MARK: Sekmeler

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: GeoSpacing.sm) {
                ForEach(Tab.allCases, id: \.self) { item in
                    let selected = item == tab
                    Button {
                        withAnimation(.spring(duration: 0.3)) { tab = item }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: item.icon)
                                .font(.system(size: 13, weight: .bold))
                            Text(item.label)
                                .font(GeoTypography.bodyBold)
                        }
                        .foregroundStyle(selected ? Color.white : GeoColor.textPrimary)
                        .padding(.horizontal, GeoSpacing.md + 2)
                        .padding(.vertical, 9)
                        .background(selected ? GeoColor.accentPrimaryStrong : GeoColor.bgSurface, in: Capsule())
                        .overlay { Capsule().strokeBorder(selected ? .clear : GeoColor.borderSubtle, lineWidth: 1.5) }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
            .padding(.vertical, 2)
        }
        .scrollClipDisabled()
    }

    // MARK: Panel

    /// Her sekmede 3 sütun → tüm sekmeler 2 sıra (4-6 seçenek), panel yüksekliği sabit kalır.
    private let tileColumns = Array(repeating: GridItem(.flexible(), spacing: GeoSpacing.md), count: 3)

    /// GeoColor.avatarSwatches sırasıyla.
    private static let backgroundNames = ["Mercan", "Nane", "Gökyüzü", "Güneş", "Lavanta", "Kiremit"]
    /// GeoHairColor.options sırasıyla.
    private static let hairColorNames = ["Siyah", "Altın", "Yeşil", "Mavi", "Mor", "Kızıl"]

    private static func skinName(_ tone: SkinTone) -> String {
        switch tone {
        case .acik: "Açık"
        case .bugday: "Buğday"
        case .esmer: "Esmer"
        case .siyahi: "Koyu"
        }
    }

    private var panel: some View {
        VStack(alignment: .leading, spacing: GeoSpacing.md) {
            Text(tab.heading)
                .font(GeoTypography.headingM)
                .foregroundStyle(GeoColor.textPrimary)

            Group {
                switch tab {
                case .background:
                    LazyVGrid(columns: tileColumns, spacing: GeoSpacing.md) {
                        ForEach(Array(GeoColor.avatarSwatches.enumerated()), id: \.element.hex) { index, swatch in
                            optionTile(title: Self.backgroundNames[index], isSelected: draftColorHex == swatch.hex, previewBackground: swatch.color) {
                                draftColorHex = swatch.hex
                            } preview: {
                                GeoAvatarCharacterView(skinTone: draft.skinTone, hairStyle: draft.hairStyle, hairColor: draft.hairColor, accessory: draft.accessory, facialFeature: draft.facialFeature)
                            }
                        }
                    }
                case .skin:
                    LazyVGrid(columns: tileColumns, spacing: GeoSpacing.md) {
                        ForEach(SkinTone.allCases, id: \.self) { tone in
                            optionTile(title: Self.skinName(tone), isSelected: draft.skinTone == tone) {
                                draft.skinTone = tone
                            } preview: {
                                GeoAvatarCharacterView(skinTone: tone, hairStyle: draft.hairStyle, hairColor: draft.hairColor)
                            }
                        }
                    }
                case .hairColor:
                    LazyVGrid(columns: tileColumns, spacing: GeoSpacing.md) {
                        ForEach(Array(GeoHairColor.options.enumerated()), id: \.element.hex) { index, option in
                            optionTile(title: Self.hairColorNames[index], isSelected: draft.hairColorHex == option.hex) {
                                draft.hairColorHex = option.hex
                            } preview: {
                                GeoAvatarCharacterView(skinTone: draft.skinTone, hairStyle: draft.hairStyle, hairColor: option.color)
                            }
                        }
                    }
                case .hair:
                    LazyVGrid(columns: tileColumns, spacing: GeoSpacing.md) {
                        ForEach(HairStyle.allCases, id: \.self) { style in
                            optionTile(title: style.title, isSelected: draft.hairStyle == style) {
                                draft.hairStyle = style
                            } preview: {
                                GeoAvatarCharacterView(skinTone: draft.skinTone, hairStyle: style, hairColor: draft.hairColor)
                            }
                        }
                    }
                case .accessory:
                    LazyVGrid(columns: tileColumns, spacing: GeoSpacing.md) {
                        noneTile(isSelected: draft.accessory == nil) { draft.accessory = nil }
                        ForEach(AvatarAccessory.allCases, id: \.self) { option in
                            optionTile(title: option.title, isSelected: draft.accessory == option) {
                                draft.accessory = option
                            } preview: {
                                GeoAvatarCharacterView(skinTone: draft.skinTone, hairStyle: draft.hairStyle, hairColor: draft.hairColor, accessory: option, showHair: false)
                            }
                        }
                    }
                case .face:
                    LazyVGrid(columns: tileColumns, spacing: GeoSpacing.md) {
                        noneTile(isSelected: draft.facialFeature == nil) { draft.facialFeature = nil }
                        ForEach(AvatarFacialFeature.allCases, id: \.self) { option in
                            optionTile(title: option.title, isSelected: draft.facialFeature == option) {
                                draft.facialFeature = option
                            } preview: {
                                GeoAvatarCharacterView(skinTone: draft.skinTone, hairStyle: draft.hairStyle, hairColor: draft.hairColor, facialFeature: option, showHair: false)
                            }
                        }
                    }
                }
            }
            .transition(.opacity)
            .id(tab)
        }
        .padding(GeoSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: GeoRadius.lg))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    private func optionTile(title: String, isSelected: Bool, previewBackground: Color? = nil, action: @escaping () -> Void, @ViewBuilder preview: () -> some View) -> some View {
        Button {
            withAnimation(.spring(duration: 0.3, bounce: 0.4)) { action() }
        } label: {
            VStack(spacing: GeoSpacing.sm) {
                Circle()
                    .fill(previewBackground ?? Color(hex: draftColorHex).opacity(0.45))
                    .frame(width: 56, height: 56)
                    // Karakter 100x100 kanvasta çiziliyor; şapka/uzun saç kenara taşabildiği için daireye kırpılır.
                    .overlay { preview().scaleEffect(0.54).clipShape(Circle()) }
                Text(LocalizedStringKey(title))
                    .font(GeoTypography.bodyBold)
                    .foregroundStyle(GeoColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.vertical, GeoSpacing.sm + 2)
            .padding(.horizontal, GeoSpacing.xs)
            .frame(maxWidth: .infinity)
            .background(isSelected ? GeoColor.accentPrimarySoft.opacity(0.22) : GeoColor.bgCanvas, in: RoundedRectangle(cornerRadius: GeoRadius.md))
            .overlay {
                RoundedRectangle(cornerRadius: GeoRadius.md)
                    .strokeBorder(isSelected ? GeoColor.accentPrimaryStrong : .clear, lineWidth: 2.5)
            }
            .overlay(alignment: .topTrailing) {
                if isSelected { checkBadge.padding(6) }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    /// Aksesuar/yüz detayındaki "Yok" kartı — tekli seçimi kaldırır.
    private func noneTile(isSelected: Bool, action: @escaping () -> Void) -> some View {
        optionTile(title: "Yok", isSelected: isSelected, action: action) {
            Image(systemName: "nosign")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(GeoColor.textMuted)
                .frame(width: 100, height: 100)
        }
    }


    private var checkBadge: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(.white, GeoColor.accentPrimaryStrong)
            .transition(.scale.combined(with: .opacity))
    }
}

#Preview {
    AvatarBuilderView(avatarColorHex: 0xFF987E, character: AvatarCharacter(), onBack: {}, onSave: { _, _ in })
}
