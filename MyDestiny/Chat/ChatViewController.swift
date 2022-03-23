//
//  ChatViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/15.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    
    @IBOutlet weak var stackViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var keyboardHeight: CGFloat = 0
    let db = Firestore.firestore()
    var messageItems = [MessageItem]()
    var target: Qualified?
    var chatID: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapEvent = UITapGestureRecognizer(target: self, action: #selector(tableViewTap(sender: )))
        tableView.addGestureRecognizer(tapEvent)
        tableView.delegate = self
        tableView.dataSource = self
        keyboardNotificationSet()
        self.getMatchChatUID()
    }
    
    @objc func tableViewTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func tableViewScrollToBottom(){
        let indexPath = IndexPath(row: self.messageItems.count-1, section: 0)
        if indexPath.row == 0 {
            return
        }
        tableView.scrollToRow(at: indexPath , at: .bottom, animated: true)
    }
    
    //MARK: KEYBOARD
    func keyboardNotificationSet(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillShow (_ notification: Notification) {
        if let keyboard = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0, delay: 0, animations: {
                self.stackViewConstraint.constant = keyboard.cgRectValue.height - 49
                self.view.layoutIfNeeded()
            }, completion: nil)
            self.keyboardHeight = keyboard.cgRectValue.height
            tableViewScrollToBottom()
        }
    }
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        if let keyboard = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0, delay: 0, animations: {
                self.stackViewConstraint.constant = keyboard.cgRectValue.height - 49
                self.view.layoutIfNeeded()
            }, completion: nil)
            self.keyboardHeight = keyboard.cgRectValue.height
            tableViewScrollToBottom()
        }
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0, delay: 0, animations: {
            self.stackViewConstraint.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
        self.keyboardHeight = 0
        tableViewScrollToBottom()
    }
    
    
    
    func getMatchChatUID() {
        let matchChatRef = db.collection("Users").document(User.shared.uid!)
        matchChatRef.getDocument { result , error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let data = result?.data() else {
                print("Fail to get data")
                return
            }
            let match = data["match"] as! [String:String]
            let chatID = match[self.target!.uid]
            self.chatID = chatID
            print(self.chatID)
            self.settingFirebaseListener()
        }
    }
    
    func settingFirebaseListener(){
        db.collection("chats").document(chatID!).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            print("Current data: \(data)")
            self.messageItems.removeAll()
            for i in 0...data.count-1{
                guard let message = data["\(i)"] as? Array<String> else {
                    print("fail to get message")
                    return
                }
                let messageItem = MessageItem(uid: message[0], time: message[1], message: message[2])
                self.messageItems.append(messageItem)
            }
            self.tableView.reloadData()
            self.tableViewScrollToBottom()
        }
    }
    @IBAction func sendBtnPressed(_ sender: Any) {
        guard let text = inputTextField.text,
              text.isEmpty == false else {
                  return
              }
        FirebaseConnect.shared.sendMessage(chatID: self.chatID!, number: "\(messageItems.count)", message: text, uid: User.shared.uid!)
        self.inputTextField.text = ""
    }
    
    @objc func textViewLongTouchAction(sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: self.tableView)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "檢舉", style: .destructive) { action in
            print("\(location)")
            guard let indexPath = self.tableView.indexPathForRow(at: location) else {
                print("Fail to get indexPath")
                return
            }
            let content = self.messageItems.remove(at: indexPath.row)
            FirebaseConnect.shared.reportDirtyWord(dirtyWord: content.message)
            self.tableView.deleteRows(at: [indexPath], with: .right)
            self.showAlert(message: "檢舉成功，我們已經收到您檢舉")
            //TODO: firebse 刪除聊天訊息
        }
        let cancleAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(reportAction)
        alert.addAction(cancleAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageItems.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var longTouchAction = UILongPressGestureRecognizer(target: self, action: #selector(textViewLongTouchAction))
        
        if messageItems[indexPath.row].uid == User.shared.uid {
            let cell = tableView.dequeueReusableCell(withIdentifier: "meCell", for: indexPath) as! FromMeTableViewCell
            let message = messageItems[indexPath.row]
            cell.gestureRecognizers?.removeAll()
            cell.addGestureRecognizer(longTouchAction)
            cell.textView.text = message.message
            cell.textView.layer.cornerRadius = 10
            cell.textView.clipsToBounds = true
            cell.nameLable.text = User.shared.userName
            return cell
        } else if messageItems[indexPath.row].uid == ""{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "targetCell", for: indexPath) as! FromTargetTableViewCell
            let message = messageItems[indexPath.row]
            cell.gestureRecognizers?.removeAll()
            cell.addGestureRecognizer(longTouchAction)
            cell.textView.text = message.message
            cell.textView.layer.cornerRadius = 10
            cell.textView.clipsToBounds = true
            cell.nameLable.text = target?.name
            return cell
        }
        
    }
    
    
    
}


// MARK:  UITextFiedDelegate
extension ChatViewController: UITextFieldDelegate{
    // 關鍵盤
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

