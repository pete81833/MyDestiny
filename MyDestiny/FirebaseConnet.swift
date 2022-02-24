//
//  FirebaseConnet.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/2/16.
//

import Foundation
import FirebaseAuth
import FacebookLogin
import GoogleSignIn
import FirebaseCore
import UIKit
import CryptoKit
import AuthenticationServices

protocol FirebaseConnetDelegate {
    func errorWithApple(error: NSError)
    func sucessLoginWithApple()
}

class FirebaseConnet: NSObject {
    
    typealias DoneHandler = ((AuthDataResult?, Error?) -> Void)
    
    enum facebookLoginError:Error {
        case cancelled
        case failed
        case connetToFirebaseFail
    }
    
    var presentViewController: UIViewController?
    var delegate: FirebaseConnetDelegate?
    
    static let shared = FirebaseConnet()
    
    private override init(){}
    
    func loginWithEmail(email: String, password: String, completion: @escaping DoneHandler) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
        
    }
    
    private func registerUserToFirebase(credential: AuthCredential) async throws {
        let result = try  await Auth.auth().signIn(with: credential)
    }
    
    func loginWithFacebook(viewController: UIViewController) async throws {
        
        //
        return try await withCheckedThrowingContinuation({ continuation in
            
            //  進行facebook登入
            let fbManger = LoginManager()
            fbManger.logIn(permissions: ["public_profile", "email"],
                           viewController: viewController) {
                result in
                switch result{
                    
                case .cancelled:
                    continuation.resume(throwing: facebookLoginError.cancelled)
                    print("使用者取消登入")
                    break
                    
                case .failed:
                    continuation.resume(throwing: facebookLoginError.failed)
                    print("FB登入失敗")
                    break
                    
                case .success:
                    print("成功登入")
                    Task{
                        do{
                            let idTokenString = AccessToken.current?.tokenString
                            let credential = FacebookAuthProvider.credential(withAccessToken: idTokenString!)
                            try await self.registerUserToFirebase(credential: credential)
                            continuation.resume()
                        }catch{
                            print(error.localizedDescription)
                            continuation.resume(throwing: facebookLoginError.connetToFirebaseFail)
                        }
                    }
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
    
    func LoginWithGoogle(viewController: UIViewController) async throws {
        
        return try await withCheckedThrowingContinuation({ continuation in
            guard let clintID = FirebaseApp.app()?.options.clientID else {
                print("can't get firebase clientID")
                return
            }
            let config = GIDConfiguration(clientID: clintID)
            GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { user, error in
                if let error = error {
                    print(error.localizedDescription)
                    continuation.resume(throwing: error)
                    return
                }
                
                guard
                    let authentication = user?.authentication,
                    let idToken = authentication.idToken
                else {
                    print("成功登入卻取不到 idToken")
                    return
                }

                Task{
                    do{
                        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
                        try await self.registerUserToFirebase(credential: credential)
                        continuation.resume()
                    }catch{
                        print(error.localizedDescription)
                        continuation.resume(throwing: error)
                    }
                }
            }
        })
        
    }
    
    func signOut() throws{
        let firebaseAuth = Auth.auth()
        try firebaseAuth.signOut()
    }
    
}


// apple login
extension FirebaseConnet: ASAuthorizationControllerDelegate{
    
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
                Task{
                    do{
                        try await self.registerUserToFirebase(credential: credential)
                        print("apple 註冊成功")
                        self.delegate?.sucessLoginWithApple()
                        
                    }catch{
                        print(error)
                        self.delegate?.errorWithApple(error: error as NSError)
                    }
                }
                
                
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

extension FirebaseConnet: ASAuthorizationControllerPresentationContextProviding {
    // 告訴apple sign 要在哪個畫面顯示登入介面
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return presentViewController!.view.window!
    }
}
