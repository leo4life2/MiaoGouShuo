//
//  PostsTableViewController.swift
//  Tolocam
//
//  Created by Leo on 2018/11/2.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import MJRefresh

class PostsTableViewController: UITableViewController {

    var posts = [Post]()
    var likes = [[Like]]()
    var postsComment = [String: (user: String, content: String)]()
    var page: Int = 1
    let pageSize: Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PostsTableViewController.loadPosts), name: NSNotification.Name(rawValue: "PostVCRefresh"), object: nil)
        loadPosts()
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.page = 1
            self?.loadPosts()
        })
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self?.loadPosts()
        })
    }
    
    @objc private func loadLikes(start: Int, end: Int) {
        let myGroup = DispatchGroup()
        for index in start...end {
            myGroup.enter()
            guard let objectId = posts[index].objectId else {return}
            let query = AVQuery(className: "Like")
            let postPointer = AVObject(className: "Posts", objectId: objectId)
            query.whereKey("post", equalTo: postPointer)
            query.includeKey("from")
            var likers = [Like]()
            var likes = 0
            query.findObjectsInBackground { (result, error) in
                if error == nil {
                    if let array = result as? [AVObject] {
                        for item in array {
                            let like = Like(like: item)
                            likers.append(like)
                            likes += like.likeNumber
                        }
                        self.posts[index].likers = likers
                        self.posts[index].likes = likes                        
                        myGroup.leave()
                    }
                } else {
                    myGroup.leave()
                }
            }
        }
        myGroup.notify(queue: .main) {
            self.tableView.reloadData()
        }
    }
    
    @objc private func loadPosts(){
        let start = (page - 1) * pageSize
        let userQuery = AVQuery(className: "Follow")
        userQuery.whereKey("followFrom", equalTo: AVUser.current()!)
        let query = AVQuery(className: "Posts")
        query.limit = pageSize
        query.skip = start
        query.whereKey("postedBy", matchesKey: "followingTo", in: userQuery)
        query.addDescendingOrder("createdAt")
        query.includeKey("postedBy")
        query.includeKey("Image")
        query.findObjectsInBackground{(results, error: Error?) -> Void in
            self.tableView.mj_header.endRefreshing()
            if let error = error{
                self.displayErrorAlert(error: error, completion: nil)
            } else {
                if let posts = results as? [AVObject], posts.count > 0 {
                    if self.page == 1 {
                        self.posts.removeAll()
                    }
                    for post in posts {
                        let postToSave = Post(post: post)
                        self.loadFirstComment(post: postToSave)
                        self.posts.append(postToSave)
                    }
                    self.page += 1
                    self.tableView.reloadData()
                    self.tableView.mj_footer.endRefreshing()
                    self.loadLikes(start: start, end: self.posts.count-1)
                }
                else {
                    self.tableView.mj_footer.endRefreshing()
                }
            }
        }
    }
    
    func loadFirstComment(post: Post) {
//        guard let post = self.post else { return }
        let query = AVQuery(className: "Comments")
        query.whereKey("post", equalTo: post.object!)
        query.includeKey("from")
        query.order(byDescending: "createdAt")
        query.getFirstObjectInBackground { (result, error) in
            if error == nil, let object = result {
                let comment = Comment(comment: object)
                if let from = comment.from, let name = from["nickname"] as? String, let content = comment.content {
                    self.postsComment[post.objectId!] = (user: name, content: content)
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostsTableViewCell", for: indexPath) as! PostsTableViewCell
        let model = self.posts[indexPath.row]
        cell.post = model
        cell.index = indexPath.row
        if let comment = self.postsComment[model.objectId!] {
            cell.displayedCommentLabel.text = comment.user + "：" + comment.content
        } else {
            cell.displayedCommentLabel.text = "暂无最新评论"
        }
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showPostDetailSegue", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPostDetailSegue" {
            let vc = segue.destination as! PostsDetailViewController
            vc.delegate = self
            if let index = sender as? Int {
                vc.post = self.posts[index]
                vc.index = index
            }
        }
    }
}

extension PostsTableViewController: PostsTableViewCellDelegate, PostsDetailViewControllerDelegate {
    func showDetail(index: Int) {
        performSegue(withIdentifier: "showPostDetailSegue", sender: index)
    }
    
    func changePostListData(postObject: Post, at: Int) {
        self.posts[at] = postObject
        self.tableView.reloadRows(at: [IndexPath(row: at, section: 0)], with: .fade)
    }
    
    func changePostData(postObject: Post, at: Int) {
        self.posts[at] = postObject
    }
    
    func showProfile(postBy: AVObject) {
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.isOther = true
        vc.user = postBy as! AVUser
        
        if postBy.value(forKey: "nickname") as! String != (AVUser.current()?.value(forKey: "nickname") as! String){
            self.navigationController!.pushViewController(vc, animated: true)
        }else{
            //user tapped on own username
            self.tabBarController?.selectedIndex = 4
        }
    }
}
