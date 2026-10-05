import SwiftUI
import UIKit

/// Figma "Profil-Ayarlar" (node 475:11482). Yalnızca ad değiştirme — kayıtlı e-posta
/// Apple ID'ye bağlı olduğu için salt okunur gösterilir (bkz. PlayerProfile.email).
/// Avatar karakteri (ten/saç/aksesuar) ve zemin rengi artık ayrı bir ekranda
/// düzenleniyor (bkz. AvatarBuilderView) — resme dokununca oraya gidilir.
struct SettingsView: View {
    let displayName: String
    let email: String?
    let avatarColorHex: UInt32
    let character: AvatarCharacter
    /// Bildirim metnine "X günlük serini kaybetme!" yazabilmek için (bkz. StreakReminderScheduler).
    var streakDays: Int = 0
    var onBack: () -> Void
    var onEditAvatar: () -> Void
    var onSave: (_ displayName: String) -> Void
    var onSignOut: () -> Void
    var onDeleteAccount: () async -> Bool
    /// "Görsel Kaynakları" — bazı yemek/tatlı/içecek görselleri Creative Commons BY
    /// lisansıyla kullanılıyor; lisans bunun için görünür bir atıf istiyor (bkz. PhotoCreditsView).
    var onOpenCredits: () -> Void = {}

    @State private var draftName: String
    @State private var isConfirmingSignOut = false
    @State private var isConfirmingDelete = false
    @State private var isDeleting = false
    @State private var deleteFailed = false
    /// Varsayılan kapalı: ebeveyn dostu — izin isteği yalnızca kullanıcı bilerek açtığında gelir.
    @AppStorage(StreakReminderScheduler.enabledDefaultsKey) private var dailyReminderEnabled = false
    @State private var showNotificationDeniedAlert = false

    init(
        displayName: String, email: String?, avatarColorHex: UInt32, character: AvatarCharacter,
        streakDays: Int = 0,
        onBack: @escaping () -> Void, onEditAvatar: @escaping () -> Void, onSave: @escaping (String) -> Void,
        onSignOut: @escaping () -> Void = {},
        onDeleteAccount: @escaping () async -> Bool = { true },
        onOpenCredits: @escaping () -> Void = {}
    ) {
        self.displayName = displayName
        self.email = email
        self.avatarColorHex = avatarColorHex
        self.character = character
        self.streakDays = streakDays
        self.onBack = onBack
        self.onEditAvatar = onEditAvatar
        self.onSave = onSave
        self.onSignOut = onSignOut
        self.onDeleteAccount = onDeleteAccount
        self.onOpenCredits = onOpenCredits
        _draftName = State(initialValue: displayName)
    }

    private var trimmedDraftName: String {
        String(draftName.trimmingCharacters(in: .whitespacesAndNewlines).prefix(30)) // makul üst sınır
    }

    private var hasChanges: Bool {
        !trimmedDraftName.isEmpty && trimmedDraftName != displayName
    }

    var body: some View {
        ScrollView {
            // Kullanıcı kararı: sayfa diğer ekranlar gibi (Ana Sayfa/Profil) TEK bir
            // ScrollView içinde baştan sona kaysın — geri oku/başlık sabit kalmasın.
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .accessibilityLabel("Geri")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(KasifColor.textPrimary)
                            .padding(KasifSpacing.sm)
                    }

                    Spacer()

                    // Kullanıcı kararı: Çıkış Yap, header alanının en sağında bir ikon
                    // olarak — aşağıdaki Bildirimler container'ının altındaki metin
                    // buton yerine (bkz. o zamanki karar, bununla değiştirildi).
                    Button {
                        isConfirmingSignOut = true
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .accessibilityLabel("Çıkış Yap")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(KasifColor.accentDanger)
                            .padding(KasifSpacing.sm)
                    }
                }

