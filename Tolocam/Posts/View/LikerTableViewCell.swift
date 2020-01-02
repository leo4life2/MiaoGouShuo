//
//  LikerTableViewCell.swift
//  ToloCam
//
//  Created by wyx on 10/03/2019.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import AVOSCloud

class LikerTableViewCell: UITableViewCell {

    @IBOutlet weak var crownImageView: UIImageView!
    @IBOutlet weak var likerRankLabel: UILabel!
    @IBOutlet weak var likerProfileImageView: UIImageView!
    @IBOutlet weak var likeName: UILabel!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var userObject = AVObject()
    var followObjectId = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.followButton.layer.cornerRadius = 5
        self.followButton.layer.masksToBounds = true
        
        self.likerProfileImageView.layer.cornerRadius = self.likerProfileImageView.frame.width/2
        self.likerProfileImageView.layer.masksToBounds = true
        
    }
    
    @IBAction func follow(_ sender: UIButton) {
        if sender.titleLabel?.text == "取消关注"{
            let query = AVQuery(className: "Follow")
            query.getObjectInBackground(withId: followObjectId, block: { (followObject, error) in
                if error == nil{
                    followObject?.deleteInBackground({ (done, error) in
                        if error == nil{
                            self.followButton.setTitle("关注", for: .normal)
                            self.followButton.layer.backgroundColor = UIColor(red: 252/255, green: 105/255, blue: 134/255, alpha: 1).cgColor
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "PostVCRefresh"), object: nil)
                        }else{
                            print(error?.localizedDescription)
                        }
                    })
                }else{
                    print(error?.localizedDescription)
                    
                }
            })
        }else{
            let follow = AVObject(className: "Follow")
            follow["followingTo"] = self.userObject
            follow["followFrom"] = AVUser.current()
            follow.saveInBackground({ (done, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }else{
                    self
                    self.followButton.setTitle("取消关注", for: .normal)
                    self.followButton.layer.backgroundColor = UIColor(red: 93/255, green: 215/255, blue: 217/255, alpha: 1).cgColor
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "PostVCRefresh"), object: nil)
                }
            })
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
