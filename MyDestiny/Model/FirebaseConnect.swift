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
import FirebaseStorage

protocol FirebaseConnetDelegate {
    func errorWithApple(error: NSError)
    func sucessLoginWithApple()
}

class FirebaseConnect: NSObject {
    
    var delegate: FirebaseConnetDelegate?
    let db = Firestore.firestore()
    let storage = Storage.storage()
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
        var userData: [String: Any] = User.shared.userData
        userData["birthday"] = Timestamp(date: userData["birthday"] as! Date)
        docRef.setData(userData, completion: completion)
    }
    
    func downloadFile(uid: String) async throws ->  Data{
        
        return try await withCheckedThrowingContinuation { continuation in
            // Create a reference to the file you want to download
            let storageRef = storage.reference()
            let islandRef = storageRef.child("\(uid).jpeg")
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            islandRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                if let error = error {
                    print("下載失敗 error:\(error)")
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: data!)
            }
        }
        
    }
    
    func a(){
        
        
    }
    
    func uploadFile(){
        guard let uid = User.shared.uid else {
            print("Fail to get UserUID")
            return
        }
        guard let uploadData = User.shared.userImage else {
            print("Fail to get userImageData")
            return
        }
        let storageRef = storage.reference().child("\(uid).jpeg")
        let uploadTask = storageRef.putData(uploadData, metadata: nil) { metadata, error in
            guard let metadata = metadata else {
                print("上傳失敗")
                return
            }
            // You can also access to download URL after upload.
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                print(downloadURL)
            }
        }
        
    }
    
    func creatChat(chatID: String, userUID: String, targetUID: String){
        let number = Int.random(in: 0...10)
        sleep(UInt32(number))
        let checkref = db.collection("Users").document(userUID)
        checkref.getDocument { result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let data = result?.data() else{
                print("Fail to get Data")
                return
            }
            if let match = data["match"] as? [String:String] {
                for key in match.keys{
                    if key != targetUID {
                        let chatRef = self.db.collection("chats").document(chatID)
                        let userRef = self.db.collection("Users").document(userUID)
                        let targetRef = self.db.collection("Users").document(targetUID)
                        chatRef.setData(["0":["","",""]]) { error in
                            print("error \(error)")
                        }
                        userRef.setData(["match":[targetUID:chatID]], merge: true)
                        targetRef.setData(["match":[userUID:chatID]], merge: true)
                    } else {
                        //TODO: 傳出去
                    }
                }
            } else{
                let chatRef = self.db.collection("chats").document(chatID)
                let userRef = self.db.collection("Users").document(userUID)
                let targetRef = self.db.collection("Users").document(targetUID)
                chatRef.setData(["0":["","",""]]) { error in
                    print("error \(error)")
                }
                userRef.setData(["match":[targetUID:chatID]], merge: true)
                targetRef.setData(["match":[userUID:chatID]], merge: true)
            }
        }
    }
    
    func sendMessage(chatID: String, number: String, message: String, uid: String){
        let chatRef = db.collection("chats").document(chatID)
        chatRef.setData([number:[uid, "", message]], merge: true)
    }
    
    func getTargetInfo(UID: String, completion: @escaping (DocumentSnapshot?, Error?) -> Void){
        let targetRef = db.collection("Users").document(UID)
        targetRef.getDocument(completion: completion)
    }
    
    func reportUser(uid: String, content: String){
        let reportRef = db.collection("watchList").document(uid)
        reportRef.updateData(["reason":FieldValue.arrayUnion([content])]) { error in
            if let e = error {
                print("udate fail \(e)")
                reportRef.setData(["reason":FieldValue.arrayUnion([content])])
            }
        }
    }
    
    func reportDirtyWord(dirtyWord: String){
        let uid = NSUUID().uuidString
        let reportRef = db.collection("dirtyWord").document(uid)
        reportRef.setData(["dirtyWord":dirtyWord])
    }
}

