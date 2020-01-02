//
//  Post.swift
//  Tolocam
//
//  Created by Leo on 2018/11/22.
//  Copyright © 2018 leo. All rights reserved.
//

import Foundation
import AVOSCloud

class Post: NSObject {
    var object: AVObject?
    var objectId: String?
    var image: String?
    var postedBy: AVObject?
    var caption: String?
    var date: String?
    var likes: Int = 0
    var likers: [Like] = [Like]()
    
    init(post: AVObject) {
        object = post
        objectId = post["objectId"] as? String
        caption = post["Caption"] as? String
        date = post["date"] as? String
//        likes = post["Likes"] as? Int
//        likers = post["likedBy"] as? NSMutableDictionary
        let creatorPointer = post["postedBy"] as? AVObject
        postedBy = creatorPointer
        let imageFile = post["Image"] as? AVFile
        image = imageFile?.url()
    }
}
