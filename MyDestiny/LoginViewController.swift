//
//  LoginViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/2/14.
//

import UIKit
import MHLoadingButton
import FirebaseAuth
import FacebookLogin

class LoginViewController: UIViewController,UITextFieldDelegate {

    
    @IBOutlet weak var fbLoginBtn: FBLoginButton!
    @IBOutlet weak var loginBtn: LoadingButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.cornerRadius = 20
        loginBtn.indicator = BallPulseIndicator(color: .black)
        
    }
    @IBAction func fbLogin(_ sender: FBLoginButton) {
        Task{
            do{
                try await FirebaseConnet.shardd.loginWithFacebook(viewController: self)
            }catch{
                print("error\(error)")
                self.errorMessage(title: "登入失敗", message: "Facebook登入錯誤")
            }
        }
    }
    
    @IBAction func googleLogin(_ sender: Any) {
        
    }
    
    @IBAction func login(_ sender: LoadingButton) {
        if sender.isLoading {
            sender.hideLoader()
        } else {
            sender.showLoader(userInteraction: true)
            FirebaseConnet.shardd.loginWithEmail(email: "pete81833@gmail.com", password: "1119pet") {
                authResult, error in
                if let error = error  {
                    print("Error: \(error)")
                    self.errorMessage(title: "登入錯誤" , message: "\(error)")
                    sender.hideLoader()
                    return
                }
                guard let user = authResult?.user else{
                    assertionFailure("成功登入卻取不到user")
                    sender.hideLoader()
                    return
                }
                print("email: \(user.email) , userInfo?\(user.uid),\(user.email),\(user.displayName),\(user.photoURL)")
                
            }
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
