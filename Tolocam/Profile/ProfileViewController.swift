//
//  ProfileViewController.swift
//  Tolocam
//
//  Created by wyx on 2019/2/27.
//  Copyright © 2019年 leo. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followedButton: UIButton!
    
    @IBOutlet weak var followStateButton: UIButton!
    @IBOutlet weak var screenButton: UIButton!
    
    @IBOutlet weak var followView: UIView!
    @IBOutlet weak var followViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataArray = [Post]()
    
    var user: AVUser = AVUser.current()!
    var isOther = false
    var isFollowed = false //是否已关注
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        if isOther {
            self.rightBarButton.image = UIImage(named: "chat")
            self.getFollowState()
        } else {
            self.rightBarButton.image = UIImage(named: "settings")
            NotificationCenter.default.addObserver(self, selector: #selector(postRefresh), name: Notification.Name(rawValue: "ProfileVCRefresh"), object: nil)
        }
        
        setupProfileView()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFollowData()
    }
    
    @IBAction func rightBarButtonAction(_ sender: UIBarButtonItem) {
        if isOther {
            performSegue(withIdentifier: "showChatSegue", sender: nil)
        } else {
            performSegue(withIdentifier: "showSettingsSegue", sender: nil)
        }
    }
    
    @objc func postRefresh() {
        loadData()
        loadFollowData()
    }
    
    @IBAction func followButtonAction(_ sender: UIButton) {
        if isFollowed == false {
            let follow = AVObject(className: "Follow")
            follow["followFrom"] = AVUser.current()
            follow["followingTo"] = self.user
            follow.saveInBackground { (success, error) in
                if success {
                    self.followStateButton.setTitle("取消关注", for: .normal)
                    self.followStateButton.layer.backgroundColor = UIColor(red: 93/255, green: 215/255, blue: 217/255, alpha: 1).cgColor
                    self.isFollowed = true
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "PostVCRefresh"), object: nil)
                } else {
                    
                }
            }
        }else{
            let query = AVQuery(className: "Follow")
            query.whereKey("followFrom", equalTo:AVUser.current()!)
            query.whereKey("followingTo", equalTo:self.user)
            query.deleteAllInBackground { (success, error) in
                if success {
                    self.followStateButton.setTitle("关注", for: .normal)
                    self.followStateButton.layer.backgroundColor = UIColor(red: 252/255, green: 105/255, blue: 134/255, alpha: 1).cgColor
                    self.isFollowed = false
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "PostVCRefresh"), object: nil)
                }
            }
        }
    }
    
    func getFollowState() {
        let query = AVQuery(className: "Follow")
        query.whereKey("followingTo", equalTo: user)
        query.whereKey("followFrom", equalTo: AVUser.current()!)
        query.getFirstObjectInBackground { (object, error) in
            if error == nil && object != nil {
                self.followStateButton.setTitle("取消关注", for: .normal)
                self.followStateButton.layer.backgroundColor = UIColor(red: 93/255, green: 215/255, blue: 217/255, alpha: 1).cgColor
                self.isFollowed = true
            } else {
                self.followStateButton.setTitle("关注", for: .normal)
                self.followStateButton.layer.backgroundColor = UIColor(red: 252/255, green: 105/255, blue: 134/255, alpha: 1).cgColor
                self.isFollowed = false
            }
        }
    }
    
    
    
    func setupProfileView() {
        let userModel = User(user: user)
        if let str = userModel.profileIm, let url = URL(string: str) {
            profileImageView.kf.setImage(with: url)
        }        
        if isOther {//其他用户
            self.title = userModel.nickname
            nameLabel.text = "用户名：" + userModel.username!
        } else {//个人中心
            nameLabel.text = userModel.nickname!
            followViewHeight.constant = 0
            followView.isHidden = true
        }
    }
    
    func loadData() {
        let query = AVQuery(className: "Posts")
        query.order(byDescending: "createdAt")
        query.whereKey("postedBy", equalTo: user)
        query.includeKey("postedBy")
        query.includeKey("Image")
        query.findObjectsInBackground{(results, error: Error?) -> Void in
            if (error == nil) {
                if let posts = results as? [AVObject] {
                    self.dataArray.removeAll()
                    for post in posts {
                        if post["Image"] != nil{
                            let model = Post(post: post)
                            self.dataArray.append(model)
                        }
                    }
                    self.collectionView.reloadData()
                }
            } else {
                if error!.localizedDescription == "The Internet connection appears to be offline."{
                    TLAlertView.showAlert(title: "Error", message:"The Internet connection appears to be offline. Please try again later.", cancel: "OK")
                }
            }
        }
    }

    func loadFollowData() {
        let followerQuery = AVQuery(className: "Follow")
        followerQuery.whereKey("followingTo", equalTo: user)
        followerQuery.whereKey("followFrom", notEqualTo: user)
        
        let followingQuery = AVQuery(className: "Follow")
        followingQuery.whereKey("followFrom", equalTo: user)
        followingQuery.whereKey("followingTo", notEqualTo: user)
        
        followerQuery.countObjectsInBackground { (count, error) in
            if error == nil{
                self.followedButton.setTitle("\(count)", for: .normal)
            }
        }
        
        followingQuery.countObjectsInBackground({ (count, error) in
            if error == nil{
                self.followingButton.setTitle("\(count)", for: .normal)
            }
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ExploreCollectionViewCell
        let model = self.dataArray[indexPath.row]
        if let str = model.image, let url = URL(string: str) {
            cell.imageView.kf.setImage(with: url)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let wh = (UIScreen.main.bounds.size.width - 4.0)/3.0
        return CGSize(width: wh, height: wh)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = self.dataArray[indexPath.row]
        performSegue(withIdentifier: "showDetailSegue", sender: model)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailSegue" {
            let vc = segue.destination as! PostsDetailViewController
            if let postDetail = sender as? Post {
                vc.post = postDetail
            }
        }
        if segue.identifier == "showFollowingSegue" {
            let vc = segue.destination as! FollowTableViewController
            vc.user = self.user
            vc.isOther = self.isOther
            vc.isFollowers = false
        }
        if segue.identifier == "showFollowerSegue" {
            let vc = segue.destination as! FollowTableViewController
            vc.user = self.user
            vc.isOther = self.isOther
            vc.isFollowers = true
        }
        if segue.identifier == "showChatSegue" {
            let vc = segue.destination as! ChatViewController
            vc.otherObject = User(user: user)
        }
    }
}
