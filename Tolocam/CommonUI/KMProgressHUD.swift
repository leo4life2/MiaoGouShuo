//
//  KMProgressHUD.swift
//  Kuma
//
//  Created by wyx on 2018/10/16.
//  Copyright © 2018年 com.focusmedia. All rights reserved.
//

import Foundation
import MBProgressHUD

class KMProgressHUD: NSObject {
    static let shareInstance = KMProgressHUD()
    @objc class func ocshared() -> KMProgressHUD {
        return shareInstance
    }

//    let HUD: MBProgressHUD = {
//        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
//        hud.bezelView.color = UIColor.clear
//        return hud
//    }()

    @objc func showHUD(message: String? = "") {
//        HUD.bezelView.color = UIColor.clear
        let view = KMProgressHUD.viewWithShow()

        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        if let message = message, message.count > 0 {
            hud.isUserInteractionEnabled = false
        }
        hud.label.text = message
//        HUD.label.text = message
        // 细节文字
//        HUD.detailsLabel.text = "请耐心等待..."
//        HUD.backgroundView.style = .blur // 或SolidColor
//        HUD.hideAnimated(true, afterDelay: 2)
    }

    @objc func hideHUD() {
//        HUD.hide(animated: true)
        let view = KMProgressHUD.viewWithShow()
        MBProgressHUD.hide(for: view, animated: true)
    }

    @objc func showHUDAutoHide(message: String) {
        let view = KMProgressHUD.viewWithShow()

        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.isUserInteractionEnabled = false
        hud.label.text = message
//        let img = UIImage(named: "MBProgressHUD.bundle/\(icon)")

//        hud.customView = UIImageView(image: img)
        hud.mode = MBProgressHUDMode.text
        hud.removeFromSuperViewOnHide = true

        hud.hide(animated: true, afterDelay: 1.5)
    }

//    func showHUDAutoHide(message: String) {
//        let afterDelay = Double(message.count) * 0.5
//        HUD.label.text = message
//        HUD.hide(animated: true, afterDelay: afterDelay)
//    }

    @objc func showHUDFail(message: String) {
        let view = KMProgressHUD.viewWithShow()

        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.isUserInteractionEnabled = false
        let img = UIImage(named: "hud_fail")
        hud.customView = UIImageView(image: img)
        hud.label.text = message
        hud.mode = MBProgressHUDMode.customView
        hud.removeFromSuperViewOnHide = true

        hud.hide(animated: true, afterDelay: 3)
//        HUD.customView = UIImageView(image: UIImage(named: "hud_fail"))
//        HUD.label.text = message
//        HUD.hide(animated: true, afterDelay: 2)
    }

//
    @objc func showHUDSuccess(message: String) {
        let view = KMProgressHUD.viewWithShow()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.isUserInteractionEnabled = false
        let img = UIImage(named: "hud_success")
        hud.customView = UIImageView(image: img)
        hud.label.text = message
        hud.mode = MBProgressHUDMode.customView
        hud.removeFromSuperViewOnHide = true

        hud.hide(animated: true, afterDelay: 3)
//        HUD.customView = UIImageView(image: UIImage(named: "hud_success"))
//        HUD.label.text = message
//        HUD.hide(animated: true, afterDelay: 2)
    }

    @objc class func viewWithShow() -> UIView {
        var window = UIApplication.shared.keyWindow
        if window?.windowLevel != UIWindow.Level.normal {
            let windowArray = UIApplication.shared.windows

            for tempWin in windowArray {
                if tempWin.windowLevel == UIWindow.Level.normal {
                    window = tempWin
                    break
                }
            }
        }
        return window!
    }
}
