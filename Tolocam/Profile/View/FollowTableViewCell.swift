//
//  FollowTableViewCell.swift
//  Tolocam
//
//  Created by wyx on 2019/2/28.
//  Copyright © 2019年 leo. All rights reserved.
//

import UIKit

@objc protocol FollowTableViewCellDelegate: NSObjectProtocol {
    @objc func cancelFollow(row: Int, view: FollowTableViewCell)
    @objc func follow(row: Int, view: FollowTableViewCell)
}

class FollowTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    weak var delegate: FollowTableViewCellDelegate?
    var userObject = AVObject()
//    var followObjectId = String()
    var indexPathRow: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func finishFollow() {
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                self.followButton.setTitle("取消关注", for: .normal)
                self.followButton.layer.backgroundColor = UIColor(red: 93/255, green: 215/255, blue: 217/255, alpha: 1).cgColor
                NotificationCenter.default.post(name: Notification.Name(rawValue: "PostVCRefresh"), object: nil)
            }
        }
    }
    
    func finishCancelFollow() {
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                self.followButton.setTitle("关注", for: .normal)
                self.followButton.layer.backgroundColor = UIColor(red: 252/255, green: 105/255, blue: 134/255, alpha: 1).cgColor
                NotificationCenter.default.post(name: Notification.Name(rawValue: "PostVCRefresh"), object: nil)
            }
        }
    }
    
    @IBAction func followTapped(_ sender: UIButton) {
        if let delegate = self.delegate, let indexPathRow = self.indexPathRow {
            if sender.titleLabel?.text == "取消关注"{
                if delegate.responds(to: #selector(FollowTableViewCellDelegate.cancelFollow(row:view:))) {
                    delegate.cancelFollow(row: indexPathRow, view: self)
                }
            } else {
                if delegate.responds(to: #selector(FollowTableViewCellDelegate.follow(row:view:))) {
                    delegate.follow(row: indexPathRow, view: self)
                }
            }
        }
//        if sender.titleLabel?.text == "取消关注"{
//            let query = AVQuery(className: "Follow")
//            query.getObjectInBackground(withId: followObjectId, block: { (followObject, error) in
//                if error == nil{
//                    followObject?.deleteInBackground({ (done, error) in
//                        if error == nil {
//                            DispatchQueue.global(qos: .default).async {
//                                DispatchQueue.main.async {
//                                    self.followButton.setTitle("关注", for: .normal)
//                                    self.followButton.layer.backgroundColor = UIColor(red: 252/255, green: 105/255, blue: 134/255, alpha: 1).cgColor
//                                    NotificationCenter.default.post(name: Notification.Name(rawValue: "PostVCRefresh"), object: nil)
//                                }
//                            }
//                        } else {
//                            print(error?.localizedDescription)
//                        }
//                    })
//                }else{
//                    print(error?.localizedDescription)
//                }
//            })
//        }else{
//            let follow = AVObject(className: "Follow")
//            follow["followingTo"] = self.userObject
//            follow["followFrom"] = AVUser.current()
//            follow.saveInBackground({ (done, error) in
//                if error != nil {
//                    print(error!.localizedDescription)
//                }else{
//                    DispatchQueue.global(qos: .default).async {
//                        DispatchQueue.main.async {
//                            self.followButton.setTitle("取消关注", for: .normal)
//                            self.followButton.layer.backgroundColor = UIColor(red: 93/255, green: 215/255, blue: 217/255, alpha: 1).cgColor
//                            NotificationCenter.default.post(name: Notification.Name(rawValue: "PostVCRefresh"), object: nil)
//                        }
//                    }
//                }
//            })
//        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
