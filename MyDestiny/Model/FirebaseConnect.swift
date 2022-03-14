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
    let db = Firestore.firestore()
    
    static let shared = FirebaseConnect()
    
    private override init(){}
    
    
    func registerUserToFirebase(credential: AuthCredential) async throws {
        try await Auth.auth().signIn(with: credential)
    }
    
    
    func signOut() throws{
        let firebaseAuth = Auth.auth()
        try firebaseAuth.signOut()
    }
    
    func getUserData(completion: @escaping (DocumentSnapshot?, Error?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            assertionFailure("Fail to get currentUser")
            return
        }
        let uid = currentUser.uid
        let docRef = db.collection("Users").document(uid)
        docRef.getDocument(completion: completion)
    }
    
    func uploadUserData(completion: @escaping ((Error?) -> Void)) {
        guard let currentUser = Auth.auth().currentUser else {
            assertionFailure("Fail to get currentUser")
            return
        }
        let uid = currentUser.uid
        let docRef = db.collection("Users").document(uid)
        let userData: [String: Any] = User.shared.userData
        docRef.setData(userData, completion: completion)
    }
}

