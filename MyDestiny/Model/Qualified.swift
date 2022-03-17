//
//  Qualified.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/14.
//

import Foundation
import UIKit

class Qualified {
    
    var name: String
    var age: Int
    var interests: [String]
    var uid: String
    var chatUID: String
    
    init(name: String, age: Int, interests: [String], uid: String, chatUID: String) {
        self.name = name
        self.age = age
        self.interests = interests
        self.uid = uid
        self.chatUID = chatUID
    }
}

