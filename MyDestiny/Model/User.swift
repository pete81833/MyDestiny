//
//  User.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/7.
//

import Foundation

class User {
    
    static let shared = User()
    private init(){}
    
    var userName: String = ""
    var birthday = Date() 
    var gender: Bool = true
    var sexuality: Bool = true
    var interests: [String] = []
    var userImage: Data?
    var uid: String?
    
    var userData: [String: Any] {
        var data = [String: Any]()
        data["username"] = userName
        data["birthday"] = birthday
        data["gender"] = gender
        data["sexuality"] = sexuality
        data["interests"] = interests
        data["UID"] = uid
        return data
    }
    
    
    
}
