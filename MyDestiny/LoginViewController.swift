//
//  LoginViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/2/14.
//

import UIKit
import FacebookLogin
import TextFieldEffects

class LoginViewController: UIViewController{
    
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func errorMessage(title: String, message: String){
        let aleart = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let aleartAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        aleart.addAction(aleartAction)
        self.present(aleart, animated: true, completion: nil)
    }
    
    func goHomePage(){
        DispatchQueue.main.async {
            // ...
            // after login is done, maybe put this in the login web service completion block
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBarController = storyboard.instantiateViewController(identifier: "TabBarController")
            
            // This is to get the SceneDelegate object from your view controller
            // then call the change root view controller function to change to main tab bar
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
        }
    }
    
    

}

// MARK: LoginBtnFunc
extension LoginViewController {
    
    
    @IBAction func fbLogin(_ sender: FBLoginButton) {
        Task{
            do{
                try await FirebaseConnet.shared.loginWithFacebook(viewController: self)
                // TODO: 換頁
                self.goHomePage()
            }catch{
                print(error.localizedDescription)
                self.errorMessage(title: "登入失敗", message: "Facebook登入錯誤")
            }
        }
    }
    
    @IBAction func googleLogin(_ sender: Any) {
        Task{
            do{
                try await FirebaseConnet.shared.LoginWithGoogle(viewController: self)
                print("Google登入成功")
                // TODO: 換頁
                self.goHomePage()
            }catch{
                print(error.localizedDescription)
                self.errorMessage(title: "登入失敗", message: "Google登入錯誤")
            }
            
        }
    }
    
    @IBAction func appleLogin(_ sender: Any) {
        FirebaseConnet.shared.delegate = self
        FirebaseConnet.shared.loginWithApple(viewController: self)
    }
    
    @IBAction func emailLogin(_ sender: Any) {
        
        guard let email = emailTextField.text,
              email.isEmpty == false else {
                  self.emailTextField.shake()
                  return
              }
        guard let password = passwordTextField.text,
              password.isEmpty == false else {
                  self.passwordTextField.shake()
                  return
              }
        
        FirebaseConnet.shared.loginWithEmail(email: email, password: password) {
            authResult, error in
            if let error = error  {
                print("Error: \(error)")
                self.errorMessage(title: "登入錯誤" , message: "email帳密錯誤")
                return
            }
            guard let user = authResult?.user else{
                assertionFailure("成功登入卻取不到user")
                return
            }
            print("email: \(user.email) , userInfo?\(user.uid),\(user.email),\(user.displayName),\(user.photoURL)")
            self.goHomePage()
            
        }
        
    }
    
}

// MARK:  FirebaseConnetDelegate
extension LoginViewController: FirebaseConnetDelegate {
    func sucessLoginWithApple() {
        
        self.goHomePage()
        
    }
    
    func errorWithApple(error: NSError) {
        errorMessage(title: "登入錯誤", message: "apple登入錯誤")
    }
}

// MARK:  UITextFiedDelegate
extension LoginViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension TextFieldEffects {
    func shake(){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.1
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 5, y: self.center.y - 1))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 5, y: self.center.y + 1))
        self.layer.add(animation, forKey: "position")
    }
}
