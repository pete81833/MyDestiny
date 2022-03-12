//
//  Central.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/1.
//

import Foundation
import CoreBluetooth

protocol CentralDelegate{
    func centralManagerChangeState(message: String)
}

class Central: NSObject {
    
    
    let manager = CBCentralManager()
    
    var delegate: CentralDelegate?
    
    var allItems = [String: DiscoveredItem]()
    var connectedItems = [String: DiscoveredItem]()
    var lastRefreshDate = Date()
    
    var willDiscoverServices = [CBService]()
    var willDiscoverCharacteristic = [CBCharacteristic]()
    
    var targetServiceUUIDs: [CBUUID]?
    var targetCharUUIDs: [CBUUID]?
    
   // let targetServiceUUIDs = [CBUUID(string: "8888")] //: [CBUUID]? = nil // 放serviceUUIDs
    
    override init(){
        super.init()
        manager.delegate = self
    }
    
    
    func startToScan(targetServiceUUIDs services: [CBUUID], targetCharUUIDs charUUIDs: [CBUUID]){
        self.targetServiceUUIDs = services
        self.targetCharUUIDs = charUUIDs
        let options = [CBCentralManagerRestoredStateScanOptionsKey: true]//預設為false，如果為false就只會回傳一次同一個設備傳過來的封包
        manager.scanForPeripherals(withServices: services, options: options)
    }
    
    func stopScaning(){
        manager.stopScan()
    }
    
    
    
}

// MARK:  CBCentralManagerDelegate
extension Central: CBCentralManagerDelegate {
    
    // 藍芽狀態改變會呼叫的方法
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let state = central.state
        if state != .poweredOn {
            let message = "BLE is not ready: \(state.rawValue)"
            // 用 delegate 把狀態改變告知外面
            delegate?.centralManagerChangeState(message: message)
        }
    }
    
    // 藍芽掃描後會呼叫到的方法
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
            //TODO: 把掃到得item丟回去，讓外面知道總共有幾個peripheral
            
            // 與peripheral 連線
            connectPeripheral()
        }
        
    }
    
    // 判斷是否連接過的方法
    private func connectPeripheral(){
        // 先判斷是否已經連接過了
        for item in allItems.keys {
            let connectedKeys = connectedItems.keys
            if connectedKeys.allSatisfy({ key in
                key != item
            }){
                // 連接Peripheral
                manager.connect(allItems[item]!.peripheral, options: nil)
                //TODO:  下面要放到取完資料的地方
                connectedItems[item] = allItems[item]
            }
        }
    }
    
    // 已經成功與peripheral連線會呼叫的方法
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // 停止掃描
        stopScaning()
        // 設定 delegate
        peripheral.delegate = self
        // 設定要掃出來的serviceUUIDs
        peripheral.discoverServices(targetServiceUUIDs)
    }
    
    // 與peripheral連線失敗後會呼叫的方法
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        print("didFailToConnect: \(peripheral.identifier), error: \(error?.localizedDescription ?? "n/a")")
    }
    
    // 停止連線後會呼叫的方法
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        print("didDisconnectPeripheral: \(peripheral.identifier), error: \(error?.localizedDescription ?? "n/a")")
        
        // 重新掃描
        startToScan(targetServiceUUIDs: self.targetServiceUUIDs!, targetCharUUIDs: self.targetCharUUIDs!)
    }
    
}

// MARK:  CBPeripheralDelegate
extension Central: CBPeripheralDelegate{
    
    // 已連結到services會呼叫的方法
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // 先判斷有沒有錯誤
        if let error = error {
            print("didDiscoverServices: \(error)")
            //  取消連接
            manager.cancelPeripheralConnection(peripheral)
            return
        }
        
        guard let services = peripheral.services else {
            assertionFailure("Fail to discover services")
            return
        }
        // 將services 取出
        willDiscoverServices = services
        // 準備一個一個services 連線
        handleNextService(of: peripheral)
    }
    
    // 準備連接services 裡的Characteristics
    func handleNextService(of peripheral: CBPeripheral) {
        
        // 取出要連接的service
        guard let service = willDiscoverServices.first else {
            return
        }
        // 取出後移除掉
        willDiscoverServices.removeFirst()
        // 連接 services的Characteristics
        peripheral.discoverCharacteristics(targetCharUUIDs, for: service)
    }
    
    // 成功連接至Characteristics會呼叫的方法
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("didDiscoverCharacteristicsFor: \(error)")
            manager.cancelPeripheralConnection(peripheral)
            return
        }
        
        guard let characteristics = service.characteristics else {
            assertionFailure("Invalid charateristics.")
            return
        }
        
        peripheral.readValue(for: characteristics.first!)
        
        // Next step
        if willDiscoverServices.isEmpty {
            // 如果陣列空了,就停止連接目前的peripheral
            manager.cancelPeripheralConnection(peripheral)
        } else {
            // Process to next service
            handleNextService(of: peripheral)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("didDiscoverCharacteristicsFor: \(error)")
            return
        }
        guard let data = characteristic.value,
              let text = String(data: data, encoding: .utf8)
        else {
            print("接不到")
            return
        }
        print("text = \(text)")
    }
    
}
