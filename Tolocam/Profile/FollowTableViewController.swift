//
//  FollowTableViewController.swift
//  Tolocam
//
//  Created by wyx on 2019/2/28.
//  Copyright © 2019年 leo. All rights reserved.
//

import UIKit

class FollowTableViewController: UITableViewController {

    var isOther = false
    var isFollowers = false
    var user = AVObject()
    var dataArray = [(User,String)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        if isFollowers {
            self.title = "粉丝"
            loadFollowerData()
        } else {
            self.title = "关注"
            loadFollowingData()
        }
    }

    func loadFollowerData() {
        let query = AVQuery(className: "Follow")
        query.whereKey("followingTo", equalTo: user)
        query.whereKey("followFrom", notEqualTo: user)
        query.includeKey("followFrom")
        query.findObjectsInBackground({ (results, error) in
            let followObjects = results as! [AVObject]
            for followObject in followObjects {
                if let pointer = followObject.value(forKey: "followFrom") as? AVObject {
                    let followQuery = AVQuery(className: "Follow")
                    followQuery.whereKey("followFrom", equalTo:AVUser.current()!)
                    followQuery.whereKey("followingTo", equalTo:pointer)
                    followQuery.getFirstObjectInBackground({ (result, error) in
                        if error == nil{
                            let model = User(user: pointer)
                            self.dataArray.append((model, result!.objectId!))
                            self.tableView.reloadData()
                        }else{
                            let model = User(user: pointer)
                            self.dataArray.append((model, ""))
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        })
    }
    
    func loadFollowingData() {
        let query = AVQuery(className: "Follow")
        query.whereKey("followFrom", equalTo: user)
        query.whereKey("followingTo", notEqualTo: user)
        query.includeKey("followingTo")
        query.findObjectsInBackground({ (results, error) in
            let followObjects = results as! [AVObject]
            for followObject in followObjects {
                if let pointer = followObject.value(forKey: "followingTo") as? AVObject {
                    let followQuery = AVQuery(className: "Follow")
                    followQuery.whereKey("followFrom", equalTo:AVUser.current()!)
                    followQuery.whereKey("followingTo", equalTo:pointer)
                    followQuery.getFirstObjectInBackground({ (result, error) in
                        if error == nil{
                            let model = User(user: pointer)
                            self.dataArray.append((model, followObject.objectId!))
                            self.tableView.reloadData()
                        }else{
                            let model = User(user: pointer)
                            self.dataArray.append((model, ""))
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        })
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableCell", for: indexPath) as! FollowTableViewCell
        let pair = dataArray[indexPath.row]
        
        cell.userObject = pair.0.object!
//        cell.followObjectId = pair.1
        cell.indexPathRow = indexPath.row
        cell.delegate = self
        
//        if pair.0.username == AVUser.current()?.username {
//            cell.followButton.isHidden = true
//        }else
        if pair.1 != ""{
            //following
            cell.followButton.setTitle("取消关注", for: .normal)
            cell.followButton.layer.backgroundColor = UIColor(red: 93/255, green: 215/255, blue: 217/255, alpha: 1).cgColor
        }else{
            cell.followButton.setTitle("关注", for: .normal)
            cell.followButton.layer.backgroundColor = UIColor(red: 252/255, green: 105/255, blue: 134/255, alpha: 1).cgColor
        }
        
        if let str = pair.0.profileIm, let url = URL(string: str) {
            cell.profileImageView.kf.setImage(with: url)
        }
        
        cell.nameLabel.text = pair.0.nickname
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = self.tableView.cellForRow(at: indexPath) as! FollowTableViewCell
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.user = self.dataArray[indexPath.row].0.object as! AVUser
        vc.isOther = true
        
        if cell.nameLabel.text == AVUser.current()?.value(forKey: "nickname") as? String {
            self.tabBarController?.selectedIndex = 4
        }else{
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }

}

extension FollowTableViewController: FollowTableViewCellDelegate {
    func cancelFollow(row: Int, view: FollowTableViewCell) {
        let followObjectId = self.dataArray[row].1
        let query = AVQuery(className: "Follow")
        query.getObjectInBackground(withId: followObjectId, block: { (followObject, error) in
            if error == nil{
                followObject?.deleteInBackground({ (done, error) in
                    if error == nil {
                        view.finishCancelFollow()
                        self.dataArray[row].1 = ""
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }else{
                print(error!.localizedDescription)
            }
        })
    }
    
    func follow(row: Int, view: FollowTableViewCell) {
        let userObject = self.dataArray[row].0
        let follow = AVObject(className: "Follow")
        follow["followingTo"] = userObject.object
        follow["followFrom"] = AVUser.current()
        follow.saveInBackground({ (done, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                view.finishFollow()
                let query = AVQuery(className: "Follow")
                query.whereKey("followingTo", equalTo: userObject.object!)
                query.whereKey("followFrom", equalTo: AVUser.current()!)
                if let object = query.getFirstObject() {
                    view.finishFollow()
                    self.dataArray[row].1 = object.objectId!
                }
            }
        })
    }
}
