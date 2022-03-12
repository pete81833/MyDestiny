//
//  SearchTableViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/1.
//

import UIKit
import CoreBluetooth

class SearchTableViewController: UITableViewController {

    let manager = CBCentralManager()
    var allItems = [String: DiscoveredItem]()
    var connectedItems = [String: DiscoveredItem]()
    var lastRefreshDate = Date()
    var willDiscoverServices = [CBService]()
    var info = ""
    
    //let targetServiceUUIDs: [CBUUID]? = nil
    //let targetCharUUIDs: [CBUUID]? = nil
    
    let targetServiceUUIDs = [CBUUID(string: "1234")] //: [CBUUID]? = nil
    let targetCharUUIDs = [CBUUID(string: "1234")] //: [CBUUID]? = nil
    var talkingChar: CBCharacteristic?
    var shouldTalkingAfterFound = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Disconnect when we return from TalkingViewController
        if let characteristic = talkingChar,
           let peripheral = characteristic.service?.peripheral {
            if peripheral.state == .connected {
                manager.cancelPeripheralConnection(peripheral)
            }
            talkingChar = nil // Clean up
        }
    }
    
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

    @IBAction func switchBtnPressed(_ sender: UISwitch) {
        if sender.isOn {
            startToScan()
        } else {
            stopScaning()
        }
    }
    
    func startToScan(){
        
        let services: [CBUUID]? = targetServiceUUIDs
        let options = [CBCentralManagerRestoredStateScanOptionsKey: true]//預設為false，如果為false就只會回傳一次同一個設備傳過來的封包
        manager.scanForPeripherals(withServices: services, options: options)
    }
    
    func stopScaning(){
        manager.stopScan()
    }
    
    func getItem(at indexPath: IndexPath) -> DiscoveredItem {
        let keys = Array(allItems.keys)
        let targetKey = keys[indexPath.row]
        return allItems[targetKey]!
    }
    
    func connetPeripheral(){
        
        let connectedKeys = connectedItems.keys
        for item in allItems.keys {
            if connectedKeys.allSatisfy({ key in
                key != item
            }){
                // 連接
                manager.connect(allItems[item]!.peripheral, options: nil)
            }
        }
    }
    
    func connetCharacteristic(characteristic: CBCharacteristic){
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "peripheralCell", for: indexPath)

        let item = getItem(at: indexPath)
        
        let name = item.peripheral.name ?? "n/a"
        cell.textLabel?.text = "\(name) RSSI: \(item.rssi)"
        cell.detailTextLabel?.text = String(format: "Last seen: %.1f seconds ago", Date().timeIntervalSince(item.lastSeen))

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shouldTalkingAfterFound = true
        let item = getItem(at: indexPath)
        manager.connect(item.peripheral, options: nil)
    }
    
    


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
//        if let vc = segue.destination as? TalkingViewController{
//            vc.talkingChar = talkingChar
//        }
    }


    
}



extension SearchTableViewController: CBCentralManagerDelegate {
    
    //當藍芽狀態改變時會呼叫的方法
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        let state = central.state
        if state != .poweredOn {
            let message = "BLE is not ready: \(state.rawValue)"
            showAlert(message: message)
        }
    }
    
    // 掃描後會呼叫的方法
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //...
        let name = peripheral.name ?? "n/a"
        let identifier = peripheral.identifier.uuidString
        let now = Date()
        
        let existItem = allItems[identifier]
        if existItem == nil {
            print("Found: \(name), RSSI: \(RSSI), id: \(identifier), data: \(advertisementData)")
        }
        
        let item = DiscoveredItem(peripheral: peripheral, rssi: RSSI.intValue, lastSeen: now)
        allItems[identifier] = item
        
        // Check if we should reload tableview.
        if existItem == nil || now.timeIntervalSince(lastRefreshDate) > 1.0 {
            lastRefreshDate = now
            self.tableView.reloadData()
        }
        
        
        // 每次掃描後要去連接peripheral
        connetPeripheral()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // 3)
        stopScaning()
        
        peripheral.delegate = self
        peripheral.discoverServices(targetServiceUUIDs)
        // 4)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        //handsharing
        print("didFailToConnect: \(peripheral.identifier), error: \(error?.localizedDescription ?? "n/a")")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral: \(peripheral.identifier), error: \(error?.localizedDescription ?? "n/a")")
        startToScan()
    }
}

extension SearchTableViewController: CBPeripheralDelegate{
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // 5)
        if let error = error {
            print("didDiscoverServices: \(error)")
            manager.cancelPeripheralConnection(peripheral)
            return
        }
        
        guard let services = peripheral.services else {
            assertionFailure("Fail to discover services")
            return
        }
        //Not working
//        for service in services {
//            peripheral.discoverCharacteristics(nil, for: service)
//        }
        
        info = "*** Services: \(services.count)\n"
        
        // 6)
        willDiscoverServices = services
        handleNextService(of: peripheral)
        // 9)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("didDiscoverCharacteristicsFor: \(error)")
            return
        }
        guard let data = characteristic.value
              //let text = String(data: data, encoding: .utf8)
        else {
            print("接不到")
            return
        }
        print("text = \(data)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // 10)
        // 17)...
        if let error = error {
            print("didDiscoverCharacteristicsFor: \(error)")
            manager.cancelPeripheralConnection(peripheral)
            return
        }
        
        guard let characteristics = service.characteristics else {
            assertionFailure("Invalid charateristics.")
            return
        }
        info += "*** Service: \(service.uuid) : \(characteristics.count)\n"
        // 11)
            
        peripheral.readValue(for: characteristics.first!)
            
        
        
//        // Next step
//        if willDiscoverServices.isEmpty {
//            // all done
//            // 12a) - End
//            //showAlert(message: info)
//            manager.cancelPeripheralConnection(peripheral)
//        } else {
//            // Process to next service
//            // 12b)
//            handleNextService(of: peripheral)
//            // 15)
//        }
//        // 16)
    }
    
    func handleNextService(of peripheral: CBPeripheral) {
        // 7)
        // 13)
        guard let service = willDiscoverServices.first else {
            return
        }
        willDiscoverServices.removeFirst()
        peripheral.discoverCharacteristics(targetCharUUIDs, for: service)
        // 8)
        // 14)
    }
    
}

extension UIViewController{
    func showAlert(message: String){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok", style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }
}

struct DiscoveredItem{
    let peripheral: CBPeripheral
    let rssi: Int
    let lastSeen: Date
}
