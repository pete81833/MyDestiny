//
//  pickImageViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/12.
//

import UIKit
import AVFoundation

class pickImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        imageView.addGestureRecognizer(tapGR)
        imageView.isUserInteractionEnabled = true
        imagePickerController.delegate = self
    }
    
    @IBAction func finishBtnPressed(_ sender: Any) {
        if let image = imageView.image  {
            
            if image == UIImage(systemName: "person.crop.square"){
                let alert = UIAlertController(title: "錯誤", message: "請選取一張照片", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "確定", style: .default)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                User.shared.userImage = image.jpegData(compressionQuality: 0.5)
                FirebaseConnect.shared.uploadUserData { error in
                    if let error = error {
                        print(error.localizedDescription)
                        print("上傳失敗")
                        return
                    }
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainTabBarController = storyboard.instantiateViewController(identifier: "TabBarController")
                
                // This is to get the SceneDelegate object from your view controller
                // then call the change root view controller function to change to main tab bar
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
            }
        }
    }
    
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension pickImageViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.imageView.image = image
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension pickImageViewController: UINavigationControllerDelegate {
    
}
