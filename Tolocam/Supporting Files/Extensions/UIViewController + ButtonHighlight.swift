//
//  UIViewController + ButtonHighlight.swift
//  Tolocam
//
//  Created by Leo on 2018/10/30.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

extension UIViewController {
    
    @objc public func buttonHighlight(_ sender: Any){
        let button = sender as! UIButton
        button.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        button.layer.borderWidth = 0
    }
    
    @objc public func buttonNormal(_ sender: Any){
        let button = sender as! UIButton
        button.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        button.layer.borderWidth = 4
    }
}
