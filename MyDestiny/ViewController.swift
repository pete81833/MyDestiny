//
//  ViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/2/11.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    @IBAction func signOut(_ sender: Any) {
        do{
            try FirebaseConnet.shared.signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginNavController = storyboard.instantiateViewController(identifier: "SignInNavigationController")

                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
        }catch{
            print(error.localizedDescription)
        }
    }
    
}

