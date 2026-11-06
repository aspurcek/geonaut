import SwiftUI

/// Figma "Profil" (node 350:13541) — bkz. Kaşif Uygulama Kural Kitabı böl. 08.
struct ProfileView: View {
    @Binding var selectedTab: GeoTab
    let displayName: String
    let email: String?
    let points: Int
    let streak: Int
    /// Haftalık seri takvimini gerçek veriden hesaplamak için (bkz. StreakStatus.weekDays).
    var lastActiveDate: Date = .now
    let avatarColorHex: UInt32
    let character: AvatarCharacter
    let progress: GameProgress
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var onSaveSettings: (_ displayName: String) -> Void
    var onSaveAvatar: (_ avatarColorHex: UInt32, _ character: AvatarCharacter) -> Void
    var onSeeAllBadges: () -> Void
    var onSignOut: () -> Void = {}
    var onDeleteAccount: () async -> Bool = { true }

    private enum Route: Hashable { case settings, avatarBuilder, photoCredits }
    @State private var path = NavigationPath()
    /// Rozet önizlemesine dokununca açılan bilgi penceresi (Rozetler sayfasındakiyle aynı bileşen).
    @State private var selectedBadge: BadgeCardInfo?
    @State private var showLevelSheet = false

    private var avatarColor: Color { Color(hex: avatarColorHex) }
    /// Kullanıcı kararı: bir soruda gösterilip cevaplanan (doğru/yanlış fark etmez)
    /// her ülke "öğrenilmiş" sayılır — bkz. GameProgress.markCountriesSeen.
    private var countriesLearned: Int { progress.learnedCountryCodes.count }

