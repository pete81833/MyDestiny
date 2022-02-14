//
//  LoginViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/2/14.
//

import UIKit
import MHLoadingButton
import FirebaseAuth

class LoginViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var loginBtn: LoadingButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginBtn.cornerRadius = 20
        self.loginBtn.indicator = BallPulseIndicator(color: .black)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func login(_ sender: LoadingButton) {
        if sender.isLoading {
            sender.hideLoader()
        } else {
            sender.showLoader(userInteraction: true)
        }
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
