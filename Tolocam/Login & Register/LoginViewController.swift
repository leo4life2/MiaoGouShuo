//
//  LoginViewController.swift
//  Tolocam
//
//  Created by Leo on 2018/9/5.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import AVOSCloud
import NVActivityIndicatorView

class LoginViewController: ViewControllerWithKeyboard, UITextFieldDelegate, NVActivityIndicatorViewable {
    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    private var blurEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       __setupUIAttributes()
    }

    @IBAction func loginTapped(_ sender: Any) {
        guard let username = self.usernameField.text, !username.isEmpty else {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            self.displayErrorAlert(message: "账号不可为空", completion: nil)
            return
        }
        
        guard let password = self.pwField.text, !password.isEmpty else {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            self.displayErrorAlert(message: "密码不可为空", completion: nil)
            return
        }
        
        //Pac Man Loading Animation // Pac Man 登录动画
        let activityData = ActivityData(size: CGSize(width: 48, height: 48), message: "登录ing...", messageFont: UIFont(name: "PingFangSC", size: 18), messageSpacing: 0, type: .pacman, color: .white, padding: 0, displayTimeThreshold: 0, minimumDisplayTime: 200, backgroundColor: UIColor(white: 0, alpha: 0.7), textColor: .white)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
        
        self.view.isUserInteractionEnabled = false // Prevent tapping login twice // 防止重复点击登录按钮
        
        AVUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            self.view.isUserInteractionEnabled = true
            
            if let error = error {
                // Login Failed // 登录失败
                self.displayErrorAlert(error: error, completion: nil)
            } else {
                // Login Succeeded // 登录成功
                UIApplication.shared.keyWindow?.rootViewController = Tolo.getTabBarController()
//                self.show(Tolo.tabBarController, sender: self)
            }
            
        }
        
    }
    
    @IBAction func forgotPw(_ sender: Any) {
        
    }
    
    @IBAction func toRegister(_ sender: Any){
        
    }
    
    private func __setupUIAttributes() {
        // Text Fields // 输入框
        self.usernameField.tintColor = UIColor.white
        self.pwField.tintColor = UIColor.white
        self.usernameField.delegate = self
        self.pwField.delegate = self
        
        // Login Button // 登录按钮
        self.loginButton.layer.cornerRadius = self.loginButton.frame.height/2
        self.loginButton.layer.borderWidth = 4
        self.loginButton.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3).cgColor
        self.loginButton.addTarget(self, action: #selector(buttonHighlight(_:)), for: .touchDown)
        self.loginButton.addTarget(self, action: #selector(buttonNormal(_:)), for: .touchUpInside)
        self.loginButton.addTarget(self, action: #selector(buttonNormal(_:)), for: .touchUpOutside)
        
        // Blur Effect // 背景模糊效果
        self.blurEffectView = UIVisualEffectView()
        self.blurEffectView.frame = self.view.bounds
        self.backgroundImg.addSubview(self.blurEffectView)
    }
    
    @objc override internal func keyboardWillShow(notification: NSNotification) {
        super.keyboardWillShow(notification: notification)
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

