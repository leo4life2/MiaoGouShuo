//
//  User.swift
//  Tolocam
//
//  Created by wyx on 2019/2/27.
//  Copyright © 2019年 leo. All rights reserved.
//

import Foundation
import UIKit
import AVOSCloud

struct User{
    var object: AVObject?
    var objectId: String?
    var profileIm: String? = nil
    var username: String?
    var nickname: String?
    var mobilePhoneNumber: String?
    
    init(user: AVObject) {
        object = user
        objectId = user["objectId"] as? String
        username = user["username"] as? String
        nickname = user["nickname"] as? String
        mobilePhoneNumber = user["mobilePhoneNumber"] as? String
        if let imageFile = user["profileIm"] as? AVFile {
            profileIm = imageFile.url()
        }
    }
}
