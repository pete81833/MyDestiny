//
//  LoginViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/2/14.
//

import UIKit
import MHLoadingButton

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func login(_ sender: LoadingButton) {
        
        if sender.isLoading {
            sender.hideLoader()
        } else {
            sender.showLoader(userInteraction: true)
        }
        
        
    }
    

}
