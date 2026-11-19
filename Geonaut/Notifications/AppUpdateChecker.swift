import Foundation
import Observation
import UIKit

/// App Store'da daha yeni sürüm varsa oyuncuya "Güncelle" der (kullanıcı kararı 2026-11-16).
/// Apple'ın herkese açık iTunes Lookup servisinden yalnızca uygulamanın kendi sürüm bilgisini okur;
/// istekte kullanıcıya ait hiçbir veri gönderilmez.
///
/// - 1.0.4 ZORUNLU GÜNCELLEME (kullanıcı kararı 2026-11-19, "güncellemeden oynatmasın"): mağazadaki sürüm
///   yayınlanalı 24 saati geçtiyse `mustUpdate` true olur ve uygulamanın tamamını kapatan, kapatılamayan
///   ForceUpdateView çıkar. İlk 24 saatte (Apple sürümü her ülkenin mağazasına hemen dağıtmayabilir,
///   oyuncu kilitli kalmasın diye) yalnızca kapatılabilir uyarı gösterilir. Mağaza, cihazın ülkesi için sorgulanır.
/// - Kapatılabilir uyarı: oyuncu güncelleyene kadar uygulama HER AÇILIŞTA sorar;
///   uygulama açık kaldıkça da 8 saatte bir yeniden sorar. "Sonra" ya da "Güncelle" (mağazayı açıp
///   güncellemezse) yalnızca o açılış içinde 8 saat erteler; kalıcı olarak susturulamaz.
/// - App Store her açılışta bir kez, açık kaldıkça 8 saatte bir sorgulanır; bilinen son sürüm saklanır,
///   ağ yoksa da hatırlatma çıkar.
/// - Cihazın iOS sürümü yeni sürümü desteklemiyorsa sormaz.
/// - Bu davranış yalnızca kendisini içeren sürümden itibaren çalışır (1.0.3'te: sürüm başına bir kez).
@MainActor
@Observable
final class AppUpdateChecker {
    static let shared = AppUpdateChecker()

    static let appStoreID = "6819617535"
    static var storeURL: URL { URL(string: "itms-apps://apps.apple.com/app/id\(appStoreID)")! }
    /// Hatırlatma ve mağaza sorgusu aralığı.
    static let interval: TimeInterval = 8 * 60 * 60

    /// Gösterilmesi gereken yeni sürüm (yoksa nil).
    private(set) var availableVersion: String?
    /// Zorunlu güncelleme: daha yeni sürüm yayınlanalı 24 saati geçti, oynamak engellenir.
    private(set) var mustUpdate = false
    /// Zorunlu hâle gelmeden önceki tolerans.
    static let gracePeriod: TimeInterval = 24 * 60 * 60

    private let defaults = UserDefaults.standard
    private static let lastCheckKey = "geonaut.update.lastCheck"
    private static let latestKnownKey = "geonaut.update.latestKnown"
    private static let latestReleaseDateKey = "geonaut.update.latestReleaseDate"
    private var isChecking = false
    /// Erteleme yalnızca bu açılış için (bellekte); uygulama yeniden açılınca uyarı yine çıkar.
    private var snoozedUntil: Date?
    /// Bu açılışta mağaza en son ne zaman sorgulandı (ilk kontrolde her zaman sorgulanır).
    private var lastFetchThisLaunch: Date?

    private init() {}

    var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    }

    func checkIfNeeded(now: Date = .now) async {
        #if DEBUG
        // Geliştirme: `-debugUpdate 1.0.9` ile sayfayı ağsız göster.
        if let forced = defaults.string(forKey: "debugUpdate"), !forced.isEmpty {
            availableVersion = forced
            mustUpdate = defaults.bool(forKey: "debugForceUpdate")
            return
        }
        #endif
        guard !isChecking else { return }

        // Mağazayı her açılışta bir kez, açık kaldıkça 8 saatte bir sorgula.
        if lastFetchThisLaunch == nil || now.timeIntervalSince(lastFetchThisLaunch!) >= Self.interval {
            lastFetchThisLaunch = now
            isChecking = true
            defer { isChecking = false }
            if let store = await Self.fetchStoreInfo() {
                defaults.set(now, forKey: Self.lastCheckKey)
                let supported = store.minimumOsVersion.map { !Self.isVersion($0, newerThan: UIDevice.current.systemVersion) } ?? true
                defaults.set(supported ? store.version : nil, forKey: Self.latestKnownKey)
                defaults.set(store.releaseDate, forKey: Self.latestReleaseDateKey)
            }
        }
        guard let latest = defaults.string(forKey: Self.latestKnownKey),
              Self.isVersion(latest, newerThan: currentVersion) else {
            mustUpdate = false
            availableVersion = nil
            return
        }
        // Zorunlu: yayın tarihi biliniyor ve 24 saat geçti.
        if let released = defaults.object(forKey: Self.latestReleaseDateKey) as? Date,
           now.timeIntervalSince(released) >= Self.gracePeriod {
            mustUpdate = true
            availableVersion = latest
            return
        }
        // İlk 24 saat: kapatılabilir uyarı (bu açılışta ertelendiyse 8 saat bekler).
        if let until = snoozedUntil, now < until { return }
        availableVersion = latest
    }

    /// "Sonra" ya da kaydırıp kapatma: 8 saat sonra yeniden sor.
    func dismiss(now: Date = .now) {
        snoozedUntil = now.addingTimeInterval(Self.interval)
        availableVersion = nil
    }

    /// "Güncelle": App Store sayfasını aç. Güncellemezse 8 saat sonra yeniden sorulur.
    func openStore(now: Date = .now) {
        snoozedUntil = now.addingTimeInterval(Self.interval)
        // Zorunlu güncellemede ekran kalır (oyuncu güncellemeden geri dönerse yine engellenir).
        if !mustUpdate { availableVersion = nil }
        UIApplication.shared.open(Self.storeURL)
    }

    // MARK: Yardımcılar

    private struct StoreInfo { let version: String; let minimumOsVersion: String?; let releaseDate: Date? }

    private static func fetchStoreInfo() async -> StoreInfo? {
        guard let bundleID = Bundle.main.bundleIdentifier,
              let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleID)&country=\(Locale.current.region?.identifier.lowercased() ?? "us")") else { return nil }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.httpMethod = "GET"
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              (response as? HTTPURLResponse)?.statusCode == 200,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let result = (json["results"] as? [[String: Any]])?.first,
              let version = result["version"] as? String else { return nil }
        let released = (result["currentVersionReleaseDate"] as? String).flatMap { ISO8601DateFormatter().date(from: $0) }
        return StoreInfo(version: version, minimumOsVersion: result["minimumOsVersion"] as? String, releaseDate: released)
    }

    /// "1.0.10" > "1.0.9" gibi sayısal karşılaştırma.
    static func isVersion(_ a: String, newerThan b: String) -> Bool {
        let pa = a.split(separator: ".").map { Int($0) ?? 0 }
        let pb = b.split(separator: ".").map { Int($0) ?? 0 }
        for i in 0..<max(pa.count, pb.count) {
            let x = i < pa.count ? pa[i] : 0, y = i < pb.count ? pb[i] : 0
            if x != y { return x > y }
        }
        return false
    }
}
