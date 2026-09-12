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
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            state = .failed("Beklenmeyen kimlik bilgisi türü")
            onFailed?("Beklenmeyen kimlik bilgisi türü")
            return
        }
        state = .idle
        onSignedIn?(credential.user, credential.fullName, credential.email)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
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
