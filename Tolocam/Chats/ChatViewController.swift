//
//  ChatViewController.swift
//  Tolocam
//
//  Created by wyx on 2019/3/4.
//  Copyright © 2019年 leo. All rights reserved.
//

import UIKit
import MessengerKit
import AVOSCloud
import AVOSCloudIM

class ChatViewController: MSGMessengerViewController {
    private var client = AVIMClient(clientId: AVUser.current()!.objectId!)
//    AVIMClient(user: AVUser.current()!)
    //好友
    private var other: ChatUser?
    //我
    private var me = ChatUser(displayName: AVUser.current()!.username!, avatar: nil, avatarUrl: nil, isSender: true, clientId: AVUser.current()?.objectId)
    var conversation: AVIMConversation?
    //好友对象
    var otherObject: User? {
        willSet {
            if let value = newValue {
                var imageUrl: URL? = nil
                if let str = value.profileIm, let url = URL(string: str) {
                    imageUrl = url
                }
                other = ChatUser(displayName: value.nickname!, avatar: nil, avatarUrl: imageUrl, isSender: false, clientId: value.objectId)
            }
        }
    }
    //消息列表
    var messages = [[MSGMessage]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.other?.displayName
        dataSource = self
        setupProfileBarButtonItem()
        loadMessage()
        collectionView.scrollToBottom(animated: false)
        self.client.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    private func setupProfileBarButtonItem() {
        if let imageUrl = other?.avatarUrl {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
            imageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
            imageView.layer.cornerRadius = imageView.bounds.width / 2
            imageView.layer.masksToBounds = true
            imageView.isUserInteractionEnabled = true
            imageView.backgroundColor = UIColor.lightGray
            imageView.contentMode = .scaleAspectFill
            //            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfile)))
            imageView.kf.setImage(with: imageUrl)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageView)
        } else {
            let profileItem = UIBarButtonItem(image: UIImage(named: "DefaultProfileImg"),
                                              style: UIBarButtonItem.Style.plain,
                                              target: self,
                                              action: nil)
            navigationItem.rightBarButtonItem = profileItem
        }
    }

    //MARK: 获取消息
    func loadMessage() {
        self.client.open { (success, error) in
            
            if success {
                guard let conversation = self.conversation else {
                    let query = self.client.conversationQuery()
                    query.whereKey("m", containsAllObjectsIn: [self.other!.clientId!, AVUser.current()!.objectId!])
                    query.findConversations(callback: { (conversations, error) in
                        if let conv = conversations?.first {
                            //如果有相同聊天对象的conversation，直接使用同一个，不创建新的
                            self.conversation = conv
                            self.getMessagesIn(conversation: conv)
                        }
                    })
                    return
                }
                self.getMessagesIn(conversation: conversation)
            }
        }
    }
    
    func getMessagesIn(conversation: AVIMConversation) {
        let query = self.client.conversationQuery()
        query.getConversationById(conversation.conversationId!, callback: { (c, error) in
            c?.queryMessages(withLimit: 10, callback: { (objects, error) in
                if let array = objects {
                    for item in array {
                        let user = self.me.clientId == item.clientId ? self.me : self.other
                        if let text = (item as! AVIMTypedMessage).text {
                            let message = MSGMessage(id: Int(item.sendTimestamp), body: MSGMessageBody.text(text), user: user!, sentAt: Date.getDateFrom(timestamp: Int(item.sendTimestamp)))
                            self.insert(message)
                        }
                    }
                }
                self.collectionView.reloadData()
            })
        })
    }
    
    //MARK: 发送消息
    override func inputViewPrimaryActionTriggered(inputView: MSGInputView) {
        guard let otherUser = otherObject else {
            return
        }
        self.client.open { (success, error) in
            //如果有针对相同的对象的conversation，则直接发送，否则创建新的
            if let conversation = self.conversation {
                self.sendMessage(inputMessage: inputView.message, conversation: conversation)
            } else {
                self.client.createConversation(withName: nil, clientIds: [otherUser.objectId!], callback: { (conversation, error) in
                    if error == nil {
                        self.sendMessage(inputMessage: inputView.message, conversation: conversation!)
                    }
                })
            }
        }
    }
    
    func sendMessage(inputMessage: String, conversation: AVIMConversation) {
        let message = AVIMTextMessage(text: inputMessage, attributes: nil)
        //                    let message = AVIMTextMessage(content: inputView.message)
        conversation.send(message, callback: { (success, error) in
            if success {
                //UI上展示消息
                let body: MSGMessageBody = (inputMessage.containsOnlyEmoji && inputMessage.count < 5) ? .emoji(inputMessage) : .text(inputMessage)
                
                let message = MSGMessage(id: 0, body: body, user: self.me, sentAt: Date())
                self.insert(message)
            } else {
                TLAlertView.showAlert(title: "发送失败", message: "消息发送失败，请稍后重试", cancel: "确定")
            }
        })
    }

