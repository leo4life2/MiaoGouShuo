//
//  PostsTableViewCell.swift
//  Tolocam
//
//  Created by Leo on 2018/11/2.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import Kingfisher

 @objc protocol PostsTableViewCellDelegate: NSObjectProtocol {
    @objc func showProfile(postBy: AVObject)
    @objc func showDetail(index: Int)
    @objc func changePostData(postObject: Post, at: Int)
}

class PostsTableViewCell: UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var creatorDisplayName: UILabel!
    @IBOutlet weak var creatorProfileImageView: UIImageView!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var totalLikesLabel: UILabel!
    @IBOutlet weak var postCaptionLabel: UILabel!
    @IBOutlet weak var displayedCommentLabel: UILabel!
    @IBOutlet weak var kingOfTheLikesCrown: UIImageView!
    @IBOutlet weak var kingOfTheLikesProfileImageView: UIImageView!
    @IBOutlet weak var likeButton: GXUpvoteButton!
    
    weak var delegate: PostsTableViewCellDelegate?
    var index: Int?
    
    var post: Post? {
        willSet{
            guard let value = newValue else {
                return
            }
            if let str = value.image, let url = URL(string: str) {
                postImageView.kf.setImage(with: url)
            }
            
            if let postedBy = value.postedBy {
                creatorDisplayName.text = postedBy["nickname"] as? String
                if let profilePic = value.postedBy?["profileIm"] as! AVFile?, let str = profilePic.url(), let url = URL(string: str) {
                    self.creatorProfileImageView.kf.setImage(with: url)
                }
            } else {
                creatorDisplayName.text = "Anonym"
            }
        
            postDate.text = value.date
            totalLikesLabel.text = String(value.likes)
            
            postCaptionLabel.text = value.caption
            kingOfTheLikesCrown.isHidden = value.likers.count == 0
            kingOfTheLikesProfileImageView.isHidden = value.likers.count == 0
            
            //TopLiker
            var likersLeaderboard = [(String,Int)]()
            for pair in value.likers {
                let pairOfLikerLikes = (pair.from?["nickname"] as! String, pair.likeNumber)
                likersLeaderboard.append(pairOfLikerLikes)
            }
            likersLeaderboard.sort(by: { $0.1 > $1.1 })
            if likersLeaderboard.count > 0{
                let topLiker = likersLeaderboard[0].0
                let query = AVQuery(className: "_User")
                query.whereKey("username", equalTo: topLiker)
                query.getFirstObjectInBackground({ (result:AVObject?, error:Error?) in
                    if error == nil{
                        if let profileImgFile = result?["profileIm"] as? AVFile, let str = profileImgFile.url(), let url = URL(string: str) {
                            self.kingOfTheLikesProfileImageView.kf.setImage(with: url)
                        }
                    }
                })
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        likeButton.delegate = self
        creatorProfileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfileAction)))
    }
    
    @IBAction func commentAction(_ sender: UIButton) {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(PostsTableViewCellDelegate.showProfile(postBy:))) {
                if let index = self.index {
                    delegate.showDetail(index: index)
                }
            }
        }
    }
    
    @objc func showProfileAction(sender: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(PostsTableViewCellDelegate.showProfile(postBy:))) {
                if let postBy = post?.postedBy {
                    delegate.showProfile(postBy: postBy)
                }
            }
        }
    }
    
    func saveLike(likeNum: Int) {
        if let post = self.post {
            var saveObject: AVObject?
            KMProgressHUD.shareInstance.showHUD()
            let query = AVQuery(className: "Like")
            query.whereKey("from", equalTo: AVUser.current()!)
            query.whereKey("post", equalTo: post.object!)
            query.getFirstObjectInBackground { (object, error) in
                if let likeObject = object {
                    let likeNumber = likeObject["likeNumber"] as! Int
                    object?.setObject(likeNumber + likeNum, forKey: "likeNumber")
                    saveObject = object
                } else {
                    let likeObject = AVObject(className: "Like")
                    likeObject.setObject(AVUser.current()!, forKey: "from")
                    likeObject.setObject(post.object, forKey: "post")
                    likeObject.setObject(likeNum, forKey: "likeNumber")
                    saveObject = likeObject
                }
                saveObject?.saveInBackground({ (success, error) in
                    if success {
                        KMProgressHUD.shareInstance.hideHUD()
                        self.totalLikesLabel.text = "\(post.likes + likeNum)"
                        post.likes += likeNum
                        if let index = self.index {
                            self.delegate?.changePostData(postObject: post, at: index)
                        }
                    } else {
                        KMProgressHUD.shareInstance.showHUDFail(message: "Failed, Please Try Again")
                        KMProgressHUD.shareInstance.hideHUD()
                    }
                })
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension PostsTableViewCell: LikeButtonDelegate {
    func likeButtonPressEnd(_ count: Int) {
        self.saveLike(likeNum: count)
    }
}
