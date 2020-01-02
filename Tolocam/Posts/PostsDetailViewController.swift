//
//  PostsDetailViewController.swift
//  Tolocam
//
//  Created by wyx on 2019/2/21.
//  Copyright © 2019年 leo. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
import NextGrowingTextView
import AVOSCloud

@objc protocol PostsDetailViewControllerDelegate: NSObjectProtocol {
    @objc func changePostListData(postObject: Post, at: Int)
}

class PostsDetailViewController: UIViewController {

    @IBOutlet weak var likeButton: GXUpvoteButton!
//    var likers = [(String,Int)]()//username:likeCount
    var like = 0
    var likers = [Like]()
    var comments = [Comment]()
    
    var index: Int?
    weak var delegate: PostsDetailViewControllerDelegate?
    var post: Post? {
        willSet {
            if let value = newValue {
                var likersLeaderboard = value.likers
//                var likersLeaderboard = [(String,Int)]()
//                for pair in value.likers {
//                    let pairOfLikerLikes = ((pair.key as! String),(pair.value as! Int))
//                    likersLeaderboard.append(pair)
//                }
                likersLeaderboard.sort(by: { $0.likeNumber > $1.likeNumber })
                if likersLeaderboard.count > 9 {
                    likersLeaderboard.removeLast(likersLeaderboard.count - 10)
                    likers = likersLeaderboard
                } else {
                    likers = likersLeaderboard
                }
            }
        }
    }
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var accessoryButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var likerCollectionView: UICollectionView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var inputContainerView: UIView!
    
    @IBOutlet weak var inputContainerViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var growingTextView: NextGrowingTextView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()

        accessoryButton.imageEdgeInsets = UIEdgeInsets(top: 23, left: 11, bottom: 23, right: 15)
        if let post = self.post {
            if let str = post.image, let url = URL(string: str) {
                postImageView.kf.setImage(with: url)
                likeLabel.text = String(post.likes)
            }
            captionLabel.text = post.caption
        }
        tableView.tableFooterView = UIView()
        self.scrollView.keyboardDismissMode = .onDrag
        self.likerCollectionView.reloadData()
        self.likeButton.delegate = self
        
