//
//  SearchTableViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/1.
//

import UIKit
import CoreBluetooth

class SearchTableViewController: UITableViewController {

    var central: Central?
    var peripheral: Peripheral?
    let targetServiceUUIDs = [CBUUID(string: "1234")]
    let targetCharUUIDs = [CBUUID(string: "1234")]
    var allItems = [String: DiscoveredItem]()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkUserData()
        
        central = Central()
        central?.delegate = self
        
        peripheral = Peripheral()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
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
             User.shared.birthday = data["birthday"] as! String
             User.shared.gender = data["gender"] as! Bool
             User.shared.sexuality = data["sexuality"] as! Bool
             User.shared.interests = data["interests"] as! [String]
         }
     }
    
    func matchUser(content: Data){
        do{
            let json = try JSONSerialization.jsonObject(with: content, options: []) as? [String: Any]
            
        } catch {
            print("error\(error)")
        }
    }
    
    @IBAction func scanSwitchPressed(_ sender: UISwitch) {
        if sender.isOn {
            central?.startToScan(targetServiceUUIDs: targetServiceUUIDs, targetCharUUIDs: targetCharUUIDs)
            
            var jsonData = try? JSONSerialization.data(withJSONObject: User.shared.userData, options: .prettyPrinted)
            peripheral?.startToAdvertising(characteristicUUID: targetCharUUIDs.first!, serviceUUID: targetServiceUUIDs.first!, data: jsonData!)
            
        } else {
            central?.stopScaning()
            
            peripheral?.stopAdvertising()
        }
    }
    
    // 登出
    @IBAction func signOut(_ sender: Any) {
        do{
            try FirebaseConnect.shared.signOut()
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

extension SearchTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.allItems.count 
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "peripheralCell", for: indexPath)
        
        let item = getItem(at: indexPath)
        let name = item.peripheral.name ?? "n/a"
        cell.textLabel?.text = "\(name) RSSI: \(item.rssi)"
        cell.detailTextLabel?.text = String(format: "Last seen: %.1f seconds ago", Date().timeIntervalSince(item.lastSeen))
        return cell
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
