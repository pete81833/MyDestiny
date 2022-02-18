//
//  FirebaseConnet.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/2/16.
//

import Foundation
import FirebaseAuth
import FacebookLogin

class FirebaseConnet: NSObject {
    
    typealias DoneHandler = ((AuthDataResult?, Error?) -> Void)
    
    enum facebookLoginError:Error {
        case cancelled
        case failed
        case connetToFirebaseFail
    }
    
    static let shardd = FirebaseConnet()
    
    private override init(){}
    
    func loginWithEmail(email: String, password: String, completion: @escaping DoneHandler) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
        
    }
    
    private func registerFacebookUserToFirebase() async throws {
        
        let idTokenString = AccessToken.current?.tokenString
        let credential = FacebookAuthProvider.credential(withAccessToken: idTokenString!)
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
                case .success(granted: let granted, declined: let declined, token: let token):
                    print("成功登入")
                    Task{
                        do{
                            try await self.registerFacebookUserToFirebase()
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
    
    
}

