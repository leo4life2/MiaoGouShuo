//
//  LikerTableViewController.swift
//  ToloCam
//
//  Created by wyx on 10/03/2019.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import AVOSCloud
import MJRefresh

class LikerTableViewController: UITableViewController {
    
//    var dictionaryOfLikers = NSMutableDictionary()
    var likers = [Like]()
    var likersLeaderboard = [(String,Bool,Int,AVObject,String)]()
    var tempArray = [(name: String, likes: Int)]()
    var page: Int = 1
    let pageSize: Int = 5
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.tableView.tableFooterView = UIView()
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self?.loadData()
        })
        
//        for pair in dictionaryOfLikers {
//            let item = (name: pair.0 as! String, likes: pair.1 as! Int)
//            tempArray.append(item)
//        }
        for pair in likers {
            let item = (name: pair.from?.username as! String, likes: pair.likeNumber as! Int)
            tempArray.append(item)
        }
        
        tempArray = tempArray.sorted(by: { (obj1, obj2) -> Bool in
            return obj1.likes > obj2.likes
        })
        
        loadData()
    }
    
    func loadData() {
        let myGroup = DispatchGroup()
        let start = (page - 1) * pageSize
        let end = tempArray.count > page * pageSize ? page * pageSize - 1 : tempArray.count - 1
        if start > end {
            self.tableView.mj_footer.endRefreshing()
            return
        }
        for index in start...end {
            myGroup.enter()
            let query = AVQuery(className: "_User")
            query.whereKey("username", equalTo: tempArray[index].name)
            query.getFirstObjectInBackground({ (queryResult, error) in
                if error == nil{
                    let followQuery = AVQuery(className: "Follow")
                    followQuery.whereKey("followFrom", equalTo:AVUser.current()!)
                    followQuery.whereKey("followingTo", equalTo:queryResult!)
                    followQuery.getFirstObjectInBackground({ (followQueryResult, error) in
                        if error == nil{
                            let pairOfLikerLikes = (queryResult!["nickname"] as! String, true, self.tempArray[index].likes, queryResult!,followQueryResult!.objectId!)
                            self.likersLeaderboard.append(pairOfLikerLikes)
                            myGroup.leave()
                        }else{
                            let pairOfLikerLikes = (queryResult!["nickname"] as! String,false, self.tempArray[index].likes, queryResult!, "")
                            self.likersLeaderboard.append(pairOfLikerLikes)
                            myGroup.leave()
                        }
                    })
                }else{
                    print(error!.localizedDescription)
                    myGroup.leave()
                }
            })
        }
        myGroup.notify(queue: .main) {
            self.likersLeaderboard = self.likersLeaderboard.sorted(by: { (obj1, obj2) -> Bool in
                return obj1.2 > obj2.2
            })
            self.page += 1
            self.tableView.reloadData()
            self.tableView.mj_footer.endRefreshing()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likersLeaderboard.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "likerCell", for: indexPath) as! LikerTableViewCell
        
        switch indexPath.row{
        case 0:
            cell.crownImageView.image = UIImage(named: "winnerCrown")
            cell.crownImageView.isHidden = false
            cell.likerRankLabel.isHidden = true
        case 1:
            cell.crownImageView.image = UIImage(named: "crownSilver")
            cell.crownImageView.isHidden = false
            cell.likerRankLabel.isHidden = true
        case 2:
            cell.crownImageView.image = UIImage(named: "crownBronze")
            cell.crownImageView.isHidden = false
            cell.likerRankLabel.isHidden = true
        default:
            cell.crownImageView.isHidden = true
            cell.likerRankLabel.isHidden = false
            cell.likerRankLabel.text = String(indexPath.row+1)
        }
        
        let person = self.likersLeaderboard[indexPath.row]
        let name = person.0
        cell.followButton.isHidden = false
        if name == AVUser.current()?.value(forKey: "username") as! String{
            cell.followButton.isHidden = true
        }else if person.1 == true{
            //following
            cell.followButton.setTitle("取消关注", for: .normal)
            cell.followButton.layer.backgroundColor = UIColor(red: 93/255, green: 215/255, blue: 217/255, alpha: 1).cgColor
        }else{
            cell.followButton.setTitle("关注", for: .normal)
            cell.followButton.layer.backgroundColor = UIColor(red: 252/255, green: 105/255, blue: 134/255, alpha: 1).cgColor
        }
        let likes = person.2
        
        cell.likeName.text = name
        cell.likes.text = String(likes)
        cell.userObject = person.3
        cell.followButton.tag = indexPath.row
        cell.followObjectId = person.4
        
        if let profileImg = person.3["profileIm"] as? AVFile{
            profileImg.getDataInBackground({ (data, error) in
                if error == nil{
                    cell.likerProfileImageView.image = UIImage(data: data!)
                }else{
                    print(error?.localizedDescription)
                }
            })
        }else{
            cell.likerProfileImageView.image = #imageLiteral(resourceName: "gray")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! LikerTableViewCell
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.user = self.likersLeaderboard[indexPath.row].3 as! AVUser
        vc.isOther = true
        if cell.likeName.text == AVUser.current()?.value(forKey: "nickname") as! String{
            self.tabBarController?.selectedIndex = 4
        }else{
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
