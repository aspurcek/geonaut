import AuthenticationServices
import SwiftUI

/// Gerçek Sign in with Apple akışı. Ürün kararı gereği tek giriş yöntemi budur
/// (e-posta/Google yok). Başarılı girişte Apple'ın verdiği kararlı `userIdentifier`
/// CloudKit profilini bulmak/oluşturmak için kullanılır — bkz. PlayerCloudKitService.
@Observable
final class AppleSignInCoordinator: NSObject {
    enum State: Equatable {
        case idle
        case authorizing
        case failed(String)
    }

    private(set) var state: State = .idle

    /// Başarılı girişte çağrılır: (userIdentifier, tam ad ve e-posta — ikisi de yalnızca
    /// ilk girişte Apple tarafından verilir, sonraki girişlerde nil gelir).
    var onSignedIn: ((_ userIdentifier: String, _ fullName: PersonNameComponents?, _ email: String?) -> Void)?
    /// Kullanıcı vazgeçtiğinde ya da gerçek bir hata oluştuğunda çağrılır — nil ise
    /// kullanıcı iptal etti (hata mesajı gösterilmemeli), dolu ise gerçek hata mesajı.
    var onFailed: ((_ message: String?) -> Void)?

    /// Hesap silinirken: Apple'a verilen Sign in with Apple izninin iptali (token revocation) için taze bir
    /// `authorizationCode` ister. Kod yalnızca birkaç dakika geçerli olduğu için giriş anında saklanamaz;
    /// silme sırasında kullanıcı Apple'la yeniden onaylar. Vazgeçilir/başarısız olursa nil döner.
    @MainActor
    func requestAuthorizationCode() async -> String? {
        await withCheckedContinuation { continuation in
            codeContinuation = continuation
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = []
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    private var codeContinuation: CheckedContinuation<String?, Never>?

    func signIn() {
        state = .authorizing
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

extension AppleSignInCoordinator: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let continuation = codeContinuation {
            codeContinuation = nil
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential
            continuation.resume(returning: credential?.authorizationCode.flatMap { String(data: $0, encoding: .utf8) })
            return
        }
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            let message = String(localized: "Beklenmeyen kimlik bilgisi türü")
            state = .failed(message)
            onFailed?(message)
            return
        }
        state = .idle
        onSignedIn?(credential.user, credential.fullName, credential.email)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let continuation = codeContinuation {
            codeContinuation = nil
            continuation.resume(returning: nil)
            return
        }
        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            state = .idle // kullanıcı vazgeçti — hata değil
            onFailed?(nil)
        } else {
            state = .failed(error.localizedDescription)
            onFailed?(error.localizedDescription)
        }
    }
}

extension AppleSignInCoordinator: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first ?? ASPresentationAnchor()
    }
}
