//
//  TargetViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/14.
//

import UIKit
import TagListView

protocol TargetViewControllerDelegate {
    func finishAddBlock()
}

class TargetViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var ageLable: UILabel!
    @IBOutlet weak var tagView: TagListView!
    var target: Qualified?
    let userDefault = UserDefaults()
    var delegate: TargetViewControllerDelegate?
    
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
 
    @IBAction func reportBtnPressed(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "檢舉", style: .destructive) { _ in
            self.performSegue(withIdentifier: "report", sender: nil)
        }
        let addToBlock = UIAlertAction(title: "加入黑名單", style: .default) { _ in
            
            let alert = UIAlertController(title: "黑名單", message: "是否要將此用戶加入黑名單，加入後就無法移除", preferredStyle: .alert)
            let action = UIAlertAction(title: "確認", style: .destructive) { _ in
                if let userBlocks = self.userDefault.value(forKey: "blocks") as? [String:String] {
                    var blocks = userBlocks
                    blocks[self.target!.uid] = self.target!.name
                    self.userDefault.set(blocks, forKey: "blocks")
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.finishAddBlock()
                } else {
                    self.userDefault.set([self.target!.uid:self.target!.name], forKey: "blocks")
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.finishAddBlock()
                }
            }
            let actionCancle = UIAlertAction(title: "取消", style: .default, handler: nil)
            alert.addAction(action)
            alert.addAction(actionCancle)
            self.present(alert, animated: true, completion: nil)
            
        }
        let cancleAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(reportAction)
        alert.addAction(addToBlock)
        alert.addAction(cancleAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goTalk" {
            let vc = segue.destination as! ChatViewController
            vc.target = self.target
        }else if segue.identifier == "report" {
            let nc = segue.destination as! UINavigationController
            let vc = nc.viewControllers.first as! ReportViewController
            vc.reportUserID = target?.uid
        }
    }

}
