//
//  ReportViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/22.
//

import UIKit

protocol ReportViewControllerDelegate {
    func finishReport()
}

class ReportViewController: UIViewController {

    var reportUserID: String?
    let userDefault = UserDefaults()
    var delegate: ReportViewControllerDelegate?
    
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.borderWidth = 1
        
        // 增加一個觸控事件
        let tap = UITapGestureRecognizer(
          target: self,
          action: #selector(hideKeyboard))

        tap.cancelsTouchesInView = false

        // 加在最基底的 self.view 上
        self.view.addGestureRecognizer(tap)
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submit(_ sender: Any) {
        
        guard let reportContent = textView.text,
              reportContent.isEmpty != true else {
                  showAlert(message: "請輸入檢舉原因，以便審查")
                  return
              }
        
        guard let reportUserID = reportUserID else {
            return
        }

        FirebaseConnect.shared.reportUser(uid: reportUserID, content: reportContent)
        
        if let userBlocks = userDefault.value(forKey: "blocks") as? Array<String> {
            var blocks = userBlocks
            blocks.append(reportUserID)
            userDefault.set(blocks, forKey: "blocks")
            self.showAlert(message: "我們已收到您的檢舉")
            print(userDefault.value(forKey: "blocks"))
            self.dismiss(animated: true) {
                self.delegate?.finishReport()
            }
        }else {
            userDefault.set([reportUserID], forKey: "blocks")
            print(userDefault.value(forKey: "blocks"))
            self.dismiss(animated: true) {
                self.delegate?.finishReport()
            }
        }
        
    }
    
    @objc func hideKeyboard(tapG:UITapGestureRecognizer){
        // 除了使用 self.view.endEditing(true)
        // 也可以用 resignFirstResponder()
        // 來針對一個元件隱藏鍵盤
        self.textView.resignFirstResponder()
    }
}
