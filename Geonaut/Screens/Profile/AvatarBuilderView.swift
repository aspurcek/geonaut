import SwiftUI

/// Figma "Avatar Oluştur" (node 566:12128) — Profil-Ayarlar'daki avatar resmine
/// dokununca açılan, karakter özelleştirmesine (ten/saç/aksesuar/yüz detayı) ve
/// zemin rengine ayrılmış ekran. Ayarlar (ad/e-posta) burada YOK — dişli rozetine
/// dokununca gidilen SettingsView'da (bkz. ProfileView).
struct AvatarBuilderView: View {
    let avatarColorHex: UInt32
    let character: AvatarCharacter
    var onBack: () -> Void
    var onSave: (_ avatarColorHex: UInt32, _ character: AvatarCharacter) -> Void

    @State private var draftColorHex: UInt32
    @State private var draft: AvatarCharacter

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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GeoScreenHeader(title: "Avatarını Oluştur", onBack: onBack)
                .padding(.bottom, GeoSpacing.xl)

            ScrollView {
                VStack(spacing: GeoSpacing.xxl) {
                    GeoAvatar(backgroundColor: Color(hex: draftColorHex), character: draft)
                        .frame(maxWidth: .infinity)

                    pickerSection(title: "Profil rengini seç") {
                        ForEach(GeoColor.avatarSwatches, id: \.hex) { swatch in
                            colorSwatch(swatch.color, isSelected: draftColorHex == swatch.hex) {
                                draftColorHex = swatch.hex
                            }
                        }
                    }

                    pickerSection(title: "Ten rengini seç") {
                        ForEach(SkinTone.allCases, id: \.self) { tone in
                            colorSwatch(tone.color, isSelected: draft.skinTone == tone) {
                                draft.skinTone = tone
                            }
                        }
                    }

                    pickerSection(title: "Saç şeklini seç") {
                        ForEach(HairStyle.allCases, id: \.self) { style in
                            thumbnailSwatch(isSelected: draft.hairStyle == style) {
                                draft.hairStyle = style
                            } content: {
                                GeoAvatarCharacterView(skinTone: draft.skinTone, hairStyle: style, hairColor: draft.hairColor)
                                    .scaleEffect(0.28)
                            }
                        }
                    }

                    pickerSection(title: "Saç rengini seç") {
                        ForEach(GeoHairColor.options, id: \.hex) { option in
                            colorSwatch(option.color, isSelected: draft.hairColorHex == option.hex) {
                                draft.hairColorHex = option.hex
                            }
                        }
                    }

                    // Kullanıcı kararı: aynı anda yalnızca BİR aksesuar — "Yok" seçeneği
                    // dahil tekli seçim (bkz. AvatarAccessory).
                    pickerSection(title: "Aksesuar seç") {
                        noneThumbnail(isSelected: draft.accessory == nil) { draft.accessory = nil }
                        ForEach(AvatarAccessory.allCases, id: \.self) { option in
                            thumbnailSwatch(isSelected: draft.accessory == option) {
                                draft.accessory = option
                            } content: {
                                GeoAvatarCharacterView(skinTone: draft.skinTone, hairStyle: draft.hairStyle, hairColor: draft.hairColor, accessory: option, showHair: false)
                                    .scaleEffect(0.34)
                            }
                        }
                    }

                    // Aynı anda yalnızca BİR yüz detayı (bkz. AvatarFacialFeature).
                    pickerSection(title: "Yüz detayı seç") {
                        noneThumbnail(isSelected: draft.facialFeature == nil) { draft.facialFeature = nil }
                        ForEach(AvatarFacialFeature.allCases, id: \.self) { option in
                            thumbnailSwatch(isSelected: draft.facialFeature == option) {
                                draft.facialFeature = option
                            } content: {
                                GeoAvatarCharacterView(skinTone: draft.skinTone, hairStyle: draft.hairStyle, hairColor: draft.hairColor, facialFeature: option, showHair: false)
                                    .scaleEffect(0.34)
                            }
                        }
                    }

                    Button("Kaydet") {
                        onSave(draftColorHex, draft)
                    }
                    .buttonStyle(.kasifPrimary)
                    .frame(maxWidth: .infinity)
                    .disabled(!hasChanges)
                }
                .padding(.bottom, GeoSpacing.xxxl)
            }
        }
        .padding(.horizontal, GeoSpacing.xl)
        .padding(.top, GeoSpacing.md)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
    }

    @ViewBuilder
    private func pickerSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(spacing: GeoSpacing.sm) {
            Text(LocalizedStringKey(title))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(GeoColor.textMuted)
            HStack(spacing: 14) {
                content()
            }
        }
    }

    private func colorSwatch(_ color: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 28, height: 28)
                .padding(4)
                .overlay {
                    if isSelected {
                        Circle().strokeBorder(GeoColor.textPrimary, lineWidth: 2.5)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private func thumbnailSwatch(isSelected: Bool, action: @escaping () -> Void, @ViewBuilder content: () -> some View) -> some View {
        Button(action: action) {
            Circle()
                .fill(GeoColor.bgSurface)
                .frame(width: 36, height: 36)
                // Şapka/uzun saç gibi katmanlar kanvasın kenarına taşabildiği için
                // (bkz. GeoAvatarCharacterView) küçük önizlemede daireye kırpmadan
                // düzensiz görünürdü.
                .overlay { content().clipShape(Circle()) }
                .overlay {
                    if isSelected {
                        Circle().strokeBorder(GeoColor.textPrimary, lineWidth: 2.5)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    /// Aksesuar/yüz detayı seçicilerindeki "Yok" şıkkı — tekli seçimi iptal eder.
    private func noneThumbnail(isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(GeoColor.bgSurface)
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(GeoColor.textMuted)
                }
                .overlay {
                    if isSelected {
                        Circle().strokeBorder(GeoColor.textPrimary, lineWidth: 2.5)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AvatarBuilderView(avatarColorHex: 0xFF987E, character: AvatarCharacter(), onBack: {}, onSave: { _, _ in })
}
