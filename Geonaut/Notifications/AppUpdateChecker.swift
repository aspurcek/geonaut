import Foundation
import Observation
import UIKit

/// 1.0.4 (kullanıcı kararı 2026-11-16): App Store'da daha yeni sürüm varsa oyuncuya nazikçe
/// "Güncelle" der. Apple'ın herkese açık iTunes Lookup servisinden yalnızca uygulamanın kendi
/// sürüm bilgisini okur; istekte kullanıcıya ait hiçbir veri gönderilmez.
///
/// - Zorunlu değil: "Sonra" denirse o sürüm için bir daha sorulmaz, bir sonraki sürümde yeniden sorar.
/// - Günde en fazla bir kez kontrol eder.
/// - Cihazın iOS sürümü yeni sürümü desteklemiyorsa sormaz.
/// - Bu kontrol yalnızca kendisini içeren sürümden itibaren çalışır; daha eski sürümdeki
///   oyunculara geriye dönük uyarı gönderilemez.
@MainActor
@Observable
final class AppUpdateChecker {
    static let shared = AppUpdateChecker()

    static let appStoreID = "6819617535"
    static var storeURL: URL { URL(string: "itms-apps://apps.apple.com/app/id\(appStoreID)")! }

    /// Gösterilmesi gereken yeni sürüm (yoksa nil).
    private(set) var availableVersion: String?

    private let defaults = UserDefaults.standard
    private static let lastCheckKey = "geonaut.update.lastCheck"
    private static let dismissedKey = "geonaut.update.dismissedVersion"
    private var isChecking = false

    private init() {}

    var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    }

    func checkIfNeeded(now: Date = .now) async {
        #if DEBUG
        // Geliştirme: `-debugUpdate 1.0.9` ile sayfayı ağsız göster.
        if let forced = defaults.string(forKey: "debugUpdate"), !forced.isEmpty {
            availableVersion = forced
            return
        }
        #endif
        guard !isChecking, availableVersion == nil else { return }
        if let last = defaults.object(forKey: Self.lastCheckKey) as? Date, now.timeIntervalSince(last) < 24 * 60 * 60 { return }
        isChecking = true
        defer { isChecking = false }

        guard let store = await Self.fetchStoreInfo() else { return }
        defaults.set(now, forKey: Self.lastCheckKey)
        guard Self.isVersion(store.version, newerThan: currentVersion),
              store.version != defaults.string(forKey: Self.dismissedKey) else { return }
        if let minimumOS = store.minimumOsVersion,
           Self.isVersion(minimumOS, newerThan: UIDevice.current.systemVersion) { return }
        availableVersion = store.version
    }

    /// "Sonra": bu sürüm için bir daha sorma.
    func dismiss() {
        if let version = availableVersion { defaults.set(version, forKey: Self.dismissedKey) }
        availableVersion = nil
    }

    /// "Güncelle": App Store sayfasını aç.
    func openStore() {
        availableVersion = nil
        UIApplication.shared.open(Self.storeURL)
    }

    // MARK: Yardımcılar

    private struct StoreInfo { let version: String; let minimumOsVersion: String? }

    private static func fetchStoreInfo() async -> StoreInfo? {
        guard let bundleID = Bundle.main.bundleIdentifier,
              let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleID)") else { return nil }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.httpMethod = "GET"
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              (response as? HTTPURLResponse)?.statusCode == 200,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let result = (json["results"] as? [[String: Any]])?.first,
              let version = result["version"] as? String else { return nil }
        return StoreInfo(version: version, minimumOsVersion: result["minimumOsVersion"] as? String)
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
