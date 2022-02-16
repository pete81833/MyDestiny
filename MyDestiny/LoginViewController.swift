//
//  LoginViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/2/14.
//

import UIKit
import MHLoadingButton
import FirebaseAuth
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended

class LoginViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var loginBtn: LoadingButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.cornerRadius = 20
        loginBtn.indicator = BallPulseIndicator(color: .black)
        
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