    // Bkz. GeoLevel.swift — Kural Kitabı böl. 07'nin tanımsız bıraktığı kademe
    // adları/puan eşikleri, içerik puan tavanlarına orantılı olarak burada karara bağlandı.
    /// Önceden sabit/örnek veriydi (herkes için aynı 3 yeşil gün); artık gerçek seriden hesaplanıyor.
    private var weekDayStates: [GeoDayChip.State] {
        StreakStatus.weekDays(lastActiveDate: lastActiveDate, streakDays: streak).map { day in
            switch day {
            case .completed: .completed
            case .playedToday: .playedToday
            case .active: .active
            case .missed: .missed
            case .upcoming: .upcoming
            }
        }
    }

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
                    VStack(spacing: GeoSpacing.xxl) {
                        VStack(spacing: 0) {
                            headerBanner
                            // Figma'da avatar banner'ın üstüne binmiyor; altında 22pt
                            // boşluklu ayrı bir blok (bkz. node 350:13541 metadata:
                            // banner height=92, avatar y=114).
                            avatarSection
                                .padding(.top, 22)
                        }

                        statCards
                            .padding(.horizontal, GeoSpacing.xl)

                        GeoStreakCalendar(dayStates: weekDayStates)
                            .padding(.horizontal, GeoSpacing.xl)

                        badgesSection
                            .padding(.horizontal, GeoSpacing.xl)
                    }
                    .padding(.bottom, GeoSpacing.xxxl)
                }
                GeoNavBar(selection: $selectedTab)
            }
            .background(GeoColor.bgCanvas)
            .badgeInfoSheet(selected: $selectedBadge)
            // ScrollView, alt view'ın kendi ignoresSafeArea'sını hiçe sayıp yine de
            // güvenli alan kadar üst boşluk bırakıyor — bu yüzden bleed işlemi
            // burada, en dıştaki container'da yapılmalı (NavBar'ın alt bleed'iyle aynı mantık).
            .ignoresSafeArea(edges: [.top, .bottom])
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .settings:
                    SettingsView(
                        displayName: displayName, email: email, avatarColorHex: avatarColorHex, character: character,
                        streakDays: streak,
                        onBack: { path.removeLast() },
                        onEditAvatar: { path.append(Route.avatarBuilder) },
                        onSave: { newName in
                            onSaveSettings(newName)
                            path.removeLast()
                        },
                        onSignOut: onSignOut, onDeleteAccount: onDeleteAccount,
                        onOpenCredits: { path.append(Route.photoCredits) }
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .photoCredits:
                    PhotoCreditsView(onBack: { path.removeLast() })
                        .toolbar(.hidden, for: .navigationBar)

                case .avatarBuilder:
                    AvatarBuilderView(
                        avatarColorHex: avatarColorHex, character: character,
                        onBack: { path.removeLast() },
                        onSave: { newColorHex, newCharacter in
                            onSaveAvatar(newColorHex, newCharacter)
                            path.removeLast()
                        }
                    )
                    .toolbar(.hidden, for: .navigationBar)
                }
            }
        }
    }

    private var headerBanner: some View {
        ZStack {
            GeoColor.accentTertiary
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
        VStack(spacing: GeoSpacing.sm) {
            ZStack(alignment: .bottomTrailing) {
                // Avatara dokunma → Avatarını Oluştur (ten/saç/aksesuar). Dişli rozetine
                // dokunma → Ayarlar (ad/e-posta). Kullanıcı isteği: bu ikisi ayrı yerlere gitsin.
                Button { path.append(Route.avatarBuilder) } label: {
                    GeoAvatar(backgroundColor: avatarColor, character: character)
                }
                .buttonStyle(.plain)

                Button { path.append(Route.settings) } label: {
                    Circle()
                        .fill(GeoColor.accentPrimary)
                        .frame(width: 30, height: 30)
                        .overlay { settingsIcon.foregroundStyle(.white) }
                }
                .buttonStyle(.plain)
            }
            .frame(width: 106, height: 106, alignment: .topLeading)

            VStack(spacing: GeoSpacing.xs) {
                Text(displayName)
                    .font(GeoTypography.headingL)
                    .foregroundStyle(GeoColor.textPrimary)
                levelBadge
                    .padding(.top, GeoSpacing.sm)
            }
        }
    }

    /// Sade ünvan alanı: ünvanın renginde, dokunulabilir rozet + altında ince simli çubuk.
    /// Detaylar (sıradaki ünvan, puan, tüm ünvanlar) rozete dokununca açılan alt sayfada.
    private var levelBadge: some View {
        let standing = LevelStanding(points: progress.lifetimePoints)
        return VStack(spacing: 10) {
            Button { showLevelSheet = true } label: {
                Text(L(standing.level.title))
                    .font(.custom(GeoFontName.balooBold, size: 16))
                .foregroundStyle(GeoColor.textPrimary)
                .padding(.horizontal, 16).padding(.vertical, 4)
                .background(standing.level.accentColor, in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Geonaut seviyesi: \(L(standing.level.title))"))
            .accessibilityHint(Text("Ünvan detaylarını açar"))

            VStack(spacing: 6) {
                GlitterBar(progress: standing.fraction, color: standing.level.accentColor, animated: !reduceMotion)
                    .frame(width: 160, height: 8)
                Group {
                    if let upper = standing.upper {
                        Text("\(standing.points) / \(upper) puan")
                    } else {
                        Text("\(standing.points) puan")
                    }
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(GeoColor.textSecondary)
                .monospacedDigit()
            }
        }
        .sheet(isPresented: $showLevelSheet) { LevelInfoSheet(standing: standing) }
    }

    /// Dişli yerine Figma "Icon/Settings" (node 347:55504) ile birebir aynı iki-kaydırıcı
    /// glifi — 24x24 doğal kanvasta çizilip rozet boyutuna ölçekleniyor.
    private var settingsIcon: some View {
        ZStack {
            Capsule().frame(width: 12.13, height: 2).position(x: 8.06, y: 8)
            Circle().frame(width: 4, height: 4).position(x: 18, y: 8)
            Capsule().frame(width: 12.13, height: 2).position(x: 15.94, y: 16)
            Circle().frame(width: 4, height: 4).position(x: 6, y: 16)
        }
        .frame(width: 24, height: 24)
        .scaleEffect(14.0 / 24.0)
    }

    private var statCards: some View {
        HStack(spacing: 9) {
            GeoStatCard(type: .points, value: "\(points)")
            GeoStatCard(type: .streak, value: "\(streak)")
            GeoStatCard(type: .countriesLearned, value: "\(countriesLearned)")
        }
    }

    private var badgesSection: some View {
        VStack(spacing: GeoSpacing.md) {
            HStack {
                Text("Rozetler")
                    .font(GeoTypography.title)
                    .foregroundStyle(GeoColor.textPrimary)
                Spacer()
                Button("Tümünü Gör →", action: onSeeAllBadges)
                    .font(GeoTypography.bodySemibold)
                    .foregroundStyle(GeoColor.accentPrimary)
            }
            HStack(spacing: 14) {
                ForEach(previewBadges, id: \.title) { badge in
                    Button {
                        selectedBadge = BadgeCardInfo(
                            title: badge.title, icon: badge.icon, accentColor: badge.accentColor,
                            unlocked: badge.unlocked, description: badge.description
                        )
                    } label: {
                        GeoAchievementBadge(title: badge.title, icon: badge.icon, accentColor: badge.accentColor, state: badge.unlocked ? .unlocked : .locked)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    ProfileView(
        selectedTab: .constant(.profile),
        displayName: "Aslı", email: "ornek@eposta.com", points: 340, streak: 4,
        avatarColorHex: 0xFF987E, character: AvatarCharacter(), progress: GameProgress(),
        onSaveSettings: { _ in }, onSaveAvatar: { _, _ in }, onSeeAllBadges: {}
    )
}