                Text("Ayarlar")
                    .font(.custom(KasifFontName.balooExtraBold, size: 24))
                    .foregroundStyle(KasifColor.textPrimary)
                    .padding(.top, KasifSpacing.sm)
                    .padding(.bottom, KasifSpacing.xl)

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
                            text: .constant(email ?? String(localized: "Apple ID e-postan paylaşılmadı"))
                        )
                        .disabled(true)

                        Button("Kaydet") {
                            onSave(trimmedDraftName)
                        }
                        .buttonStyle(.kasifPrimary)
                        .frame(maxWidth: .infinity)
                        .disabled(!hasChanges)
                    }

                    VStack(alignment: .leading, spacing: KasifSpacing.lg) {
                        Text("Bildirimler")
                            .font(KasifTypography.title)
                            .foregroundStyle(KasifColor.textPrimary)

                        Toggle(isOn: $dailyReminderEnabled) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Günlük Hatırlatma")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(KasifColor.textPrimary)
                                Text("O gün oynamadıysan akşam 19:00'da serini hatırlatırız.")
                                    .font(.system(size: 13))
                                    .foregroundStyle(KasifColor.textMuted)
                            }
                        }
                        .tint(KasifColor.accentPrimary)
                        .onChange(of: dailyReminderEnabled) { _, isOn in
                            if isOn {
                                Task {
                                    let granted = await StreakReminderScheduler.requestAuthorization()
                                    if granted {
                                        StreakReminderScheduler.reschedule(streakDays: streakDays, enabled: true)
                                    } else {
                                        dailyReminderEnabled = false
                                        showNotificationDeniedAlert = true
                                    }
                                }
                            } else {
                                StreakReminderScheduler.cancelAll()
                            }
                        }
                    }

                    // Kullanıcı kararı: Gizlilik/Görsel Kaynakları gibi yasal/hukuki
                    // bağlantılar tek bir "Yasal" başlığı altında toplanıyor — ileride
                    // KVKK vb. eklenirse aynı başlığın altına girecek.
                    VStack(alignment: .leading, spacing: KasifSpacing.md) {
                        Text("Yasal")
                            .font(KasifTypography.title)
                            .foregroundStyle(KasifColor.textPrimary)

                        if let privacyURL = LegalLinks.privacyPolicy {
                            Link("Gizlilik Politikası", destination: privacyURL)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(KasifColor.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button("Görsel Kaynakları", action: onOpenCredits)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(KasifColor.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Yanlışlıkla basılmasın diye üsttekilerden bilerek büyük bir boşlukla
                    // ayrılmış, ekranın en altında (kullanıcı kararı: "aradaki boşluk çok olmalı").
                    Button("Hesabımı Sil") {
                        isConfirmingDelete = true
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(KasifColor.textMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.top, KasifSpacing.xxxxl * 2)
                    .disabled(isDeleting)
                }
            }
            .padding(.horizontal, KasifSpacing.xl)
            .padding(.top, KasifSpacing.md)
            .padding(.bottom, KasifSpacing.xxxl)
        }
        .background { KasifColor.bgCanvas.ignoresSafeArea() }
        .alert("Çıkış yapmak istediğine emin misin?", isPresented: $isConfirmingSignOut) {
            Button("Vazgeç", role: .cancel) {}
            Button("Çıkış Yap", role: .destructive) { onSignOut() }
        }
        .alert("Hesabın silinsin mi?", isPresented: $isConfirmingDelete) {
            Button("Vazgeç", role: .cancel) {}
            Button("Hesabımı Sil", role: .destructive) {
                isDeleting = true
                Task {
                    let ok = await onDeleteAccount()
                    isDeleting = false
                    deleteFailed = !ok
                }
            }
        } message: {
            Text("Tüm ilerlemen, puanların ve rozetlerin kalıcı olarak silinir. Bu işlem geri alınamaz.")
        }
        .alert("Hesap silinemedi", isPresented: $deleteFailed) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text("İnternet bağlantını kontrol edip tekrar dene.")
        }
        .alert("Bildirim izni kapalı", isPresented: $showNotificationDeniedAlert) {
            Button("Ayarlar'ı Aç") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text("Hatırlatma gönderebilmemiz için Ayarlar'dan bildirim izni vermen gerekiyor.")
        }
    }
}

#Preview {
    SettingsView(
        displayName: "Aslı", email: "ornek@eposta.com", avatarColorHex: 0xFF987E, character: AvatarCharacter(),
        onBack: {}, onEditAvatar: {}, onSave: { _ in }, onSignOut: {}
    )
}
