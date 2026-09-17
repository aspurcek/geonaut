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
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(KasifColor.textPrimary)
                    .padding(KasifSpacing.sm)
            }

            Text("Avatarını Oluştur")
                .font(.custom(KasifFontName.balooExtraBold, size: 24))
                .foregroundStyle(KasifColor.textPrimary)
                .padding(.top, KasifSpacing.sm)
                .padding(.bottom, KasifSpacing.xl)

            ScrollView {
                VStack(spacing: KasifSpacing.xxl) {
                    KasifAvatar(backgroundColor: Color(hex: draftColorHex), character: draft)
                        .frame(maxWidth: .infinity)

                    pickerSection(title: "Zemin rengini seç") {
                        ForEach(KasifColor.avatarSwatches, id: \.hex) { swatch in
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
                                KasifAvatarCharacterView(skinTone: draft.skinTone, hairStyle: style, hairColor: draft.hairColor)
                                    .scaleEffect(0.34)
                            }
                        }
                    }

                    pickerSection(title: "Saç rengini seç") {
                        ForEach(KasifHairColor.options, id: \.hex) { option in
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
                                KasifAvatarCharacterView(skinTone: draft.skinTone, hairStyle: draft.hairStyle, hairColor: draft.hairColor, accessory: option)
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
                                KasifAvatarCharacterView(skinTone: draft.skinTone, hairStyle: draft.hairStyle, hairColor: draft.hairColor, facialFeature: option)
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
                .padding(.bottom, KasifSpacing.xxxl)
            }
        }
        .padding(.horizontal, KasifSpacing.xl)
        .padding(.top, KasifSpacing.md)
        .background(KasifColor.bgCanvas)
    }

    @ViewBuilder
    private func pickerSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(spacing: KasifSpacing.sm) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(KasifColor.textMuted)
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
                        Circle().strokeBorder(KasifColor.textPrimary, lineWidth: 2.5)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private func thumbnailSwatch(isSelected: Bool, action: @escaping () -> Void, @ViewBuilder content: () -> some View) -> some View {
        Button(action: action) {
            Circle()
                .fill(KasifColor.bgSurface)
                .frame(width: 36, height: 36)
                // Şapka/uzun saç gibi katmanlar kanvasın kenarına taşabildiği için
                // (bkz. KasifAvatarCharacterView) küçük önizlemede daireye kırpmadan
                // düzensiz görünürdü.
                .overlay { content().clipShape(Circle()) }
                .overlay {
                    if isSelected {
                        Circle().strokeBorder(KasifColor.textPrimary, lineWidth: 2.5)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    /// Aksesuar/yüz detayı seçicilerindeki "Yok" şıkkı — tekli seçimi iptal eder.
    private func noneThumbnail(isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(KasifColor.bgSurface)
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(KasifColor.textMuted)
                }
                .overlay {
                    if isSelected {
                        Circle().strokeBorder(KasifColor.textPrimary, lineWidth: 2.5)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AvatarBuilderView(avatarColorHex: 0xFF987E, character: AvatarCharacter(), onBack: {}, onSave: { _, _ in })
}
