//
//  Comment.swift
//  Tolocam
//
//  Created by wyx on 2019/3/14.
//  Copyright © 2019年 leo. All rights reserved.
//

import Foundation
import AVOSCloud

struct Comment {
    var object: AVObject?
    var objectId: String?
    var content: String?
    var post: AVObject?
    var from: AVObject?
    var to: AVObject?
    var createdAtStr: String?
    
    init() {        
    }
    init(comment: AVObject) {
        object = post
        objectId = comment["objectId"] as? String
        content = comment["content"] as? String
        post = comment["post"] as? AVObject
        from = comment["from"] as? AVObject
        to = comment["to"] as? AVObject
        let date = comment["createdAt"] as? Date
        createdAtStr = date?.getFormatString()
    }
}
