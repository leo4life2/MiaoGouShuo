//
//  ResetPasswordViewController.swift
//  Tolocam
//
//  Created by wyx on 2019/2/28.
//  Copyright © 2019年 leo. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var confirmPwField: UITextField!
    @IBOutlet weak var sendCodeBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    
    var timer = Timer()
    var timerCount = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func sendCode(_ sender: Any) {
        if AVUser.current()?.mobilePhoneNumber != nil{
            AVUser.requestPasswordReset(withPhoneNumber: AVUser.current()!.mobilePhoneNumber!, block: { (done:Bool, error:Error?) in
                if error == nil{
                    let alert = UIAlertController(title: "发送成功", message: "请查收短信", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "确认", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.__countDownTimer), userInfo: nil, repeats: true)
                    self.sendCodeBtn.isEnabled = false
                }else{
                    let alert = UIAlertController(title: "发送失败", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "确认", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    @objc func __countDownTimer() {
        timerCount -= 1
        if timerCount == 0 {
            timer.invalidate()
            
            self.sendCodeBtn.setTitle("发送", for: .normal)
            self.sendCodeBtn?.isEnabled = true
        } else {
            self.sendCodeBtn.setTitle("\(timerCount)", for: .normal)
        }
    }
    
    @IBAction func confirmBtn(_ sender: Any) {
        if self.codeField.text == ""{
            let alert = UIAlertController(title: "错误", message: "请填写验证码", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确认", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if self.pwField.text != self.confirmPwField.text{
            let alert = UIAlertController(title: "错误", message: "密码不一致", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确认", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            AVUser.resetPassword(withSmsCode: self.codeField.text!, newPassword: self.pwField.text!) { (done:Bool, error:Error?) in
                if done{
                    let alert = UIAlertController(title: "成功", message: "请使用新密码登录", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "确认", style: .cancel, handler: { (action:UIAlertAction) in
                        self.dismiss(animated: true, completion: nil)
                        //logout??
                    }))
                    self.present(alert, animated: true, completion: nil)
                }else{
                    print(error!.localizedDescription)
                    let alert = UIAlertController(title: "错误", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "确认", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

}

//@IBDesignable
class TextField: UITextField {
    @IBInspectable var insetX: CGFloat = 15
    @IBInspectable var insetY: CGFloat = 0
    
    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
    
    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
}
