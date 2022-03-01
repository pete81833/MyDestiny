//
//  ViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/2/11.
//

import UIKit
import Lottie

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        let animationView = AnimationView(name: "love-animation-with-particle")
//        animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
//        animationView.center = self.view.center
//        animationView.loopMode = .loop
//        animationView.contentMode = .scaleAspectFill
//
//        view.addSubview(animationView)
//
//        animationView.play()
        
        
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

