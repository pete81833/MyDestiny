//
//  LoginViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/2/14.
//

import UIKit
import FirebaseAuth
import FacebookLogin
import CryptoKit
import AuthenticationServices

class LoginViewController: UIViewController,UITextFieldDelegate{
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func fbLogin(_ sender: FBLoginButton) {
        Task{
            do{
                try await FirebaseConnet.shardd.loginWithFacebook(viewController: self)
                // TODO: 換頁
            }catch{
                print(error.localizedDescription)
                self.errorMessage(title: "登入失敗", message: "Facebook登入錯誤")
            }
        }
    }
    
    @IBAction func googleLogin(_ sender: Any) {
        Task{
            do{
                try await FirebaseConnet.shardd.LoginWithGoogle(viewController: self)
                print("Google登入成功")
                // TODO: 換頁
            }catch{
                print(error.localizedDescription)
                self.errorMessage(title: "登入失敗", message: "Google登入錯誤")
            }
            
        }
    }
    
    @IBAction func appleLogin(_ sender: Any) {
        FirebaseConnet.shardd.loginWithApple(viewController: self)
    }
    
    @IBAction func emailLogin(_ sender: Any) {
        
        FirebaseConnet.shardd.loginWithEmail(email: "pete81833@gmail.com", password: "1119pete") {
            authResult, error in
            if let error = error  {
                print("Error: \(error)")
                self.errorMessage(title: "登入錯誤" , message: "\(error)")
                return
            }
            guard let user = authResult?.user else{
                assertionFailure("成功登入卻取不到user")
                return
            }
            print("email: \(user.email) , userInfo?\(user.uid),\(user.email),\(user.displayName),\(user.photoURL)")
            
        }
        
    }
    
    func errorMessage(title: String, message: String){
        let aleart = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let aleartAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        aleart.addAction(aleartAction)
        self.present(aleart, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}


