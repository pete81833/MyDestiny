//
//  SignIn.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/1.
//

import Foundation
//---facebookLogin
import FacebookCore
import FacebookLogin
//---firebase
import FirebaseCore
import FirebaseAuth
import Firebase
//---GoogleSignIn
import GoogleSignIn
//---AppleSignIn
import AuthenticationServices

protocol SignInDelegate {
    func errorWithApple(error: NSError)
    func sucessLoginWithApple(credential: OAuthCredential)
}

class SignIn: NSObject{
    
    
    typealias DoneHandler = ((AuthDataResult?, Error?) -> Void)
    
    enum facebookLoginError:Error {
        case cancelled
        case failed
    }
    
    var delegate: SignInDelegate?
    
    var presentViewController: UIViewController?
    
    static let shared = SignIn()
    
    private override init(){}
    
    func loginWithEmail(email: String, password: String, viewController: UIViewController,  completion: @escaping DoneHandler) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    func LoginWithGoogle(viewController: UIViewController) async throws -> AuthCredential {
        
        return try await withCheckedThrowingContinuation({ continuation in
            
            guard let clintID = FirebaseApp.app()?.options.clientID else {
                assertionFailure("can't get firebase clientID")
                return
            }
            let config = GIDConfiguration(clientID: clintID)
            GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { user, error in
                if let error = error {
                    print(error.localizedDescription)
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let authentication = user?.authentication,
                      let idToken = authentication.idToken else {
                    assertionFailure("成功登入卻取不到 idToken")
                    return
                }
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
                continuation.resume(returning: credential)
            }
        })
        
    }
    
    func loginWithFacebook(viewController: UIViewController) async throws -> AuthCredential{
        
        return try await withCheckedThrowingContinuation({ continuation in
            
            let fbManger = LoginManager()
            fbManger.logIn(permissions: ["public_profile", "email"],
                           viewController: viewController) { result in
                
                switch result{
                case .cancelled:
                    print("使用者取消登入")
                    continuation.resume(throwing: facebookLoginError.cancelled)
                    break
                    
                case .failed:
                    print("FB登入失敗")
                    continuation.resume(throwing: facebookLoginError.failed)
                    break
                    
                case .success:
                    print("成功登入")
                    let idTokenString = AccessToken.current?.tokenString
                    let credential = FacebookAuthProvider.credential(withAccessToken: idTokenString!)
                    continuation.resume(returning: credential)
                    break
                }
            }
        })
    }
    
    func loginWithApple(viewController: UIViewController){
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        presentViewController = viewController
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

// apple login
extension SignIn: ASAuthorizationControllerDelegate{
    
    // 授權成功
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
                    
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                
                //印出使用者資訊
                print("user: \(appleIDCredential.user)")
                print("fullName: \(String(describing: appleIDCredential.fullName))")
                print("Email: \(String(describing: appleIDCredential.email))")
                print("realUserStatus: \(String(describing: appleIDCredential.realUserStatus))")
                //registerUserToFirebase
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nil)
                self.delegate?.sucessLoginWithApple(credential: credential)
                
            }
        }
    
    /// 授權失敗
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
        switch (error) {
        case ASAuthorizationError.canceled:
            break
        case ASAuthorizationError.failed:
            break
        case ASAuthorizationError.invalidResponse:
            break
        case ASAuthorizationError.notHandled:
            break
        case ASAuthorizationError.unknown:
            break
        default:
            break
        }
        
        print("didCompleteWithError: \(error.localizedDescription)")
        self.delegate?.errorWithApple(error: error as NSError)
        
    }
    
}

extension SignIn: ASAuthorizationControllerPresentationContextProviding {
    // 告訴apple sign 要在哪個畫面顯示登入介面
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return presentViewController!.view.window!
    }
}
