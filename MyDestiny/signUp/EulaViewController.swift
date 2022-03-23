//
//  EulaViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/23.
//

import UIKit

class EulaViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let link = NSMutableAttributedString(string: "社群規範",attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25.0)])
        
        link.addAttribute(.link, value: "https://mydestinypete.blogspot.com/2022/03/blog-post.html", range: NSRange(location: 0,length: 4))
        textView.attributedText = link
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
