//
//  File.swift
//  Tolocam
//
//  Created by Leo on 2018/9/8.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import AVOSCloud

extension UIViewController {
    
    public func displayMessageAlert(_ title: String, message: String, completion: (() -> Void)?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: completion)
    }
    
    public func displayErrorAlert(_ title: String = "错误" , message: String, completion: (() -> Void)?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: completion)
    }
    
    public func displayErrorAlert(_ title: String = "错误", error: Error, completion: (() -> Void)?){
//        let error = error as! AVError
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: completion)
    }
    
}
