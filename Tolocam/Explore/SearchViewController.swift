//
//  SearchViewController.swift
//  Tolocam
//
//  Created by wyx on 2019/2/27.
//  Copyright © 2019年 leo. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var dataArray = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        setupTableView()
    }
    
    func setupSearchBar() {
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
        searchBar.backgroundImage = UIColor.white.toImage()
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor(red: 226/255, green: 226/255, blue: 226/255, alpha: 1)
    }
    
    func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.isHidden = true
    }

    func loadData (){        
        let query = AVQuery(className: "_User")
        let nicknameQuery = AVQuery(className: "_User")
        if searchBar.text != "" {
            query.whereKey("username", hasPrefix: searchBar.text!.lowercased())
            query.whereKey("username", notEqualTo: AVUser.current()!.username!)
            nicknameQuery.whereKey("nickname", hasPrefix: searchBar.text!.lowercased())
            nicknameQuery.whereKey("nickname", notEqualTo: AVUser.current()!.value(forKey: "nickname") as! String)
        }else{
            query.whereKey("username", equalTo: "")
            nicknameQuery.whereKey("nickname", equalTo: "")
        }
        query.order(byAscending: "username")
        
        let orQuery = AVQuery.orQuery(withSubqueries: [query, nicknameQuery])
        orQuery.findObjectsInBackground({ (results, error) in
            if error == nil{
                self.dataArray.removeAll()
                if let usernames = results as? [AVObject], usernames.count > 0 {
                    for item in usernames{
                        let user = User(user: item)
                        self.dataArray.append(user)
                    }
                    self.tableView.isHidden = false
                }else{
                    print("no results!!!!")
                    self.tableView.isHidden = true
                }
                self.tableView.reloadData()
            } else {
                if error!.localizedDescription == "The Internet connection appears to be offline."{
                    TLAlertView.showAlert(title: "Error", message:"The Internet connection appears to be offline. Please try again later.", cancel: "OK")
                }
            }
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count  
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") as! SearchTableViewCell
        let model = dataArray[indexPath.row]
        if let str = model.profileIm, let url = URL(string: str) {
            cell.profileImageView.kf.setImage(with: url)
        }
        cell.nameLabel.text = model.nickname
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "用户"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataArray[indexPath.row]
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.isOther = true
        vc.user = model.object as! AVUser
        
        if model.nickname != (AVUser.current()?.value(forKey: "nickname") as! String){
            self.navigationController!.pushViewController(vc, animated: true)
        }else{
            //user tapped on own username
            self.tabBarController?.selectedIndex = 4
        }
        
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.loadData()
    }
}
