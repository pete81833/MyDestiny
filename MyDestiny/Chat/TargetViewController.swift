//
//  TargetViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/14.
//

import UIKit
import TagListView

class TargetViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    
    @IBOutlet weak var ageLable: UILabel!
    @IBOutlet weak var tagView: TagListView!
    var target: Qualified?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let target = target else {
            print("Fail to get target")
            return
        }


        nameLable.text = target.name
        ageLable.text =  "\(target.age) 歲"
        tagView.addTags(target.interests)
        tagView.textFont = UIFont.systemFont(ofSize: 25)
        tagView.alignment = .center
        
        let task = Task{
            do{
                let image = try await FirebaseConnect.shared.downloadFile(uid: target.uid)
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: image)
                }
            }catch{
                print(error.localizedDescription)
            }
        }
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goTalk" {
            let vc = segue.destination as! ChatViewController
            vc.target = self.target
        }
    }
    

}
