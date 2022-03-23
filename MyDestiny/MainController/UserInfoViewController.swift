//
//  UserInfoViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/18.
//

import UIKit
import TagListView

class UserInfoViewController: UIViewController {

    @IBOutlet weak var tagListView: TagListView!
    
    @IBOutlet weak var userNameLable: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var isEditingTag = false
    let imagePickerController = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        tagListView.addTags(User.shared.interests)
        tagListView.isUserInteractionEnabled = false
        tagListView.textFont = UIFont.systemFont(ofSize: 25)
        tagListView.alignment = .center
        
        Task{
            do{
                let imageData = try await FirebaseConnect.shared.downloadFile(uid: User.shared.uid!)
                self.imageView.image = UIImage(data: imageData)
            } catch{
                print("user don't have image")
                self.imageView.image = UIImage(systemName: "person.crop.square")
            }
        }
        
        userNameLable.text = User.shared.userName
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        
    }
    
    @IBAction func selectImage(_ sender: Any) {
        self.present(imagePickerController, animated: true, completion: nil)
    }
}

extension UserInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            self.imageView.image = image
            User.shared.userImage = image.jpegData(compressionQuality: 0.5)
            FirebaseConnect.shared.uploadFile()
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
