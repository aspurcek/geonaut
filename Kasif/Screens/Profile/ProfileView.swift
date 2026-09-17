import SwiftUI

/// Figma "Profil" (node 350:13541) — bkz. Kaşif Uygulama Kural Kitabı böl. 08.
struct ProfileView: View {
    @Binding var selectedTab: KasifTab
    let displayName: String
    let email: String?
    let points: Int
    let streak: Int
    let avatarColorHex: UInt32
    let character: AvatarCharacter
    let progress: GameProgress
    var onSaveSettings: (_ displayName: String) -> Void
    var onSaveAvatar: (_ avatarColorHex: UInt32, _ character: AvatarCharacter) -> Void
    var onSeeAllBadges: () -> Void

    private enum Route: Hashable { case settings, avatarBuilder }
    @State private var path = NavigationPath()

    private var avatarColor: Color { Color(hex: avatarColorHex) }
    /// Kullanıcı kararı: bir soruda gösterilip cevaplanan (doğru/yanlış fark etmez)
    /// her ülke "öğrenilmiş" sayılır — bkz. GameProgress.markCountriesSeen.
    private var countriesLearned: Int { progress.learnedCountryCodes.count }

    // Bkz. KasifLevel.swift — Kural Kitabı böl. 07'nin tanımsız bıraktığı kademe
    // adları/puan eşikleri, içerik puan tavanlarına orantılı olarak burada karara bağlandı.
    private var level: KasifLevel { KasifLevel.level(forPoints: points) }
    private var levelTitle: String { "Kaşif seviyesi: \(level.title)" }
    let weekDayStates: [KasifDayChip.State] = [.completed, .completed, .completed, .active, .upcoming, .upcoming, .upcoming]

    /// Gerçek GameProgress'ten ilk 3 kıta rozeti + kategori kupası (bkz. BadgeCatalog) —
    /// önceden sabit/örnek veriydi. Tam liste "Tümünü Gör" ile Kupalar sekmesinde.
    private var previewBadges: [BadgeCatalog.BadgeInfo] {
        let flagBadges = BadgeCatalog.bayrakTahminBadges(progress: progress)
        return Array(flagBadges.prefix(3)) + [flagBadges[flagBadges.count - 1]]
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: KasifSpacing.xxl) {
                        VStack(spacing: 0) {
                            headerBanner
                            // Figma'da avatar banner'ın üstüne binmiyor; altında 22pt
                            // boşluklu ayrı bir blok (bkz. node 350:13541 metadata:
                            // banner height=92, avatar y=114).
                            avatarSection
                                .padding(.top, 22)
                        }

                        statCards
                            .padding(.horizontal, KasifSpacing.xl)

                        KasifStreakCalendar(dayStates: weekDayStates)
                            .padding(.horizontal, KasifSpacing.xl)

                        badgesSection
                            .padding(.horizontal, KasifSpacing.xl)
                    }
                    .padding(.bottom, KasifSpacing.xxxl)
                }
                KasifNavBar(selection: $selectedTab)
            }
            .background(KasifColor.bgCanvas)
            // ScrollView, alt view'ın kendi ignoresSafeArea'sını hiçe sayıp yine de
            // güvenli alan kadar üst boşluk bırakıyor — bu yüzden bleed işlemi
            // burada, en dıştaki container'da yapılmalı (NavBar'ın alt bleed'iyle aynı mantık).
            .ignoresSafeArea(edges: [.top, .bottom])
            .navigationBarHidden(true)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .settings:
                    SettingsView(
                        displayName: displayName, email: email, avatarColorHex: avatarColorHex, character: character,
                        onBack: { path.removeLast() },
                        onEditAvatar: { path.append(Route.avatarBuilder) },
                        onSave: { newName in
                            onSaveSettings(newName)
                            path.removeLast()
                        }
                    )
                    .navigationBarHidden(true)

                case .avatarBuilder:
                    AvatarBuilderView(
                        avatarColorHex: avatarColorHex, character: character,
                        onBack: { path.removeLast() },
                        onSave: { newColorHex, newCharacter in
                            onSaveAvatar(newColorHex, newCharacter)
                            path.removeLast()
                        }
                    )
                    .navigationBarHidden(true)
                }
            }
        }
    }

    private var headerBanner: some View {
        ZStack {
            KasifColor.accentTertiary
            Image(systemName: "star.fill").font(.system(size: 12)).foregroundStyle(.white.opacity(0.7))
                .position(x: 40, y: 25)
            Image(systemName: "star.fill").font(.system(size: 18)).foregroundStyle(.white.opacity(0.8))
                .position(x: 330, y: 30)
            Image(systemName: "star.fill").font(.system(size: 8)).foregroundStyle(.white.opacity(0.6))
                .position(x: 100, y: 65)
        }
        .frame(height: 92)
        .clipShape(.rect(bottomLeadingRadius: 32, bottomTrailingRadius: 32))
    }

    private var avatarSection: some View {
        VStack(spacing: KasifSpacing.sm) {
            ZStack(alignment: .bottomTrailing) {
                // Avatara dokunma → Avatarını Oluştur (ten/saç/aksesuar). Dişli rozetine
                // dokunma → Ayarlar (ad/e-posta). Kullanıcı isteği: bu ikisi ayrı yerlere gitsin.
                Button { path.append(Route.avatarBuilder) } label: {
                    KasifAvatar(backgroundColor: avatarColor, character: character)
                }
                .buttonStyle(.plain)

                Button { path.append(Route.settings) } label: {
                    Circle()
                        .fill(KasifColor.bgSurface)
                        .frame(width: 30, height: 30)
                        .overlay {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(KasifColor.textSecondary)
                        }
                }
                .buttonStyle(.plain)
            }
            .frame(width: 106, height: 106, alignment: .topLeading)

            VStack(spacing: KasifSpacing.xs) {
                Text(displayName)
                    .font(KasifTypography.headingL)
                    .foregroundStyle(KasifColor.textPrimary)
                KasifBadge(text: levelTitle, tone: level.badgeTone)
            }
        }
    }

    private var statCards: some View {
        HStack(spacing: 9) {
            KasifStatCard(type: .points, value: "\(points)")
            KasifStatCard(type: .streak, value: "\(streak)")
            KasifStatCard(type: .countriesLearned, value: "\(countriesLearned)")
        }
    }

    private var badgesSection: some View {
        VStack(spacing: KasifSpacing.md) {
            HStack {
                Text("Rozetler")
                    .font(KasifTypography.title)
                    .foregroundStyle(KasifColor.textPrimary)
                Spacer()
                Button("Tümünü Gör →", action: onSeeAllBadges)
                    .font(KasifTypography.bodySemibold)
                    .foregroundStyle(KasifColor.accentPrimary)
            }
            HStack(spacing: 14) {
                ForEach(previewBadges, id: \.title) { badge in
                    KasifAchievementBadge(title: badge.title, icon: badge.icon, accentColor: badge.accentColor, state: badge.unlocked ? .unlocked : .locked)
                }
            }
        }
    }
}

#Preview {
    ProfileView(
        selectedTab: .constant(.profile),
        displayName: "Aslı", email: "asli.karabulut@gmail.com", points: 340, streak: 4,
        avatarColorHex: 0xFF987E, character: AvatarCharacter(), progress: GameProgress(),
        onSaveSettings: { _ in }, onSaveAvatar: { _, _ in }, onSeeAllBadges: {}
    )
}
