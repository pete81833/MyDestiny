//
//  LoginViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/2/14.
//

import UIKit
import TextFieldEffects
import FirebaseAuth
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended

class LoginViewController: UIViewController, NVActivityIndicatorViewable{
    
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    
    let size = CGSize(width: 30, height: 30)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func errorMessage(title: String, message: String){
        self.stopAnimating(nil)
        let aleart = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let aleartAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        aleart.addAction(aleartAction)
        self.present(aleart, animated: true, completion: nil)
    }
    
    func goHomePage(){
        DispatchQueue.main.async {
            self.stopAnimating(nil)
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

// MARK: LoginBtnFunction 
extension LoginViewController {
    
    
    @IBAction func fbLogin(_ sender: Any) {
        startAnimating(size, message: "Loading...", type: .ballScaleRipple, fadeInAnimation: nil)
        Task{
            do{
                let credential = try await SignIn.shared.loginWithFacebook(viewController: self)
                DispatchQueue.main.async {
                    NVActivityIndicatorPresenter.sharedInstance.setMessage("Authenticating...")
                }
                try await FirebaseConnet.shared.registerUserToFirebase(credential: credential)
                self.goHomePage()
            }catch{
                print(error.localizedDescription)
                //TODO: 重複email帳號處理
                self.errorMessage(title: "登入失敗", message: "Facebook登入錯誤")
            }
        }
    }
    
    @IBAction func googleLogin(_ sender: Any) {
        startAnimating(size, message: "Loading...", type: .ballScaleRipple, fadeInAnimation: nil)
        Task{
            do{
                let credential = try await SignIn.shared.LoginWithGoogle(viewController: self)
                print("Google登入成功")
                DispatchQueue.main.async {
                    NVActivityIndicatorPresenter.sharedInstance.setMessage("Authenticating...")
                }
                try await FirebaseConnet.shared.registerUserToFirebase(credential: credential)
                self.goHomePage()
            }catch{
                print(error.localizedDescription)
                self.errorMessage(title: "登入失敗", message: "Google登入錯誤")
            }
            
        }
    }
    
    @IBAction func appleLogin(_ sender: Any) {
        startAnimating(size, message: "Loading...", type: .ballScaleRipple, fadeInAnimation: nil)
        SignIn.shared.delegate = self
        SignIn.shared.loginWithApple(viewController: self)
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
        startAnimating(size, message: "Loading...", type: .ballScaleRipple, fadeInAnimation: nil)
        // 用email登入就會直接幫你串到firebase上了，不需要credential
        SignIn.shared.loginWithEmail(email: email, password: password, viewController: self) {
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
            DispatchQueue.main.async {
                NVActivityIndicatorPresenter.sharedInstance.setMessage("Authenticating...")
            }
            self.goHomePage()
            
        }
    }
    
}

// MARK:  FirebaseConnetDelegate
extension LoginViewController: SignInDelegate {
   
    func sucessLoginWithApple(credential: OAuthCredential) {
        Task{
            do{
                DispatchQueue.main.async {
                    NVActivityIndicatorPresenter.sharedInstance.setMessage("Authenticating...")
                }
                try await FirebaseConnet.shared.registerUserToFirebase(credential: credential)
                print("apple 註冊成功")
                self.goHomePage()
            }catch{
                print(error.localizedDescription)
                errorMessage(title: "登入錯誤", message: "apple帳號無法使用，請使用別的登入方式")
            }
        }
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
