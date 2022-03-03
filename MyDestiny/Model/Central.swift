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
    
    let targetServiceUUIDs = [CBUUID(string: "8888")] //: [CBUUID]? = nil // 放serviceUUIDs
    
    override init(){
        super.init()
        manager.delegate = self
    }
    
    
    func startToScan(){
        
        let services: [CBUUID]? = targetServiceUUIDs
        let options = [CBCentralManagerRestoredStateScanOptionsKey: true]//預設為false，如果為false就只會回傳一次同一個設備傳過來的封包
        manager.scanForPeripherals(withServices: services, options: options)
    }
    
    func stopScaning(){
        manager.stopScan()
    }
    
    
}

extension Central: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        let state = central.state
        if state != .poweredOn {
            let message = "BLE is not ready: \(state.rawValue)"
            delegate?.centralManagerChangeState(message: message)
        }
    }
}


