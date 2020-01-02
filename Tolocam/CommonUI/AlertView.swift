//
//  TLAlertView.swift
//  Tolocam
//
//  Created by wyx on 15/02/2018.
//  Copyright © 2018 wyx. All rights reserved.
//

import Foundation
import UIKit

class TLAlertView {
    static func showAlert(title: String, message: String, cancel: String?, action: UIAlertAction? = nil, completion: (()->Void)? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let action = action {
            alert.addAction(action)
        }
        if let cancelText = cancel {
            alert.addAction(UIAlertAction(title: cancelText, style: .cancel, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
        } else {
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true) {
                Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { (timer) in
                    if let newAlert = completion{
                        newAlert()
                    }
                    alert.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
    
}

