//
//  SettingsTableViewController.swift
//  Tolocam
//
//  Created by wyx on 2019/2/28.
//  Copyright © 2019年 leo. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var nickname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var suggestionsField: UITextField!
    @IBOutlet weak var logoutBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.username.text = AVUser.current()?.username
        let query = AVQuery(className: "_User")
        query.whereKey("objectId", equalTo: AVUser.current()!.objectId!)
        query.getFirstObjectInBackground { (object:AVObject?, error:Error?) in
            if error == nil{
                if let userObject = object {
                    let user = User(user: userObject)
                    self.nickname.text = user.nickname
                    if let str = user.profileIm, let url = URL(string: str) {
                        self.profilePic.kf.setImage(with: url)
                    }
                }
            }else{
                print(error!.localizedDescription)
            }
        }
        self.email.text = AVUser.current()?.email
        self.phone.text = AVUser.current()?.mobilePhoneNumber
        self.nickname.delegate = self
        self.nickname.tag = 0
        self.email.delegate = self
        self.email.tag = 1
        self.phone.delegate = self
        self.phone.tag = 2
        self.suggestionsField.delegate = self
        self.suggestionsField.tag = 3
        
//        self.tableView.separatorColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        
//        self.hideKeyboardWhenTappedAround()
    }

    @IBAction func logoutTapped(_ sender: Any) {
        let action = UIAlertAction(title: "确认", style: .destructive, handler: { (action:UIAlertAction) in
            
            AVUser.logOut()
            UIApplication.shared.keyWindow?.rootViewController = Tolo.getLoginViewController()
        })
        
        TLAlertView.showAlert(title: "提示", message: "确认要登出吗？", cancel: "退出", action: action)        
        
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section{
        case 0:
            if indexPath.row == 0{
                //profileimg
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
            break
        case 1:
            if indexPath.row == 0{
                //mail
            }else if indexPath.row == 1{
                //phone
            }else if indexPath.row == 2{
                //reset pw
                let alert = UIAlertController(title: nil, message: "选择身份验证方式", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction.init(title: "邮箱", style: .default, handler: { (action:UIAlertAction) in
                    //send email
                    AVUser.requestPasswordResetForEmail(inBackground: (AVUser.current()?.email)!, block: { (done:Bool, error:Error?) in
                        if error == nil{
                            let alertView = UIAlertController(title: "重置密码", message: "已向您的邮箱发送重置密码邮件", preferredStyle: .alert)
                            alertView.addAction(UIAlertAction(title: "确认", style: .cancel, handler: nil))
                            self.present(alertView, animated: true, completion: nil)
                        }else{
                            let alertView = UIAlertController(title: "失败", message: error!.localizedDescription, preferredStyle: .alert)
                            alertView.addAction(UIAlertAction(title: "确认", style: .cancel, handler: nil))
                            self.present(alertView, animated: true, completion: nil)
                        }
                    })
                }))
                alert.addAction(UIAlertAction.init(title: "手机", style: .default, handler: { (action:UIAlertAction) in
                    //show vc
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingsResetPWPhoneVC") as! ResetPasswordViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }))
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            break
        case 3:
            performSegue(withIdentifier: "showPrivacySegue", sender: nil)
            break
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag{
        case 0:
            var length = 0
            for char in textField.text!.characters {
                // 判断是否中文，是中文+2 ，不是+1
                length += "\(char)".lengthOfBytes(using: String.Encoding.utf8) == 3 ? 2 : 1
            }
            if textField.text == ""{
                let failAlert = UIAlertController(title: "错误", message: "请输入昵称", preferredStyle: .alert)
                failAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                self.present(failAlert, animated: true, completion: nil)
            }else if length>20{
                let failAlert = UIAlertController(title: "错误", message: "昵称字数超过限制", preferredStyle: .alert)
                failAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                self.present(failAlert, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "提示", message: "确定要更改昵称吗？", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action:UIAlertAction) in
                    let user = AVUser.current()
                    user?.setObject(textField.text, forKey: "nickname")
                    user?.saveInBackground({ (done:Bool, error:Error?) in
                        if done{
                            textField.resignFirstResponder()
                        }else{
                            let failAlert = UIAlertController(title: "更改名称失败", message: error?.localizedDescription, preferredStyle: .alert)
                            failAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                            self.present(failAlert, animated: true, completion: nil)
                        }
                    })
                }))
                self.present(alert, animated: true, completion: nil)
            }
            
        case 3:
            let alert = UIAlertController(title: "提示", message: "确定要提交反馈吗？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action:UIAlertAction) in
                var feedbackObject = AVObject(className: "Feedback")
                feedbackObject["text"] = textField.text
                feedbackObject.saveInBackground({ (done:Bool, error:Error?) in
                    if done{
                        textField.resignFirstResponder()
                        textField.text = ""
                    }else{
                        let failAlert = UIAlertController(title: "错误", message: "提交反馈失败", preferredStyle: .alert)
                        failAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                        self.present(failAlert, animated: true, completion: nil)
                    }
                })
            }))
            self.present(alert, animated: true, completion: nil)
        default:
            break
        }
        return true
    }

}