    override func insert(_ message: MSGMessage) {

        collectionView.performBatchUpdates({
            if let lastSection = self.messages.last, let lastMessage = lastSection.last, lastMessage.user.displayName == message.user.displayName {
                self.messages[self.messages.count - 1].append(message)

                let sectionIndex = self.messages.count - 1
                let itemIndex = self.messages[sectionIndex].count - 1
                self.collectionView.insertItems(at: [IndexPath(item: itemIndex, section: sectionIndex)])

            } else {
                self.messages.append([message])
                let sectionIndex = self.messages.count - 1
                self.collectionView.insertSections([sectionIndex])
            }
        }, completion: { (_) in
            self.collectionView.scrollToBottom(animated: true)
            self.collectionView.layoutTypingLabelIfNeeded()
        })
    }

    override func insert(_ messages: [MSGMessage], callback: (() -> Void)? = nil) {

        collectionView.performBatchUpdates({
            for message in messages {
                if let lastSection = self.messages.last, let lastMessage = lastSection.last, lastMessage.user.displayName == message.user.displayName {
                    self.messages[self.messages.count - 1].append(message)

                    let sectionIndex = self.messages.count - 1
                    let itemIndex = self.messages[sectionIndex].count - 1
                    self.collectionView.insertItems(at: [IndexPath(item: itemIndex, section: sectionIndex)])

                } else {
                    self.messages.append([message])
                    let sectionIndex = self.messages.count - 1
                    self.collectionView.insertSections([sectionIndex])
                }
            }
        }, completion: { (_) in
            self.collectionView.scrollToBottom(animated: false)
            self.collectionView.layoutTypingLabelIfNeeded()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                callback?()
            }
        })
    }

}

//MARK: MSGDataSource
extension ChatViewController: MSGDataSource {

    func numberOfSections() -> Int {
        return messages.count
    }

    func numberOfMessages(in section: Int) -> Int {
        return messages[section].count
    }

    func message(for indexPath: IndexPath) -> MSGMessage {
        return messages[indexPath.section][indexPath.item]
    }

    func footerTitle(for section: Int) -> String? {
        if let date = messages[section].last?.sentAt {
            return date.getFormatString()
        } else {
            return nil
        }
    }

    func headerTitle(for section: Int) -> String? {
        return messages[section].last?.user.displayName
    }

}

struct ChatUser: MSGUser {

    var displayName: String

    var avatar: UIImage?

    var avatarUrl: URL?

    var isSender: Bool
    
    var clientId: String?

}

//MARK: AVIMClientDelegate
extension ChatViewController: AVIMClientDelegate {
    func imClientPaused(_ imClient: AVIMClient) {
        
    }
    
    func imClientResuming(_ imClient: AVIMClient) {
        
    }
    
    func imClientResumed(_ imClient: AVIMClient) {
        
    }
    
    func imClientClosed(_ imClient: AVIMClient, error: Error?) {
        
    }
    
    func conversation(_ conversation: AVIMConversation, didReceive message: AVIMTypedMessage) {
        conversation.readInBackground()
        if message.clientId == self.other?.clientId {
            if let text = message.text {
                let m = MSGMessage(id: Int(message.sendTimestamp), body: MSGMessageBody.text(text), user: self.other!, sentAt: Date.getDateFrom(timestamp: Int(message.sendTimestamp)))
                self.insert(m)
                self.collectionView.reloadData()
            }
        }
    }
}

//MARK: SBDChannelDelegate
//extension ChatViewController: SBDChannelDelegate {
//    //收到消息
//    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
//        if message is SBDUserMessage {
//            let item = message as! SBDUserMessage
//            if let body = item.message, let userName = item.sender?.nickname, let user = userName == me.displayName ? me : other {
//                let message = MSGMessage(id: Int(item.messageId), body: MSGMessageBody.text(body), user: user, sentAt: Date(timeIntervalSince1970: TimeInterval(item.createdAt)))
//                messages.append([message])
//            }
//            self.collectionView.reloadData()
//            collectionView.scrollToBottom(animated: false)
//
//            //数据库存储消息
//            let realm = try! Realm()
//            let rmMessage = RealmMessage()
//            rmMessage.id = "\(item.messageId)"
//            rmMessage.channelUrl = self.channel?.channelUrl
//            rmMessage.message = item.message
//            rmMessage.user = other?.displayName
//            rmMessage.type = "MESG"
//            //            rmMessage.createdAt = Date(timeIntervalSince1970: TimeInterval(item.createdAt/1000))
//
//            if let conversation = self.currentRmConversation {
//
//                try! realm.write {
//                    realm.add(rmMessage)
//                    conversation.messages.append(rmMessage)
//                    realm.add(conversation, update: true)
//                }
//            }
//        }
//    }
//}
