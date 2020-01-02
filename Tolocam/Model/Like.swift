//
//  Like.swift
//  Tolocam
//
//  Created by wyx on 2019/4/4.
//  Copyright © 2019年 leo. All rights reserved.
//

import Foundation
import AVOSCloud

struct Like {
    var object: AVObject?
    var objectId: String?
    var from: AVUser?
    var post: AVObject?
    var likeNumber: Int = 0
    
    init(like: AVObject) {
        object = like
        objectId = like["objectId"] as? String
        from = like["from"] as? AVUser
        post = like["post"] as? AVObject
        likeNumber = like["likeNumber"] as? Int ?? 0
    }
}
