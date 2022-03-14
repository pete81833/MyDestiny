//
//  Peripheral.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/13.
//

import Foundation
import CoreBluetooth

class Peripheral: NSObject {
    
    let manager  = CBPeripheralManager()
    var serviceUUID: CBUUID?
    var characteristicUUID: CBUUID?
    var mainChar: CBMutableCharacteristic!
    var titleName = User.shared.userName
    
    override init(){
        super.init()
        manager.delegate = self
    }
    
    func startToAdvertising(characteristicUUID: CBUUID, serviceUUID: CBUUID, data: Data) {
        if mainChar == nil {
            let properties: CBCharacteristicProperties = [.read]
            let permissions: CBAttributePermissions = [.readable]
            mainChar = CBMutableCharacteristic(type: characteristicUUID, properties: properties, value: data, permissions: permissions)
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
    
}

extension Peripheral: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        let state = peripheral.state
        if state != .poweredOn {
            let message = "BLE is not ready: \(state.rawValue)"
            //TODO: 藍芽關閉要通知外面
            
        }
    }
    
    
}
