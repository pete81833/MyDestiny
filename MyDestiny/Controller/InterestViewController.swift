//
//  InterestViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/10.
//

import UIKit
import TagListView
import AVFoundation

class InterestViewController: UIViewController {
    
    @IBOutlet weak var checkInterstBtn: UIButton!
    @IBOutlet weak var tagListView: TagListView!
    var tags: [String] = [
        "吃貨","instagram","散步","跑步","旅行","語言交換","電影","高爾夫","韓劇","韓流",
        "攝影","閱讀","運動","閒聊","咖啡","卡拉 OK",
        "喝一杯","投資理財","展覽","夜生活","密室逃脫","血拼",
        "早午餐","交友","什麼都能試試","健行","游泳","烘培","釣魚","汽車"
    ]
    var selectTags: [String:TagView]  = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tagListView.delegate = self
        tagListView.textFont = UIFont.systemFont(ofSize: 25)
        tagListView.alignment = .center
        tagListView.addTags(tags)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(tagListView.frame.height)
        var maxY = CGFloat(0)
        for view in tagListView.subviews{
            if view.frame.maxY >= maxY {
                maxY = view.frame.maxY
            }
        }
        print(maxY)
        let heightConstraint = NSLayoutConstraint(item: tagListView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: maxY)
        self.tagListView.addConstraint(heightConstraint)
    }
    
        
    
    
    @IBAction func finishBtnPressed(_ sender: Any) {
        if self.selectTags.count > 4 {
            for interestName in selectTags.keys {
                User.shared.interests.append(interestName)
            }
            
            performSegue(withIdentifier: "goSelectPhoto", sender: nil)
        }
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

extension InterestViewController: TagListViewDelegate{
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
        if tagView.isSelected {
            tagView.borderColor = UIColor(named: "VolcanicGlass")
            tagView.textColor = UIColor(named: "Anthracite")!
            selectTags.removeValue(forKey: (tagView.titleLabel?.text)!)
            self.checkInterstBtn.titleLabel?.text = "繼續 " + "\(selectTags.count)/5"
            tagView.isSelected = false
        } else {
            if selectTags.count < 5{
                selectTags[(tagView.titleLabel?.text)!] = tagView
                self.checkInterstBtn.titleLabel?.text = "繼續 " + "\(selectTags.count)/5"
                tagView.borderColor = UIColor(named: "VeryPeri")
                tagView.textColor = UIColor(named: "VeryPeri")!
                tagView.isSelected = true
            } else {
                // 初始化 UIImpactFeedbackGenerator
                let generator = UIImpactFeedbackGenerator(style: .rigid)
                // 觸發回饋
                generator.impactOccurred()            }
        }
        
        print(selectTags)
        
    }
}
