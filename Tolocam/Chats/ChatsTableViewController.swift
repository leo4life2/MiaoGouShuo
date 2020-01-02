//
//  ChatsTableViewController.swift
//  Tolocam
//
//  Created by wyx on 2019/3/4.
//  Copyright © 2019年 leo. All rights reserved.
//

import UIKit
import AVOSCloudIM

class ChatsTableViewController: UITableViewController {

    public var client: AVIMClient?
    var conversations = [TLConversation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        
        // Add refresh with MJRefresh
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadConversationList()
    }
    
    func loadConversationList() {
        self.client = AVIMClient(clientId: AVUser.current()!.objectId!)
//            AVIMClient(user: AVUser.current()!)
        self.client?.open(callback: { (success, error) in
            let query = self.client?.conversationQuery()
            query?.findConversations(callback: { (avimConversations, error) in
                if error == nil {
                    if let array = avimConversations {
                        self.conversations.removeAll()
                        for item in array {
                            let object = TLConversation(object: item)
                            self.conversations.append(object)
                        }
                        self.tableView.reloadData()
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.conversations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsTableViewCell", for: indexPath) as! ChatsTableViewCell
        let conversation = conversations[indexPath.row]
        cell.nameLabel.text = conversation.name
        cell.messageLabel.text = conversation.lastMessage
        cell.dateLabel.text = conversation.dateStr
        if let url = conversation.imageUrl {
            cell.profileImageView.kf.setImage(with: URL(string: url))
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "showChatSegue", sender: conversations[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChatSegue", let c = sender as? TLConversation {
            let vc = segue.destination as! ChatViewController
            vc.otherObject = c.other
            vc.conversation = c.object
        }
    }
    
    @objc func __refresh(){
        self.conversations = []
        loadConversationList()
        self.tableView?.reloadData()
//        let tabItems = self.tabBarController!.tabBar.items!
//        let tabItem = tabItems[3]
//        let unreadMessages = Array(manager.userAndUnreadMessagesCount.values).reduce(0, +)
//        tabItem.badgeValue = unreadMessages != 0 ? String(unreadMessages) : nil
//        UIApplication.shared.applicationIconBadgeNumber = unreadMessages
        self.refreshControl?.endRefreshing()
    }

}

struct TLConversation {
    var object: AVIMConversation?
    var name: String?
    var imageUrl: String?
    var dateStr: String?
    var lastMessage: String?
    var other: User?
    
    init(object: AVIMConversation) {
        self.object = object
        if let array = object.members {
            for item in array {
                if item != AVUser.current()?.objectId {
                    let query = AVQuery(className: "_User")
                    if let user = query.getObjectWithId(item) {
                        name = user["nickname"] as? String
                        if let imageFile = user["profileIm"] as? AVFile {
                            imageUrl = imageFile.url()
                        }
                        other = User(user: user)
                    }                   
                    dateStr = object.updateAt?.getFormatString()
//                    lastMessage = object.lastMessage?.content
                }
            }
        }
    }
}
