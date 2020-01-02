//
//  RegisterViewController.swift
//  Tolocam
//
//  Created by Leo on 2018/9/18.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import AVOSCloud
import NVActivityIndicatorView

class RegisterViewController: ViewControllerWithKeyboard, UITextFieldDelegate, NVActivityIndicatorViewable {
    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var sendSMSButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var smsField: UITextField!
    
    private var blurEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        __setupUIAttributes()
    }
    
    @IBAction func registerAction(_ sender: UIButton) {
        let vc = Tolo.getPrivacyViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        guard let username = self.usernameField.text?.lowercased(), !username.isEmpty else{
            self.displayErrorAlert(message: "用户名不可为空", completion: nil)
            return
        }
        let usernameRegex = "^[a-z0-9_-]{6,20}$"
        do {
            let success = try RegexHelper(usernameRegex).match(username)
            if !success {
                self.displayErrorAlert(message: "用户名请使用6-20个字母、数字、下划线或减号", completion: nil)
                return
            }
        } catch {
            self.displayErrorAlert(message: "请不要使用特殊字符", completion: nil)
            return
        }
        guard let phoneNumber = self.phoneNumberField.text, !phoneNumber.isEmpty else{
            self.displayErrorAlert(message: "手机号不可为空", completion: nil)
            return
        }
        guard let password = self.pwField.text, !password.isEmpty else{
            self.displayErrorAlert(message: "密码不可为空", completion: nil)
            return
        }
        guard let sms = self.smsField.text, !sms.isEmpty else{
            self.displayErrorAlert(message: "验证码不可为空", completion: nil)
            return
        }
        
//        let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: NSRegularExpression.Options())
//        if regex.firstMatch(in: username, options: NSRegularExpression.MatchingOptions(), range:NSMakeRange(0, username.count)) != nil {
//            self.displayErrorAlert(message: "请不要使用特殊字符", completion: nil)
//        }
        
        //Pac Man Loading Animation // Pac Man 注册动画
        let activityData = ActivityData(size: CGSize(width: 48, height: 48), message: "注册ing...", messageFont: UIFont(name: "PingFangSC", size: 18), messageSpacing: 0, type: .pacman, color: .white, padding: 0, displayTimeThreshold: 0, minimumDisplayTime: 200, backgroundColor: UIColor(white: 0, alpha: 0.7), textColor: .white)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
        
        self.view.isUserInteractionEnabled = false // Prevent tapping login twice // 防止重复点击注册按钮
        
        AVUser.signUpOrLoginWithMobilePhoneNumber(inBackground: phoneNumber, smsCode: sms) { (user, error) in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            self.view.isUserInteractionEnabled = true
            
            if let error = error {
                self.displayErrorAlert(error: error, completion: nil)
            } else {                
                user!.username = username
                user!.password = password
                let defaultProfileImgData = UIImage(named: "DefaultProfileImg")!.lowQualityJPEGNSData
                let file = AVFile(data: defaultProfileImgData as Data)
                user!.setObject(file, forKey: "profileIm")
                user!.setObject(username, forKey: "nickname")
                user!.saveInBackground({ (done, error) in
                    if let error = error{
                        self.displayErrorAlert(error: error){
                            //Delete user if failed to setup //注册失败则删除未设置完成的用户
                            self.__deleteUser(user: user!)
                        }
                    } else {
                        //Follow self to see own posts // 关注自己以查看自己的帖子
                        let followSelf = { () -> AVObject in
                            let followObject = AVObject(className: "Follow")
                            followObject.setObject(user, forKey: "followFrom")
                            followObject.setObject(user, forKey: "followingTo")
                            return followObject
                        }()
                        //Follow Leo by default // 默认关注Leo
                        let followLeo = { () -> AVObject in
                            let followObject = AVObject(className: "Follow")
                            followObject.setObject(user, forKey: "followFrom")
                            followObject.setObject(AVUser(objectId: "588a0e8e128fe100650502e7"), forKey: "followingTo")
                            return followObject
                        }()
                        
                        followSelf.saveInBackground()
                        followLeo.saveInBackground()
                        
                        // Must re-login for new session token.
                        // User 设置用户名和密码的操作相当于更改用户名和密码，所以当用户名和密码被更新后，当前的 session token 就过期了，需要调用一次 login 方法，获取新的 session token 之后才能继续对 User 进行操作
                        AVUser.logInWithUsername(inBackground: username, password: password, block: { (user, error) in
                            if let error = error {
                                self.displayErrorAlert(error: error, completion: nil)
                            } else {
                                self.show(Tolo.walkthroughPageViewController, sender: self)
                            }
                        })
                    }
                })
            }
        }
    }
    
    @IBAction func sendSMS(_ sender: Any) {
        guard let phoneNumber = self.phoneNumberField.text, !phoneNumber.isEmpty else{
            self.displayErrorAlert(message: "手机号不可为空", completion: nil)
            return
        }
        
        let options = { () -> AVShortMessageRequestOptions in
            let options = AVShortMessageRequestOptions()
            options.ttl = 10
            options.applicationName = "Tolocam"
            return options
        }()
        
        AVSMS.requestShortMessage(forPhoneNumber: phoneNumber, options: options) { (done, error) in
            if let error = error{
                self.displayErrorAlert(error: error, completion: nil)
            } else {
                self.displayMessageAlert("发送成功", message: "请查收短信", completion: nil)
            }
        }
    }
    
    @IBAction func returnToLogin(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func __setupUIAttributes() {
        // Text Fields // 输入框
        for field in [self.usernameField, self.phoneNumberField, self.pwField, self.smsField]{
            field!.tintColor = UIColor.white
            field!.delegate = self
        }
        
        // Login Button // 登录按钮
        self.registerButton.layer.cornerRadius = self.registerButton.frame.height/2
        self.registerButton.layer.borderWidth = 4
        self.registerButton.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3).cgColor
        self.registerButton.addTarget(self, action: #selector(buttonHighlight(_:)), for: .touchDown)
        self.registerButton.addTarget(self, action: #selector(buttonNormal(_:)), for: .touchUpInside)
        self.registerButton.addTarget(self, action: #selector(buttonNormal(_:)), for: .touchUpOutside)
        
        // SMS Button // 发送验证码按钮
        self.sendSMSButton.layer.borderWidth = 1
        self.sendSMSButton.layer.borderColor = UIColor.white.cgColor
        self.sendSMSButton.layer.cornerRadius = 5
        
        // Blur Effect // 背景模糊效果
        self.blurEffectView = UIVisualEffectView()
        self.blurEffectView.frame = self.view.bounds
        self.backgroundImg.addSubview(self.blurEffectView)
    }
    
    private func __deleteUser(user: AVUser){
        user.deleteInBackground { (done, error) in
            if let error = error {
                //If failed, try again until it works //若删除失败，继续尝试删除
                let timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
                    print(error.localizedDescription)
                    self.__deleteUser(user: user)
                })
                timer.fire()
            }
        }
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        // To make sure textfield on top doesn't go above the screen, usernameField shall not move when keyboard appears, other views shall move up when tapped on.
        // 若编辑usernameField则不移动，点击其他textfield时屏幕向上移动 (usernamefield - 当前textfield) 的距离。
        UIView.animate(withDuration: 0.1) {
            self.view.frame.origin.y = self.usernameField.frame.origin.y - textField.frame.origin.y
        }
    }
    
    @objc override internal func keyboardWillShow(notification: NSNotification) {
        UIView.animate(withDuration: 0.5, animations: {
            self.blurEffectView.effect = UIBlurEffect(style: .regular)
        })
    }
    
    @objc override internal func keyboardWillHide(notification: NSNotification) {
        super.keyboardWillHide(notification: notification)
        UIView.animate(withDuration: 0.5, animations: {
            self.blurEffectView.effect = nil
        })
    }
    
}
