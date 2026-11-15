import SwiftUI

/// Profil'deki "Arkadaşlar" bölümü — Game Center ile (bkz. GameCenterManager).
/// Bağlı değilken tanıtım kartı + "Game Center'a bağlan"; bağlıyken arkadaşlar puana göre
/// sıralanmış mini tablo (sen dahil) + "Arkadaş ekle".
struct FriendsSection: View {
    /// Oyuncunun kendi ömür boyu puanı (tabloda "Sen" satırı için ve skor gönderimi için).
    let myPoints: Int
    /// Tam "Arkadaşlar" ekranını açar (sıralama, davet, düellolar).
    var onOpen: () -> Void = {}
    var gameCenter = GameCenterManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: GeoSpacing.md) {
            HStack {
                Text("Arkadaşlar")
                    .font(GeoTypography.headingM)
                    .foregroundStyle(GeoColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Button(action: onOpen) {
                    HStack(spacing: 4) {
                        Text("Düello & sıralama")
                        Image(systemName: "arrow.right")
                    }
                    .font(GeoTypography.bodyBold)
                    .foregroundStyle(GeoColor.accentPrimaryStrong)
                }
                .buttonStyle(.plain)
            }

            content
                .frame(maxWidth: .infinity)
                .padding(GeoSpacing.lg)
                .background(GeoColor.bgSurface, in: RoundedRectangle(cornerRadius: GeoRadius.lg))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
        }
        .task {
            gameCenter.submit(points: myPoints)
            gameCenter.refreshIfSignedIn(myPoints: myPoints)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch gameCenter.status {
        case .idle, .unavailable:
            connectCard
        case .authenticating:
            ProgressView()
                .tint(GeoColor.accentPrimary)
                .frame(maxWidth: .infinity, minHeight: 80)
        case .signedIn:
            if gameCenter.friendsAccess == .denied {
                deniedCard
            } else if gameCenter.isLoadingFriends && gameCenter.friends.isEmpty {
                ProgressView()
                    .tint(GeoColor.accentPrimary)
                    .frame(maxWidth: .infinity, minHeight: 80)
            } else if gameCenter.friends.filter({ !$0.isMe }).isEmpty {
                emptyCard
            } else {
                friendsList
            }
        }
    }

    // MARK: Kartlar

    private var connectCard: some View {
        VStack(spacing: GeoSpacing.md) {
            HStack(spacing: GeoSpacing.md) {
                GeoGlyphCircle(symbol: "person.2.fill", background: GeoColor.accentTertiary, size: 48)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Arkadaşlarınla yarış")
                        .font(GeoTypography.title)
                        .foregroundStyle(GeoColor.textPrimary)
                    Text("Game Center'daki arkadaşlarını ekle, Geonaut puanlarınızı karşılaştırın.")
                        .font(GeoTypography.bodySemibold)
                        .foregroundStyle(GeoColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            if gameCenter.status == .unavailable {
                Text("Game Center'a bağlanılamadı. Ayarlar > Game Center'dan giriş yapıp tekrar dene.")
                    .font(GeoTypography.caption)
                    .foregroundStyle(GeoColor.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Button {
                gameCenter.authenticate()
            } label: {
                Label("Game Center'a bağlan", systemImage: "gamecontroller.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.kasifPrimary)
        }
    }

    private var emptyCard: some View {
        VStack(spacing: GeoSpacing.md) {
            GeoGlyphCircle(symbol: "person.2.fill", background: GeoColor.accentTertiary, size: 48)
            Text("Henüz Game Center arkadaşın yok")
                .font(GeoTypography.title)
                .foregroundStyle(GeoColor.textPrimary)
            Text("Arkadaşlarını davet et; Geonaut oynayanların puanları burada görünür.")
                .font(GeoTypography.bodySemibold)
                .foregroundStyle(GeoColor.textSecondary)
                .multilineTextAlignment(.center)
            Button {
                gameCenter.presentAddFriend()
            } label: {
                Label("Arkadaş ekle", systemImage: "person.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.kasifPrimary)
        }
    }

    private var deniedCard: some View {
        VStack(spacing: GeoSpacing.md) {
            GeoGlyphCircle(symbol: "lock.fill", background: GeoColor.bgLocked, size: 44)
            Text("Arkadaş listesine izin verilmedi")
                .font(GeoTypography.title)
                .foregroundStyle(GeoColor.textPrimary)
            Text("Arkadaşlarını görmek için Ayarlar'dan Geonaut'a Game Center arkadaş listesi izni ver.")
                .font(GeoTypography.bodySemibold)
                .foregroundStyle(GeoColor.textSecondary)
                .multilineTextAlignment(.center)
            Button("Ayarları aç") {
                if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
            }
            .buttonStyle(.kasifPrimary)
        }
    }

    // MARK: Liste

    private var friendsList: some View {
        VStack(spacing: GeoSpacing.sm) {
            ForEach(Array(gameCenter.friends.enumerated()), id: \.element.id) { index, friend in
                HStack(spacing: GeoSpacing.md) {
                    Text(verbatim: "\(index + 1)")
                        .font(GeoTypography.title)
                        .foregroundStyle(index == 0 ? GeoColor.accentHighlightStrong : GeoColor.textMuted)
                        .frame(width: 22)
                        .monospacedDigit()
                    avatar(friend)
                    Text(friend.isMe ? L("Sen") : friend.name)
                        .font(GeoTypography.bodyBoldL)
                        .foregroundStyle(GeoColor.textPrimary)
                        .lineLimit(1)
                    Spacer(minLength: GeoSpacing.sm)
                    if let points = friend.points {
                        HStack(spacing: 4) {
                            GeoGemIcon(size: 15)
                            Text(verbatim: "\(points)")
                                .font(GeoTypography.bodyBold)
                                .foregroundStyle(GeoColor.textPrimary)
                                .monospacedDigit()
                        }
                    } else {
                        Text(verbatim: "—")
                            .font(GeoTypography.bodyBold)
                            .foregroundStyle(GeoColor.textMuted)
                    }
                }
                .padding(.horizontal, GeoSpacing.sm)
                .padding(.vertical, 6)
                .background(friend.isMe ? GeoColor.accentPrimarySoft.opacity(0.18) : .clear, in: RoundedRectangle(cornerRadius: GeoRadius.md))
            }
        }
    }

    @ViewBuilder
    private func avatar(_ friend: GameCenterManager.Friend) -> some View {
        if let photo = friend.photo {
            Image(uiImage: photo)
                .resizable()
                .scaledToFill()
                .frame(width: 36, height: 36)
                .clipShape(Circle())
        } else {
            Text(String(friend.name.prefix(1)).uppercased())
                .font(GeoTypography.bodyBold)
                .foregroundStyle(GeoColor.accentTertiaryStrong)
                .frame(width: 36, height: 36)
                .background(GeoColor.accentTertiary, in: Circle())
        }
    }
}
