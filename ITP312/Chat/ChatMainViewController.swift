//
//  MainViewController.swift
//  ITP312
//
//  Created by ITP312 on 15/1/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class ChatMainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var messages: [Message] = []
    var messageDictionary = [String: Message]()
    let cellID = "MessageCell"
    
    @IBOutlet weak var messageTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTableView.delegate = self
        messageTableView.rowHeight = 80.0
        messageTableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        messageTableView.allowsMultipleSelectionDuringEditing = true
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let message = self.messages[indexPath.row]
        if let chatPartnerID = message.chatPartnerID() {
            Database.database().reference().child("user-messages/\(uid)/\(chatPartnerID)/").removeValue { (err, ref) in
                if err != nil {
                    print("fail to delete message:", err!)
                }
                //delete message with chatPartnerID
                self.messageDictionary.removeValue(forKey: chatPartnerID)
                self.attemptReload()
//
//                self.messages.remove(at: indexPath.row)
//                self.messageTableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        setCurrentUser()
    }
    
    func setCurrentUser() {
        //refresh the data base on new login/registeer
        messages.removeAll()
        messageDictionary.removeAll()
        messageTableView.reloadData()
        observeMessage()
    }
    
    var timer: Timer?
    
    func observeMessage() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let uidRef = Database.database().reference().child("user-messages").child(uid)
        
        uidRef.observe(.childAdded, with: {(snapshot) in
            
            let userID = snapshot.key
            
            Database.database().reference().child("user-messages").child(uid).child(userID).observe(.childAdded, with: { (snapshot) in
                let messageID = snapshot.key
                self.fetchMessageWithID(messageID: messageID)
            })
        })
        
        uidRef.observe(.childRemoved) { (snapshot) in
            self.messageDictionary.removeValue(forKey: snapshot.key)
            self.attemptReload()
        }
        
    }
    
    private func fetchMessageWithID(messageID: String) {
        let messageRef = Database.database().reference().child("messages").child(messageID)
        messageRef.observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(
                    dictionary: dictionary
                )
                
                if let chatPartnerID = message.chatPartnerID() {
                    self.messageDictionary[chatPartnerID] = message
                }
                self.attemptReload()
            }
        })
    }
    
    private func attemptReload() {
        
        // some delay to wait loaded and triger reload only once
        // if the observer still change within 0.1 seconds the timer will invalidate and will not reload
        // untill there is no change reload the entire data table
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
    }
    
    @objc func handleReload() {
        self.messages = Array(self.messageDictionary.values)
        self.messages.sort(by: {(message1: Message, message2: Message) -> Bool in
            message1.timestamp!.intValue > message2.timestamp!.intValue
        })
        messageTableView.reloadData()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        
        cell.message = message
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard let chatPartnerID = message.chatPartnerID() else {
            return
        }
        let ref = Database.database().reference().child("/users/\(chatPartnerID)/")
        ref.observe(.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            let user = User(
                id: chatPartnerID,
                name: dictionary["name"]! as! String,
                email: dictionary["email"]! as! String,
                profileURL: dictionary["profileURL"]! as! String
            )
            self.showChatControllerForUser(user)
        })
    }
    
    @IBAction func compose(_ sender: Any) {
        let newMessageController = self.storyboard?.instantiateViewController(withIdentifier: "NewMessage") as! UserListViewController
        newMessageController.messagesController = self
        present(newMessageController, animated: true, completion: nil)
    }

    func showChatControllerForUser(_ user: User) {
        let chatLogViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatLog") as! ChatLogViewController
        chatLogViewController.user = user
        print("Chat to \(user)")
        self.navigationController?.pushViewController(chatLogViewController, animated: true)
    }
    
    @IBAction func handleDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
