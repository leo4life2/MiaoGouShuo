//
//  Tolo.swift
//  Tolocam
//
//  Created by Leo on 2018/9/18.
//  Copyright © 2018 leo. All rights reserved.
//

import Foundation
import UIKit

struct Tolo {
    static let storyboard = UIStoryboard(name: "Main", bundle: nil)
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    static func getTabBarController() -> ToloTabBarViewController {
        return Tolo.storyboard.instantiateViewController(withIdentifier: "TabBarController") as! ToloTabBarViewController
    }
    static func getLoginViewController() -> LoginViewController {
        return Tolo.storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
    }
    static func getPrivacyViewController() -> PrivacyViewController {
        return Tolo.storyboard.instantiateViewController(withIdentifier: "PrivacyViewController") as! PrivacyViewController
    }
    
//    static let tabBarController = Tolo.storyboard.instantiateViewController(withIdentifier: "TabBarController") as! ToloTabBarViewController
//    static let loginViewController = Tolo.storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
    static let registerViewController = Tolo.storyboard.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
    static let walkthroughPageViewController = Tolo.storyboard.instantiateViewController(withIdentifier: "WalkthroughPageViewController") as! WalkthroughPageViewController
    static let walkthroughPage1ViewController = Tolo.storyboard.instantiateViewController(withIdentifier: "WalkthroughPage1ViewController")
    static let walkthroughPage2ViewController = Tolo.storyboard.instantiateViewController(withIdentifier: "WalkthroughPage2ViewController")
    static let walkthroughPage3ViewController = Tolo.storyboard.instantiateViewController(withIdentifier: "WalkthroughPage3ViewController")
    static let walkthroughPage4ViewController = Tolo.storyboard.instantiateViewController(withIdentifier: "WalkthroughPage4ViewController")
    static let walkthroughPage5ViewController = Tolo.storyboard.instantiateViewController(withIdentifier: "WalkthroughPage5ViewController") as! WalkthroughPage5ViewController
    
}
