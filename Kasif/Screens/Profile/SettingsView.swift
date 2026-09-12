import SwiftUI

/// Figma "Profil-Ayarlar" (node 475:11482). Avatar rengi ve ad değiştirme — kayıtlı
/// e-posta Apple ID'ye bağlı olduğu için salt okunur gösterilir (bkz. PlayerProfile.email).
struct SettingsView: View {
    let displayName: String
    let email: String?
    let avatarColorHex: UInt32
    var onBack: () -> Void
    var onSave: (_ displayName: String, _ avatarColorHex: UInt32) -> Void

    @State private var draftName: String
    @State private var draftColorHex: UInt32

    init(displayName: String, email: String?, avatarColorHex: UInt32, onBack: @escaping () -> Void, onSave: @escaping (String, UInt32) -> Void) {
        self.displayName = displayName
        self.email = email
        self.avatarColorHex = avatarColorHex
        self.onBack = onBack
        self.onSave = onSave
        _draftName = State(initialValue: displayName)
        _draftColorHex = State(initialValue: avatarColorHex)
    }

    private var draftColor: Color {
        KasifColor.avatarSwatches.first { $0.hex == draftColorHex }?.color ?? Color(hex: draftColorHex)
    }

    private var trimmedDraftName: String {
        draftName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Figma'da "Kaydet" iki durumlu: değişiklik yokken pasif (%40 opak), bir şey
    /// değiştirildiğinde aktif — bkz. KasifButtonStyle'ın zaten desteklediği disabled.
    private var hasChanges: Bool {
        (!trimmedDraftName.isEmpty && trimmedDraftName != displayName) || draftColorHex != avatarColorHex
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
                        KasifAvatar(backgroundColor: draftColor, showSettingsBadge: true)

                        Text("Profil rengini seç")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(KasifColor.textMuted)

                        HStack(spacing: 14) {
                            ForEach(KasifColor.avatarSwatches, id: \.hex) { swatch in
                                Button {
                                    draftColorHex = swatch.hex
                                } label: {
                                    Circle()
                                        .fill(swatch.color)
                                        .frame(width: 28, height: 28)
                                        .padding(4)
                                        .overlay {
                                            if draftColorHex == swatch.hex {
                                                Circle().strokeBorder(KasifColor.textPrimary, lineWidth: 2.5)
                                            }
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
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
                            onSave(trimmedDraftName, draftColorHex)
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
    SettingsView(displayName: "Aslı", email: "asli.karabulut@gmail.com", avatarColorHex: 0xFF987E, onBack: {}, onSave: { _, _ in })
}
