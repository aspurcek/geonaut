import SwiftUI

/// Figma "Profil-Ayarlar" (node 475:11482). Yalnızca ad değiştirme — kayıtlı e-posta
/// Apple ID'ye bağlı olduğu için salt okunur gösterilir (bkz. PlayerProfile.email).
/// Avatar karakteri (ten/saç/aksesuar) ve zemin rengi artık ayrı bir ekranda
/// düzenleniyor (bkz. AvatarBuilderView) — resme dokununca oraya gidilir.
struct SettingsView: View {
    let displayName: String
    let email: String?
    let avatarColorHex: UInt32
    let character: AvatarCharacter
    var onBack: () -> Void
    var onEditAvatar: () -> Void
    var onSave: (_ displayName: String) -> Void

    @State private var draftName: String

    init(
        displayName: String, email: String?, avatarColorHex: UInt32, character: AvatarCharacter,
        onBack: @escaping () -> Void, onEditAvatar: @escaping () -> Void, onSave: @escaping (String) -> Void
    ) {
        self.displayName = displayName
        self.email = email
        self.avatarColorHex = avatarColorHex
        self.character = character
        self.onBack = onBack
        self.onEditAvatar = onEditAvatar
        self.onSave = onSave
        _draftName = State(initialValue: displayName)
    }

    private var trimmedDraftName: String {
        draftName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasChanges: Bool {
        !trimmedDraftName.isEmpty && trimmedDraftName != displayName
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(KasifColor.textPrimary)
                    .padding(KasifSpacing.sm)
            }

            Text("Ayarlar")
                .font(.custom(KasifFontName.balooExtraBold, size: 24))
                .foregroundStyle(KasifColor.textPrimary)
                .padding(.top, KasifSpacing.sm)
                .padding(.bottom, KasifSpacing.xl)

            ScrollView {
                VStack(alignment: .leading, spacing: KasifSpacing.xxl) {
                    VStack(spacing: KasifSpacing.md) {
                        Button(action: onEditAvatar) {
                            KasifAvatar(backgroundColor: Color(hex: avatarColorHex), character: character)
                        }
                        .buttonStyle(.plain)

                        Text("Avatarını düzenle")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(KasifColor.textMuted)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: KasifSpacing.lg) {
                        Text("Hesap Bilgileri")
                            .font(KasifTypography.title)
                            .foregroundStyle(KasifColor.textPrimary)

                        KasifTextField(label: "Ad", placeholder: "Ad", text: $draftName)

                        KasifTextField(
                            label: "Kayıtlı E-posta",
                            placeholder: "",
                            text: .constant(email ?? "Apple ID e-postan paylaşılmadı")
                        )
                        .disabled(true)

                        Button("Kaydet") {
                            onSave(trimmedDraftName)
                        }
                        .buttonStyle(.kasifPrimary)
                        .frame(maxWidth: .infinity)
                        .disabled(!hasChanges)
                    }
                }
                .padding(.bottom, KasifSpacing.xxxl)
            }
        }
        .padding(.horizontal, KasifSpacing.xl)
        .padding(.top, KasifSpacing.md)
        .background(KasifColor.bgCanvas)
    }
}

#Preview {
    SettingsView(
        displayName: "Aslı", email: "asli.karabulut@gmail.com", avatarColorHex: 0xFF987E, character: AvatarCharacter(),
        onBack: {}, onEditAvatar: {}, onSave: { _ in }
    )
}
