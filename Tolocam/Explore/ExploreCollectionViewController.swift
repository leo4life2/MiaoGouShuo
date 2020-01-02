//
//  ExploreCollectionViewController.swift
//  Tolocam
//
//  Created by wyx on 2019/2/26.
//  Copyright © 2019年 leo. All rights reserved.
//

import UIKit
import MJRefresh

private let reuseIdentifier = "Cell"

class ExploreCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var dataArray: [Post] = [Post]()
    var page: Int = 1
    let pageSize: Int = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        loadData()
        self.collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.page = 1
            self?.loadData()
        })
        self.collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self?.loadData()
        })
    }

    func loadData() {
        let start = (page - 1) * pageSize
        let query = AVQuery(className: "Posts")
        query.limit = pageSize
        query.skip = start
        query.order(byDescending: "Likes")
        query.includeKey("postedBy")
        query.includeKey("Image")
        query.findObjectsInBackground({ (results, error) in
            self.collectionView.mj_header.endRefreshing()
            if error == nil {
                if let posts = results as? [AVObject], posts.count > 0 {
                    if self.page == 1 {
                        self.dataArray.removeAll()
                    }
                    for post in posts {
                        if post["Image"] == nil{
                            print("    CHECK THIS LOL NIL )")
                        }else{
                            let value = Post(post: post)
                            self.dataArray.append(value)
                        }
                    }
                    self.page += 1
                    self.collectionView?.reloadData()
                }
                self.collectionView.mj_footer.endRefreshing()
            } else {
                if error!.localizedDescription == "The Internet connection appears to be offline."{
                    TLAlertView.showAlert(title: "Error", message:"The Internet connection appears to be offline. Please try again later.", cancel: "OK")
                }
                self.collectionView.mj_footer.endRefreshing()
            }
            
        })
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ExploreCollectionViewCell
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    }
}
