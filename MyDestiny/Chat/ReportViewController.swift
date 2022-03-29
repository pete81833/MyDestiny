//
//  ReportViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/22.
//

import UIKit


class ReportViewController: UIViewController {

    var reportUserID: String?
    
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
        let alert = UIAlertController(title: "成功", message: "我們已經收到您的檢舉，審核成功後會email通知", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "確認", style: .default) { _ in
            self.dismiss(animated: true)
        }
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc func hideKeyboard(tapG:UITapGestureRecognizer){
        // 除了使用 self.view.endEditing(true)
        // 也可以用 resignFirstResponder()
        // 來針對一個元件隱藏鍵盤
        self.textView.resignFirstResponder()
    }
}
