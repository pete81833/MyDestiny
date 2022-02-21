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
        try? FirebaseConnet.shardd.signOut()
        self.performSegue(withIdentifier: "loginVC", sender: nil)
    }
    
}

