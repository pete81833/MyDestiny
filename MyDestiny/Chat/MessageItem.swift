//
//  messageItem.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/15.
//

import Foundation
import Firebase

class MessageItem {
    
    var uid: String
    var time: String
    var message: String
    
    init(uid: String, time: String, message: String){
        self.uid = uid
        self.time = time
        self.message = message
    }
    
}
