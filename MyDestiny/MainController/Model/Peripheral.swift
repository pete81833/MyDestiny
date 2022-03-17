//
//  Peripheral.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/13.
//

import Foundation
import CoreBluetooth

protocol PeriphralDelegate{
    
}

class Peripheral: NSObject {
    
    var delegate: PeriphralDelegate?
    let manager  = CBPeripheralManager()
    var serviceUUID: CBUUID?
    var characteristicUUID: CBUUID?
    var mainChar: CBMutableCharacteristic!
    var titleName = User.shared.userName
    var data = Data()
    
    override init(){
        super.init()
        manager.delegate = self
    }
    
    func startToAdvertising(characteristicUUID: CBUUID, serviceUUID: CBUUID, data: Data) {
        self.data = data
        if mainChar == nil {
            let properties: CBCharacteristicProperties = [.read, .notify, .write]
            let permissions: CBAttributePermissions = [.readable, .writeable]
            mainChar = CBMutableCharacteristic(type: characteristicUUID, properties: properties, value: nil, permissions: permissions)
            let service = CBMutableService(type: serviceUUID, primary: true)
            service.characteristics = [mainChar]
            manager.add(service)
        }
        // Start advertising
        let uuids = [serviceUUID] // Important! It must an array.
        let info: [String: Any] = [CBAdvertisementDataLocalNameKey: titleName,
                                CBAdvertisementDataServiceUUIDsKey: uuids]
        manager.startAdvertising(info)
    }
    
    
    func stopAdvertising() {
        manager.stopAdvertising()
    }
    
    func sendMessage(central: CBCentral?) {
        
        let centrals = (central == nil ? nil : [central!]) // 是nil 給 nil 不是nil 把它包進Array裡面
        manager.updateValue(data, for: mainChar, onSubscribedCentrals: centrals)
        // 發送指令的成功與失敗 seccesss（底層有收到這個指令） 跟 false （底層沒收到，可能是因為還在收其他的資料跟處理，所以要有重新發送的機制）
        
    }
    
}

extension Peripheral: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        let state = peripheral.state
        if state != .poweredOn {
            let message = "BLE is not ready: \(state.rawValue)"
            //TODO: 藍芽關閉要通知外面
            
        }
    }
    
    // Notify from Central.
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        
        sendMessage(central: central)
        
    } //進來的時候會觸發這個方法
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        
    }
    
    // Note! This method will be called only when we get  false from manager.updateValue().
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        print("peripheralManagerIsReady")
        sendMessage(central: nil)
        
    }
    
    // 有人發信息來的時候
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            guard let data = request.value,
                  let message = String(data: data, encoding: .utf8) else {
                      assertionFailure("Fail to convert data to string.")
                      return
            }
            
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        // 請求中的數據，這裏把文本框中的數據發給中心設備
        request.value = data
        // 成功響應請求
        peripheral.respond(to: request, withResult: .success)
    }
    
    
    
}
