//
//  SignUpViewController.swift
//  MyDestiny
//
//  Created by 胡丕 on 2022/3/7.
//

import UIKit
import TextFieldEffects

// 這個viewController 對應三個view 分別是 輸入名字 輸入生日 性別及性向
class SignUpViewController: UIViewController {

    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var likeMaleBtn: UIButton!
    @IBOutlet weak var likeFemaleBtn: UIButton!
    @IBOutlet weak var dateTextField: HoshiTextField!
    @IBOutlet weak var nameTextField: HoshiTextField!
    
    let datePicker = UIDatePicker()
    var gender: Bool?
    var sexuality: Bool?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設定按鈕樣式
        if let maleBtn = self.maleBtn,
           let femaleBtn = self.femaleBtn,
           let likeMaleBtn = self.likeMaleBtn,
           let likeFemaleBtn = self.likeFemaleBtn{
            maleBtn.layer.borderWidth = 1
            maleBtn.layer.cornerRadius = maleBtn.frame.height/2
            femaleBtn.layer.borderWidth = 1
            femaleBtn.layer.cornerRadius = maleBtn.frame.height/2
            likeMaleBtn.layer.borderWidth = 1
            likeMaleBtn.layer.cornerRadius = maleBtn.frame.height/2
            likeFemaleBtn.layer.borderWidth = 1
            likeFemaleBtn.layer.cornerRadius = maleBtn.frame.height/2
        }

        
    }
    // 按下textField可以編輯日期
    @IBAction func editDate(_ sender: HoshiTextField) {
        // 設定datePicker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        datePicker.tintColor = UIColor(named: "VeryPeri")
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding  ToolBar Button
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneClick))
        doneButton.tintColor = UIColor(named: "VeryPeri")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelClick))
        cancelButton.tintColor = UIColor(named: "VeryPeri")
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        sender.inputAccessoryView = toolBar
        // 設定datePicker到 textField 的 inputView
        sender.inputView = datePicker
    }
    // toolbar Done Action
    @objc func doneClick(){
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .long
        dateFormatter1.timeStyle = .none
        User.shared.birthday = datePicker.date
        dateTextField.text = dateFormatter1.string(from: datePicker.date)
        dateTextField.resignFirstResponder()
    }
    // toobar cancle action
    @objc func cancelClick(){
        dateTextField.resignFirstResponder()
    }
    // 性別二選一
    @IBAction func genderBtnPressed(_ sender: UIButton) {
        if sender == maleBtn{
            self.gender = true
            femaleBtn.tintColor = UIColor(named: "VolcanicGlass")
            femaleBtn.backgroundColor = UIColor(named: "CloudDancer")
            femaleBtn.layer.borderColor = UIColor(named: "VolcanicGlass")?.cgColor
            maleBtn.tintColor = UIColor(named: "CloudDancer")
            maleBtn.layer.borderColor = UIColor(named: "VeryPeri")?.cgColor
            maleBtn.backgroundColor = UIColor(named: "VeryPeri")
                        
        } else if sender == femaleBtn{
            self.gender = false
            maleBtn.tintColor = UIColor(named: "VolcanicGlass")
            maleBtn.backgroundColor = UIColor(named: "CloudDancer")
            maleBtn.layer.borderColor = UIColor(named: "VolcanicGlass")?.cgColor
            femaleBtn.tintColor = UIColor(named: "CloudDancer")
            femaleBtn.layer.borderColor = UIColor(named: "VeryPeri")?.cgColor
            femaleBtn.backgroundColor = UIColor(named: "VeryPeri")
        }
    }
    // 性向二選一
    @IBAction func sexualityBtnPressed(_ sender: UIButton) {
        if sender == likeMaleBtn {
            self.sexuality = true
            likeFemaleBtn.tintColor = UIColor(named: "VolcanicGlass")
            likeFemaleBtn.backgroundColor = UIColor(named: "CloudDancer")
            likeFemaleBtn.layer.borderColor = UIColor(named: "VolcanicGlass")?.cgColor
            likeMaleBtn.tintColor = UIColor(named: "CloudDancer")
            likeMaleBtn.layer.borderColor = UIColor(named: "VeryPeri")?.cgColor
            likeMaleBtn.backgroundColor = UIColor(named: "VeryPeri")
        } else if sender == likeFemaleBtn {
            self.sexuality = false
            likeMaleBtn.tintColor = UIColor(named: "VolcanicGlass")
            likeMaleBtn.backgroundColor = UIColor(named: "CloudDancer")
            likeMaleBtn.layer.borderColor = UIColor(named: "VolcanicGlass")?.cgColor
            likeFemaleBtn.tintColor = UIColor(named: "CloudDancer")
            likeFemaleBtn.layer.borderColor = UIColor(named: "VeryPeri")?.cgColor
            likeFemaleBtn.backgroundColor = UIColor(named: "VeryPeri")
        }
    }
    
    // 確認是否填寫名字
    @IBAction func checkNameBtnPressed(_ sender: Any) {
        
        guard let name = self.nameTextField.text,
              name.isEmpty == false else {
            nameTextField.shake()
            return
        }
        User.shared.userName = name
        print(User.shared.userName)
        performSegue(withIdentifier: "goBirthday", sender: nil)
    }
    
    //  確認是否填寫生日
    @IBAction func checkBirthdayBtnPressed(_ sender: Any) {
        
        guard let birthday = self.dateTextField.text,
              birthday.isEmpty == false else {
                  dateTextField.shake()
                  return
              }
        print(User.shared.birthday)
        performSegue(withIdentifier: "goGender", sender: nil)
        
    }
    
    // 確認是否填寫性別及性向
    @IBAction func checkGenderAndSexualityBtnPressed(_ sender: Any) {
        guard let gender = gender,
              let sexuality = sexuality else {
            return
        }
        
        User.shared.gender = gender
        User.shared.sexuality = sexuality
        print("\(User.shared.gender), \(User.shared.sexuality)")
        performSegue(withIdentifier: "goInterest", sender: nil)
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}

// MARK:  UITextFiedDelegate
extension SignUpViewController: UITextFieldDelegate{
    // 關鍵盤
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

