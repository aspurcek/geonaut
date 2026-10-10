import Foundation

/// App Review ve tanıtım için demo hesabı: kullanıcı adı + şifre ile giriş, tüm özellikler açık.
/// Gerçek bir hesap değildir (bulutla ilgisi yok); yalnızca bir kapıdır, güvenlik amacı taşımaz.
enum DemoAccess {
    static let username = "demo"
    static let password = "geonaut2026"

    static func isValid(username: String, password: String) -> Bool {
        username.trimmingCharacters(in: .whitespaces).lowercased() == Self.username && password == Self.password
    }
}
