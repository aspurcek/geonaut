import Foundation

/// Hesap silinince Apple'a "bu uygulamanın Sign in with Apple iznini iptal et" demek (App Store kuralı 5.1.1(v)).
/// Apple bunu ancak gizli anahtarla (.p8) imzalanmış bir istekle kabul ediyor; anahtar uygulamaya GÖMÜLEMEZ,
/// bu yüzden küçük bir sunucu işlevi yapıyor (bkz. Server/revoke-apple-token). Adres henüz yazılmadıysa
/// (nil) hiçbir şey yapılmaz ve silme eskisi gibi çalışır.
enum AppleTokenRevocation {
    /// Sunucu işlevinin adresi (Netlify, Server/revoke-apple-token). nil yapılırsa iptal kapanır ve hesap silme eskisi gibi çalışır.
    static let endpoint: URL? = URL(string: "https://geonaut-revoke.netlify.app/revoke")

    static var isConfigured: Bool { endpoint != nil }

    /// En iyi çaba: ağ yoksa ya da sunucu hata verirse false döner; hesap silme bunu BEKLEMEDEN tamamlanmış sayılır.
    static func revoke(authorizationCode: String) async -> Bool {
        guard let endpoint else { return false }
        var request = URLRequest(url: endpoint, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["code": authorizationCode])
        guard let (_, response) = try? await URLSession.shared.data(for: request),
              let http = response as? HTTPURLResponse else { return false }
        return (200..<300).contains(http.statusCode)
    }
}
