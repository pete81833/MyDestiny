//
//  SearchTableViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/1.
//

import UIKit
import CoreBluetooth
import Firebase
import UserNotifications

protocol SearchTableViewControllerDelegate {
    
}

class SearchTableViewController: UITableViewController {

    var central: Central?
    var peripheral: Peripheral?
    let targetServiceUUIDs = [CBUUID(string: "1234")]
    let targetCharUUIDs = [CBUUID(string: "1234")]
    var allItems = [String: DiscoveredItem]()
    let dateFormatter = DateFormatter()
    var qualifieds: [Qualified] = []
    let userDefault = UserDefaults()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 檢查userData 是否存在
        
        
        central = Central()
        central?.delegate = self
        
        peripheral = Peripheral()
        peripheral?.delegate = self
        
        checkUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkBlocks()
        self.tableView.reloadData()
        
    }
    
    func checkBlocks(){
        if let userBlocks = userDefault.value(forKey: "blocks") as? [String:String] {
            var i = 0
            for qualified in qualifieds {
                for blockID in userBlocks.keys {
                    if qualified.uid == blockID {
                        self.qualifieds.remove(at: i)
                    }
                }
                i += 1
            }
        }
    }
    
    func checkUserData(){
         // 檢查使用者是否有填寫基本資料
         FirebaseConnect.shared.getUserData { result, error in
             // 如果取不到資料，跳到signUp頁面填寫
             if let error = error {
                 print(error.localizedDescription)
                 return
             }
             guard let data = result?.data() else {
                 let storyboard = UIStoryboard(name: "Main", bundle: nil)
                 let signUpNavController = storyboard.instantiateViewController(identifier: "signUpNavigationController")
                 (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(signUpNavController)
                 return
             }
             User.shared.userName = data["username"] as! String
             User.shared.birthday = (data["birthday"] as! Timestamp).dateValue()
             User.shared.gender = data["gender"] as! Bool
             User.shared.sexuality = data["sexuality"] as! Bool
             User.shared.interests = data["interests"] as! [String]
             User.shared.uid = Auth.auth().currentUser?.uid
             
             guard let matchUser = data["match"] as? [String:String] else {
                 print("User didn't have match user")
                 return
             }
             
             for matchUserUID in matchUser.keys {
                 FirebaseConnect.shared.getTargetInfo(UID: matchUserUID) { targetResult, error in
                     if let error = error {
                         print("Fail to get match user info")
                         print(error.localizedDescription)
                         return
                     }
                     guard let target = targetResult?.data() else {
                         print("Fail to get match user info")
                         return
                     }
                     let name = target["username"] as! String
                     let birthday = (target["birthday"] as! Timestamp).dateValue()
                     let age = self.calculateAge(date: birthday)
                     let interests = target["interests"] as! [String]
                     let q = Qualified(name: name, age: age, interests: interests, uid: matchUserUID, chatUID: matchUser[matchUserUID]!)
                     print(q)
                     self.qualifieds.append(q)
                     self.checkBlocks()
                     self.tableView.reloadData()
                 }
             }
         }
     }
    
    
    func calculateAge(date: Date) -> Int {
        let calendar = Calendar.current
        let targetAgeComponents = calendar.dateComponents([.year], from: date, to: Date())
        let targetAge = targetAgeComponents.year!
        return targetAge
    }
    
    
    func matchUser(content: Data){
        do{
            let json = try JSONSerialization.jsonObject(with: content, options: []) as? [String: Any]
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            guard   let target = json,
                    let targetUID = target["UID"] as? String,
                    let targetName = target["username"] as? String,
                    let targetBirthday = formatter.date(from: (target["birthday"] as! String)),
                    let targetGender = target["gender"] as? Bool,
                    let targetSexuality = target["sexuality"] as? Bool,
                    let targetInterests = target["interests"] as? [String] else {
                        assertionFailure("Fail to get target data")
                        return
                    }
            
            if let userBlocks = userDefault.value(forKey: "blocks") as? [String:String] {
                for id in userBlocks.keys{
                    if id == targetUID{
                        return
                    }
                }
            }
            
            print(targetUID)
            var isMatch = false
            for q in qualifieds {
                if q.uid == targetUID{
                    isMatch = true
                }
            }
            if !isMatch {
                let userSet = Set(User.shared.interests)
                let targetSet = Set(targetInterests)
                let myAge = calculateAge(date: User.shared.birthday)
                let targetAge = calculateAge(date: targetBirthday)
                let diffenerceAge = myAge - targetAge
                if diffenerceAge > -5 && diffenerceAge < 6{
                    if User.shared.sexuality == targetGender {
                        if User.shared.gender == targetSexuality {
                            if userSet.intersection(targetSet).count > 2 {
                                //TODO: 將配對到的物件存成物件
                                let chatUID = NSUUID().uuidString
                                print(chatUID)
                                let qualified = Qualified(name: targetName, age: targetAge, interests: targetInterests, uid: targetUID, chatUID: chatUID)
                                self.qualifieds.append(qualified)
                                //TODO: 顯示在tableView上
                                self.tableView.reloadData()
                                //TODO: 通知在背景的使用者
                                notifyUser(message: qualified.name)
                                //TODO: 建立firebase的聊天
                                FirebaseConnect.shared.creatChat(chatID: chatUID, userUID: User.shared.uid!, targetUID: targetUID)
                                //TODO: 通知對方？
                    
                            }
                        }
                    }
                }
            }
        } catch {
            print("error\(error)")
        }
    }
    
    
    func notifyUser(message: String){
        let content = UNMutableNotificationContent()
        content.title = "配對成功"
        content.body = "成功配對，趕快來認識\(message)"
        content.sound = UNNotificationSound.default
        content.badge
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    
    @IBAction func scanSwitchPressed(_ sender: UISwitch) {
        if sender.isOn {
            central?.startToScan(targetServiceUUIDs: targetServiceUUIDs, targetCharUUIDs: targetCharUUIDs)
            var data = User.shared.userData
            let date = User.shared.birthday
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            data["birthday"] = formatter.string(from: date)
            print(data["birthday"])
            var jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            peripheral?.startToAdvertising(characteristicUUID: targetCharUUIDs.first!, serviceUUID: targetServiceUUIDs.first!, data: jsonData!)
            
        } else {
            central?.stopScaning()
            peripheral?.stopAdvertising()
        }
    }
    
    func clearUser(){
        User.shared.uid = ""
        User.shared.userName = ""
        User.shared.birthday = Date()
        User.shared.gender = true
        User.shared.sexuality = true
        User.shared.interests = []
        User.shared.userImage = nil
    }
    
    // 登出
    @IBAction func signOut(_ sender: Any) {
        do{
            try FirebaseConnect.shared.signOut()
            clearUser()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginNavController = storyboard.instantiateViewController(identifier: "SignInNavigationController")
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func getItem(at indexPath: IndexPath) -> DiscoveredItem {
        let keys = Array(allItems.keys) // Array有順序，Dictionary沒順序
        let targetKey = keys[indexPath.row]
        return allItems[targetKey]!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TargetViewController {
            vc.target = self.qualifieds[self.tableView.indexPathForSelectedRow!.row]
            vc.delegate = self
        }
    }
}

extension SearchTableViewController: CentralDelegate{
    
    func didSucessGetValue(content: Data) {
        matchUser(content: content)
    }
    
    func centralManagerChangeState(message: String) {
        showAlert(message: message)
    }
    
    func didDiscoverPeripheral(allItem: [String : DiscoveredItem]) {
        self.allItems = allItem
        self.tableView.reloadData()
    }
    
    
}

extension SearchTableViewController: PeriphralDelegate{
    
}

extension SearchTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.qualifieds.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "peripheralCell", for: indexPath)
        cell.textLabel?.text = self.qualifieds[indexPath.row].name
        
        return cell
    }
    
    
}

extension SearchTableViewController: TargetViewControllerDelegate{
    func finishAddBlock() {
        let alert = UIAlertController(title: "成功", message: "已經將使用者加入您的黑名單，你們不會再次配對到", preferredStyle: .alert)
        let action = UIAlertAction(title: "確認", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIViewController {
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
