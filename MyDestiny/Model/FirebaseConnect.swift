//
//  FirebaseConnet.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/2/16.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import Firebase

protocol FirebaseConnetDelegate {
    func errorWithApple(error: NSError)
    func sucessLoginWithApple()
}

class FirebaseConnect: NSObject {
    
    var delegate: FirebaseConnetDelegate?
    
    static let shared = FirebaseConnect()
    
    private override init(){}
    
    
    func registerUserToFirebase(credential: AuthCredential) async throws {
        try await Auth.auth().signIn(with: credential)
    }
    
    
    func signOut() throws{
        let firebaseAuth = Auth.auth()
        try firebaseAuth.signOut()
    }
    
}

