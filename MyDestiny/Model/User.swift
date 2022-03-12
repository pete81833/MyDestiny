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
    
    var userName: String?
    var birthday: String?
    var gender: Bool?
    var sexuality: Bool?
    var interests: [String]?
    var userImage: Data?
}