        self.setupTextView()
        self.setupTitleView()
        self.loadComments()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "smscode"), style: .plain, target: self, action: #selector(rightBarButtonAction))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    @objc func rightBarButtonAction() {
        if let post = self.post {
            if let postedBy = post.postedBy {
                if postedBy["username"] as? String == AVUser.current()?.username {
                    //删除
                    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    actionSheet.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { (action:UIAlertAction) in
                        let query = AVQuery(className: "Posts")
                        query.getObjectInBackground(withId: self.post!.objectId!, block: { (object:AVObject?, error:Error?) in
                            if error == nil{
                                object?.deleteInBackground({ (done:Bool, error:Error?) in
                                    if error != nil{
                                        print(error)
                                    }else{
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: "PostVCRefresh"), object: nil)
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: "ProfileVCRefresh"), object: nil)
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                })
                            }else{
                                print(error!)
                            }
                        })
                    }))
                    actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                    self.present(actionSheet, animated: true, completion: nil)
                } else {
                    //举报
                    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    actionSheet.addAction(UIAlertAction(title: "举报", style: .default, handler: { (action:UIAlertAction) in
                        let action = UIAlertAction(title: "举报", style: .destructive, handler: { (alertAction) in
                            let report = AVObject(className: "Reports")
                            report["Post"] = self.post?.object
                            report.saveInBackground({ (success, error) in
                                TLAlertView.showAlert(title: "成功", message: "管理员将在24小时内对此内容采取措施", cancel: "确定")
                            })
                        })
                        TLAlertView.showAlert(title: "举报", message: "确定要举报此内容吗？", cancel: "取消", action: action)
                    }))
                    actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                    self.present(actionSheet, animated: true, completion: nil)
                }
            }
        }
    }
    
    func setupTitleView() {
        let titleView = TLTitleView(frame: CGRect())
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapToshowProfile)))
        self.navigationItem.titleView = titleView
        if let post = self.post {
            if let postedBy = post.postedBy {
                titleView.nameLabel.text = postedBy["nickname"] as? String
                if let profilePic = post.postedBy?["profileIm"] as! AVFile?, let str = profilePic.url(), let url = URL(string: str) {
                    titleView.profileImageView.kf.setImage(with: url)
                }
            }
            titleView.dateLabel.text = post.date
        }
        
    }
    
    func loadComments() {
        guard let post = self.post else { return }
        let query = AVQuery(className: "Comments")
        query.whereKey("post", equalTo: post.object!)
        query.includeKey("from")
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (results, error) in
            if error == nil, let objects = results {
                for item in objects {
                    let comment = Comment(comment: item as! AVObject)
                    self.comments.append(comment)
                    self.tableView.reloadData()
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
                        self.likeLabel.text = "\(post.likes + likeNum)"
                        post.likes += likeNum
                        if let index = self.index {
                            self.delegate?.changePostListData(postObject: post, at: index)
                        }
                    } else {
                        KMProgressHUD.shareInstance.showHUDFail(message: "Failed, Please Try Again")
                        KMProgressHUD.shareInstance.hideHUD()
                    }
                })
            }
        }
    }
    
    @objc func tapToshowProfile() {
        if let post = self.post {
            if let postedBy = post.postedBy as? AVUser {
                self.showProfile(user: postedBy)                
            }
        }
    }
    
    @objc func showProfile(user: AVUser?) {
        var showUser: AVUser?
        if let u = user {
            showUser = u
        } else {
            if let postedBy = self.post?.postedBy {
                showUser = postedBy as? AVUser
            }
        }
        if let postedBy = showUser {
            let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            vc.isOther = true
            vc.user = postedBy
//            print(postedBy["nickname"])
//            print(AVUser.current()?["nickname"])
            if postedBy.object(forKey: "nickname") as! String != (AVUser.current()?.object(forKey: "nickname") as! String){
                self.navigationController!.pushViewController(vc, animated: true)
            }else{
                //user tapped on own username
                self.tabBarController?.selectedIndex = 4
            }
        }
    }
    
    func setupTextView() {
        NotificationCenter.default.addObserver(self, selector: #selector(PostsDetailViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PostsDetailViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.inputContainerView.layer.shadowOffset = CGSize(width: 0, height: -2)
        self.inputContainerView.layer.shadowColor = UIColor.lightGray.cgColor
        
        self.growingTextView.layer.cornerRadius = 4
        self.growingTextView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        self.growingTextView.placeholderAttributedText = NSAttributedString(
            string: "说些什么吧～",
            attributes: [
                .font: self.growingTextView.textView.font!,
                .foregroundColor: UIColor.gray
            ]
        )
    }
    
    @IBAction func handleSendButton(_ sender: AnyObject) {
        let str = self.growingTextView.textView.text
        if str!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0 {
            let comment = AVObject(className: "Comments")
            comment["post"] = self.post?.object
            comment["content"] = str
            comment["from"] = AVUser.current()!
            //TODO：下个版本添加可回复指定的人
            //comment.setValue(AVUser.current()!, forKey: "to")
            comment.saveInBackground { (success, error) in
                if success {
                    var newComment = Comment()
                    newComment.post = self.post?.object
                    newComment.content = str
                    newComment.from = AVUser.current()!
                    newComment.createdAtStr = Date().getFormatString()
                    self.comments.insert(newComment, at: 0)
                    self.tableView.reloadData()
                    self.growingTextView.textView.text = ""
                    self.view.endEditing(true)
                } else {
                    TLAlertView.showAlert(title: "Error", message: "fail to send comment, try again", cancel: "OK")
                }
            }
        }
    }
    
    @IBAction func showRankList(_ sender: UIButton) {
        performSegue(withIdentifier: "showRankListSegue", sender: nil)
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let _ = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                //key point 0,
                self.inputContainerViewBottom.constant =  0
                //textViewBottomConstraint.constant = keyboardHeight
                UIView.animate(withDuration: 0.25, animations: { () -> Void in self.view.layoutIfNeeded() })
            }
        }
    }
    @objc func keyboardWillShow(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                self.inputContainerViewBottom.constant = keyboardHeight - (self.tabBarController?.tabBar.frame.size.height)!
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRankListSegue" {
            let vc = segue.destination as! LikerTableViewController
            if let likers = self.post?.likers {
//                vc.dictionaryOfLikers = likers
                vc.likers = likers
            } else {
                return
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension PostsDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "likerTopCollectionViewCell", for: indexPath) as! LikerTopCollectionViewCell
        cell.isTop = indexPath.row == 0
        
        guard let liker = likers[indexPath.row].from else {
            return cell
        }
        let query = AVQuery(className: "_User")
        query.whereKey("username", equalTo: liker.username!)
        query.getFirstObjectInBackground({ (result:AVObject?, error:Error?) in
            if error == nil{
                if let profileImgFile = result?["profileIm"] as? AVFile, let str = profileImgFile.url(), let url = URL(string: str) {
                    cell.profileImageView.kf.setImage(with: url)                    
                }
            }
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.row == 0 ? CGSize(width: 52, height: 60) : CGSize(width: 30, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let liker = likers[indexPath.row].from else {
            return
        }
        let query = AVQuery(className: "_User")
        query.whereKey("username", equalTo: liker.username!)
        query.getFirstObjectInBackground({ (result:AVObject?, error:Error?) in
            if error == nil, let user = result as? AVUser {
                self.showProfile(user: user)
            }
        })
    }
}

extension PostsDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
        let comment = comments[indexPath.row]
        if let name = comment.from?["nickname"] as? String {
            cell.nameLabel.text = name + ":"
        }
        cell.commentLabel.text = comment.content
        cell.dateLabel.text = comment.createdAtStr
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.indexPathsForVisibleRows?.last?.row {
            DispatchQueue.main.async {
                self.tableViewHeight.constant = tableView.contentSize.height
            }
        }
    }
}

extension PostsDetailViewController: LikeButtonDelegate {
    func likeButtonPressEnd(_ count: Int) {
        self.saveLike(likeNum: count)
    }
}

class TLTitleView: UIView {
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let dateLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        profileImageView.layer.cornerRadius = 18
        profileImageView.layer.masksToBounds = true
        profileImageView.image = UIImage(named: "DefaultProfileImg")
        self.addSubview(profileImageView)
        
        nameLabel.font =  UIFont(name: "PingFangSC-Medium", size: 14)
        nameLabel.textColor = UIColor(red: 80/255, green: 79/255, blue: 79/255, alpha: 1)
        self.addSubview(nameLabel)

        dateLabel.font =  UIFont(name: "Avenir-Roman", size: 12)
        dateLabel.textColor = UIColor(red: 151/255, green: 147/255, blue: 147/255, alpha: 1)
        self.addSubview(dateLabel)
        profileImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left)
            make.centerY.equalTo(self.snp.centerY)
            make.height.width.equalTo(36)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(profileImageView.snp.right).offset(10)
            make.height.equalTo(20)
            make.top.equalTo(self.snp.top)
            make.right.equalTo(self.snp.right)
        }
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.left)
            make.height.equalTo(16)
            make.top.equalTo(nameLabel.snp.bottom)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var intrinsicContentSize: CGSize { // 重写get方法
        get {
            return CGSize.init(width: 180, height: 44)
        }
    }
}

