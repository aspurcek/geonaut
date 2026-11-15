import SwiftUI

/// "Arkadaşlar" ekranı (Figma FLOW12 1119:23344): Bu hafta / Tüm zamanlar sıralaması, arkadaş
/// daveti (+25 puan), düellolarım ve her arkadaşın yanında "Düello". Düello için Game Center şart.
struct FriendsView: View {
    let me: DuelPlayerInfo
    let myCategories: [String]
    let myPoints: Int
    var onBack: () -> Void

    var gameCenter = GameCenterManager.shared
    var duels = DuelManager.shared
    var stats = SocialStats.shared

    @State private var playContext: DuelManager.PlayContext?
    @State private var showGameCenterRequired = false
    @State private var toast: String?
    @State private var busyID: String?

    var body: some View {
        VStack(spacing: 0) {
            GeoScreenHeader(title: "Arkadaşlar", onBack: onBack)
                .padding(.horizontal, GeoSpacing.xl)
                .padding(.bottom, GeoSpacing.md)

            ScrollView {
                VStack(alignment: .leading, spacing: GeoSpacing.lg) {
                    if gameCenter.isSignedIn {
                        scopePicker
                        inviteCard
                        if !duels.entries.isEmpty { duelsSection }
                        rankingSection
                    } else {
                        connectCard
                    }
                    #if DEBUG
                    botButton
                    #endif
                    Text("Düello daveti Game Center bildirimiyle gider. Arkadaşın 3 gün içinde oynamazsa davet düşer.")
                        .font(GeoTypography.caption)
                        .foregroundStyle(GeoColor.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, GeoSpacing.xl)
                .padding(.bottom, GeoSpacing.xxxl)
            }
            .refreshable {
                await gameCenter.reloadFriends(myPoints: myPoints)
                await duels.refresh()
            }
        }
        .padding(.top, GeoSpacing.md)
        .background { GeoColor.bgCanvas.ignoresSafeArea() }
        .overlay(alignment: .bottom) {
            if let toast {
                GeoToast(message: toast, tone: .success)
                    .padding(.horizontal, GeoSpacing.xl)
                    .padding(.bottom, GeoSpacing.xl)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .task {
            duels.me = me
            duels.myCategories = myCategories
            #if DEBUG
            if UserDefaults.standard.bool(forKey: "debugFriends") {
                gameCenter.debugFill(myPoints: myPoints)
                duels.debugFillEntries()
                return
            }
            #endif
            gameCenter.refreshIfSignedIn(myPoints: myPoints)
            await duels.refresh()
        }
        .onChange(of: gameCenter.scope) {
            #if DEBUG
            if UserDefaults.standard.bool(forKey: "debugFriends") { gameCenter.debugFill(myPoints: myPoints); return }
            #endif
            Task { await gameCenter.reloadFriends(myPoints: myPoints) }
        }
        .onChange(of: gameCenter.isSignedIn) { _, signedIn in
            if signedIn { showGameCenterRequired = false }
        }
        .fullScreenCover(item: $playContext) { context in
            DuelFlowView(context: context, onClose: {
                playContext = nil
                Task { await duels.refresh() }
            }, onRematch: { old, opponentID in
                playContext = nil
                rematch(old, opponentID: opponentID)
            })
        }
        .sheet(isPresented: $showGameCenterRequired) {
            GameCenterRequiredSheet(onConnect: { gameCenter.authenticate() }, onLater: { showGameCenterRequired = false })
        }
        .alert("Bir sorun oldu", isPresented: Binding(get: { duels.errorMessage != nil }, set: { if !$0 { duels.errorMessage = nil } })) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(duels.errorMessage ?? "")
        }
    }

    // MARK: Bölümler

    private var scopePicker: some View {
        HStack(spacing: 0) {
            scopeTab("Bu hafta", .week)
            scopeTab("Tüm zamanlar", .allTime)
        }
        .padding(4)
        .background(GeoColor.bgLocked, in: Capsule())
    }

    private func scopeTab(_ title: LocalizedStringKey, _ scope: GameCenterManager.Scope) -> some View {
        let selected = gameCenter.scope == scope
        return Button {
            withAnimation(.spring(duration: 0.3)) { gameCenter.scope = scope }
        } label: {
            Text(title)
                .font(.custom(GeoFontName.balooBold, size: 14))
                .foregroundStyle(selected ? GeoColor.textPrimary : GeoColor.textMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, GeoSpacing.sm)
                .background(selected ? GeoColor.bgSurface : .clear, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var inviteCard: some View {
        HStack(spacing: GeoSpacing.md) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(GeoColor.accentTertiaryStrong)
                .frame(width: 48, height: 48)
                .background(GeoColor.bgSurface, in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("Arkadaşını davet et")
                    .font(GeoTypography.title)
                    .foregroundStyle(GeoColor.textPrimary)
                HStack(spacing: 4) {
                    Text("Her yeni arkadaş için +\(DuelRules.friendReward)")
                        .font(GeoTypography.bodySemibold)
                        .foregroundStyle(GeoColor.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    GeoGemIcon(size: 14)
                }
            }
            Spacer(minLength: 0)
            Button {
                gameCenter.presentAddFriend()
            } label: {
                Text("Davet et")
                    .font(GeoTypography.bodyBold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(GeoColor.accentPrimaryStrong, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(GeoSpacing.lg)
        .background(GeoColor.accentTertiary, in: RoundedRectangle(cornerRadius: GeoRadius.xl))
    }

    private var duelsSection: some View {
        VStack(alignment: .leading, spacing: GeoSpacing.sm) {
            Text("Düellolarım")
                .font(GeoTypography.headingM)
                .foregroundStyle(GeoColor.textPrimary)
            VStack(spacing: 6) {
                ForEach(duels.entries) { entry in
                    duelRow(entry)
                }
            }
            .padding(GeoSpacing.md)
            .background(GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: GeoRadius.lg))
        }
    }

    private func duelRow(_ entry: DuelManager.Entry) -> some View {
        HStack(spacing: GeoSpacing.md) {
            DuelAvatar(info: entry.opponentInfo, size: 38)
            VStack(alignment: .leading, spacing: 0) {
                Text(entry.opponentName)
                    .font(GeoTypography.bodyBoldL)
                    .foregroundStyle(GeoColor.textPrimary)
                    .lineLimit(1)
                Text(status(entry))
                    .font(GeoTypography.caption)
                    .foregroundStyle(statusColor(entry))
            }
            Spacer(minLength: GeoSpacing.sm)
            switch entry.state {
            case .yourTurn:
                actionPill("Oyna", systemImage: "play.fill", busy: busyID == entry.id) { play(entry) }
            case .waiting:
                Image(systemName: "hourglass")
                    .foregroundStyle(GeoColor.textMuted)
            case .finished:
                if let id = entry.opponentID {
                    actionPill("Rövanş", systemImage: "arrow.triangle.2.circlepath", busy: busyID == id) { challenge(id) }
                }
            case .expired:
                Button("Kaldır") { Task { await duels.remove(entry) } }
                    .font(GeoTypography.bodyBold)
                    .foregroundStyle(GeoColor.textMuted)
            }
        }
        .padding(6)
    }

    private func status(_ entry: DuelManager.Entry) -> LocalizedStringKey {
        switch entry.state {
        case .yourTurn: return "Sıra sende"
        case .waiting: return "Sırası bekleniyor"
        case .expired: return "Süresi doldu"
        case .finished(let outcome):
            let myID = duels.me?.id ?? me.id
            let mine = entry.data?.results[myID]?.correct ?? 0
            let theirs = entry.data?.results.first { $0.key != myID }?.value.correct ?? 0
            switch outcome {
            case .won: return "Kazandın · \(mine)–\(theirs)"
            case .lost: return "Kaybettin · \(mine)–\(theirs)"
            case .tied: return "Berabere · \(mine)–\(theirs)"
            }
        }
    }

    private func statusColor(_ entry: DuelManager.Entry) -> Color {
        switch entry.state {
        case .yourTurn: GeoColor.accentPrimaryStrong
        case .finished(.won): GeoColor.accentSuccessText
        default: GeoColor.textMuted
        }
    }

    private var rankingSection: some View {
        VStack(alignment: .leading, spacing: GeoSpacing.sm) {
            Text(gameCenter.scope == .week ? "Bu haftanın sıralaması" : "Tüm zamanların sıralaması")
                .font(GeoTypography.headingM)
                .foregroundStyle(GeoColor.textPrimary)
            VStack(spacing: 6) {
                if gameCenter.friendsAccess == .denied {
                    Text("Arkadaşlarını görmek için Ayarlar'dan Geonaut'a Game Center arkadaş listesi izni ver.")
                        .font(GeoTypography.bodySemibold)
                        .foregroundStyle(GeoColor.textSecondary)
                        .padding(GeoSpacing.sm)
                } else if gameCenter.friends.filter({ !$0.isMe }).isEmpty && !gameCenter.isLoadingFriends {
                    Text("Henüz Game Center arkadaşın yok. Yukarıdan davet et; Geonaut oynayanlar burada görünür.")
                        .font(GeoTypography.bodySemibold)
                        .foregroundStyle(GeoColor.textSecondary)
                        .padding(GeoSpacing.sm)
                }
                ForEach(Array(gameCenter.friends.enumerated()), id: \.element.id) { index, friend in
                    rankRow(index: index, friend: friend)
                }
            }
            .padding(GeoSpacing.md)
            .background(GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: GeoRadius.lg))
        }
    }

    private func rankRow(index: Int, friend: GameCenterManager.Friend) -> some View {
        HStack(spacing: GeoSpacing.md) {
            Text(verbatim: "\(index + 1)")
                .font(GeoTypography.title)
                .foregroundStyle(index == 0 ? GeoColor.accentHighlightStrong : GeoColor.textMuted)
                .frame(width: 20)
                .monospacedDigit()
            if friend.isMe {
                DuelAvatar(info: me, size: 38)
            } else if let photo = friend.photo {
                Image(uiImage: photo).resizable().scaledToFill().frame(width: 38, height: 38).clipShape(Circle())
            } else {
                Text(String(friend.name.prefix(1)).uppercased())
                    .font(GeoTypography.bodyBold)
                    .foregroundStyle(GeoColor.accentTertiaryStrong)
                    .frame(width: 38, height: 38)
                    .background(GeoColor.accentTertiary, in: Circle())
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(friend.isMe ? L("Sen") : friend.name)
                    .font(GeoTypography.bodyBoldL)
                    .foregroundStyle(GeoColor.textPrimary)
                    .lineLimit(1)
                if !friend.isMe {
                    Text(stats.record(with: friend.id).map { LocalizedStringKey($0.summary) } ?? "Düello yok")
                        .font(GeoTypography.caption)
                        .foregroundStyle(GeoColor.textMuted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            Spacer(minLength: GeoSpacing.sm)
            HStack(spacing: 4) {
                GeoGemIcon(size: 15)
                Text(verbatim: friend.points.map(String.init) ?? "—")
                    .font(GeoTypography.bodyBold)
                    .foregroundStyle(GeoColor.textPrimary)
                    .monospacedDigit()
            }
            .fixedSize()
            if !friend.isMe {
                actionPill("Düello", systemImage: "flag.2.crossed.fill", busy: busyID == friend.id) { challenge(friend.id) }
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .background(friend.isMe ? GeoColor.accentPrimarySoft.opacity(0.18) : .clear, in: RoundedRectangle(cornerRadius: GeoRadius.md))
    }

    private func actionPill(_ title: LocalizedStringKey, systemImage: String, busy: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if busy {
                    ProgressView().tint(.white).controlSize(.mini)
                } else {
                    Image(systemName: systemImage).font(.system(size: 11, weight: .bold))
                }
                Text(title).font(GeoTypography.bodyBold)
            }
            .foregroundStyle(.white)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(GeoColor.accentPrimaryStrong, in: Capsule())
            .fixedSize()
        }
        .buttonStyle(.plain)
        .disabled(busy)
    }

    private var connectCard: some View {
        VStack(spacing: GeoSpacing.md) {
            GeoGlyphCircle(symbol: "gamecontroller.fill", background: GeoColor.accentTertiary, size: 64)
            Text("Arkadaşlarınla yarış")
                .font(GeoTypography.headingM)
                .foregroundStyle(GeoColor.textPrimary)
            Text("Sıralama, arkadaş daveti ve düellolar için Game Center'a bağlan.")
                .font(GeoTypography.bodySemibold)
                .foregroundStyle(GeoColor.textSecondary)
                .multilineTextAlignment(.center)
            if gameCenter.status == .unavailable {
                Text("Game Center'a bağlanılamadı. Ayarlar > Game Center'dan giriş yapıp tekrar dene.")
                    .font(GeoTypography.caption)
                    .foregroundStyle(GeoColor.textMuted)
                    .multilineTextAlignment(.center)
            }
            Button {
                gameCenter.authenticate()
            } label: {
                Group {
                    if gameCenter.status == .authenticating {
                        ProgressView().tint(.white)
                    } else {
                        Label("Game Center'a bağlan", systemImage: "gamecontroller.fill")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.kasifPrimary)
        }
        .padding(GeoSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: GeoRadius.lg))
    }

    #if DEBUG
    /// Yalnızca geliştirme sürümü: Game Center olmadan tek başına düello denemek için bot rakip.
    private var botButton: some View {
        Button {
            duels.me = me
            duels.myCategories = myCategories
            playContext = duels.startBotDuel()
        } label: {
            Label("Bot düellosu (test)", systemImage: "cpu")
                .font(GeoTypography.bodyBold)
                .foregroundStyle(GeoColor.accentInfoStrong)
                .frame(maxWidth: .infinity)
                .padding(.vertical, GeoSpacing.md)
                .background(GeoColor.accentInfo.opacity(0.25), in: RoundedRectangle(cornerRadius: GeoRadius.md))
        }
        .buttonStyle(.plain)
    }
    #endif

    // MARK: Eylemler

    private func challenge(_ friendID: String) {
        guard gameCenter.isSignedIn else { showGameCenterRequired = true; return }
        busyID = friendID
        Task {
            await duels.challenge(friendID: friendID)
            busyID = nil
            if duels.errorMessage == nil { showToast(L("Düello daveti gönderildi")) }
        }
    }

    private func play(_ entry: DuelManager.Entry) {
        busyID = entry.id
        Task {
            playContext = await duels.startPlaying(entry)
            busyID = nil
        }
    }

    private func rematch(_ old: DuelManager.PlayContext, opponentID: String) {
        #if DEBUG
        if old.isBot {
            Task {
                try? await Task.sleep(for: .milliseconds(450))
                playContext = duels.startBotDuel()
            }
            return
        }
        #endif
        challenge(opponentID)
    }

    private func showToast(_ message: String) {
        withAnimation { toast = message }
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            withAnimation { toast = nil }
        }
    }
}

/// "Düello için Game Center'a bağlan" alt sayfası (Figma FLOW12 1119:23469).
struct GameCenterRequiredSheet: View {
    var onConnect: () -> Void
    var onLater: () -> Void
    var gameCenter = GameCenterManager.shared

    var body: some View {
        VStack(spacing: GeoSpacing.md) {
            GeoGlyphCircle(symbol: "gamecontroller.fill", background: GeoColor.accentTertiary, size: 72)
            Text("Düello için Game Center'a bağlan")
                .font(GeoTypography.headingL)
                .foregroundStyle(GeoColor.textPrimary)
                .multilineTextAlignment(.center)
            Text("Düellolar Game Center üzerinden oynanır: davet, sıra ve sonuç arkadaşınla eşleşir. Bağlanmadan düelloya girilemez.")
                .font(GeoTypography.bodySemibold)
                .foregroundStyle(GeoColor.textSecondary)
                .multilineTextAlignment(.center)
            if gameCenter.status == .unavailable {
                Text("Game Center'a bağlanılamadı. Ayarlar > Game Center'dan giriş yapıp tekrar dene.")
                    .font(GeoTypography.caption)
                    .foregroundStyle(GeoColor.textMuted)
                    .multilineTextAlignment(.center)
            }
            Button(action: onConnect) {
                Group {
                    if gameCenter.status == .authenticating {
                        ProgressView().tint(.white)
                    } else {
                        Label("Game Center'a bağlan", systemImage: "gamecontroller.fill")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.kasifPrimary)
            Button("Şimdi değil", action: onLater)
                .font(GeoTypography.bodyBold)
                .foregroundStyle(GeoColor.textMuted)
        }
        .padding(.horizontal, GeoSpacing.xxl)
        .padding(.top, GeoSpacing.xxl)
        .padding(.bottom, GeoSpacing.lg)
        .presentationDetents([.height(420)])
        .presentationDragIndicator(.visible)
        .presentationBackground(GeoColor.bgSurface)
    }
}
