import SwiftUI

/// Figma Design System / Bileşenler / Avatar (node 162:397). 104pt renkli daire + katmanlı
/// karakter (bkz. KasifAvatarCharacterView). Zemin rengi ve karakter (ten/saç/aksesuar)
/// "Avatarını Oluştur" ekranında düzenleniyor (bkz. AvatarBuilderView). Bu view saf
/// görüntüleme amaçlı — ayarlar rozeti gibi interaktif eklentiler çağıran tarafta
/// (bkz. ProfileView.avatarSection: avatara dokunma ile rozete dokunma FARKLI yerlere gider).
struct KasifAvatar: View {
    var backgroundColor: Color = KasifColor.accentPrimarySoft
    var character = AvatarCharacter()

    var body: some View {
        Circle()
            .fill(backgroundColor)
            .frame(width: 104, height: 104)
            .overlay {
                KasifAvatarCharacterView(
                    skinTone: character.skinTone,
                    hairStyle: character.hairStyle,
                    hairColor: character.hairColor,
                    accessory: character.accessory,
                    facialFeature: character.facialFeature
                )
                .scaleEffect(0.9)
                // Şapka/saç gibi katmanlar 100x100 kanvasın kenarına yakın taşabilir
                // (bkz. KasifAvatarCharacterView) — daireye kırpmadan bu taşma
                // düzensiz/kesik görünürdü.
                .clipShape(Circle())
            }
    }
}

/// KasifAvatar ve AvatarBuilderView arasında paylaşılan, karakteri tanımlayan değerler —
/// bkz. PlayerProfile'daki kalıcı alanların taslak/geçici (draft) hâli.
struct AvatarCharacter: Equatable {
    var skinTone: SkinTone = .acik
    var hairStyle: HairStyle = .kisa
    var hairColorHex: UInt32 = 0x222938
    /// Kullanıcı kararı: aynı anda yalnızca BİR aksesuar / BİR yüz detayı.
    var accessory: AvatarAccessory? = nil
    var facialFeature: AvatarFacialFeature? = nil

    var hairColor: Color { Color(hex: hairColorHex) }
}

#Preview {
    HStack(spacing: KasifSpacing.xl) {
        KasifAvatar(backgroundColor: KasifColor.accentPrimarySoft, character: AvatarCharacter(hairStyle: .uzun, accessory: .gozluk))
        KasifAvatar(backgroundColor: KasifColor.accentSuccessStrong, character: AvatarCharacter(skinTone: .esmer, hairStyle: .kivircik, accessory: .sapka))
        KasifAvatar(backgroundColor: KasifColor.accentInfoStrong, character: AvatarCharacter(skinTone: .siyahi, hairStyle: .topuz, accessory: .kupe, facialFeature: .cil))
    }
    .padding(KasifSpacing.xxxl)
    .background(KasifColor.bgCanvas)
}
