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
    
    @IBOutlet weak var tableView: UITableView!
    
    var messages: [Message] = []
    
    var messageDictionary = [String: Message]()
    
    let cellID = "MessageCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        
        self.tableView.rowHeight = 80.0
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        
        setCurrentUser()
        
        observeMessage()
    }
    
    func setCurrentUser() {
        print("set up user")
        var ref: DatabaseReference!
        ref = Database.database().reference()
        guard let uid = Auth.auth().currentUser?.uid else {
            print("login fail")
            return
        }
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.navigationItem.title = dictionary["name"]! as? String
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        messages.removeAll()
        messageDictionary.removeAll()
        self.tableView.reloadData()
        
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
        
    }
    
    private func fetchMessageWithID(messageID: String) {
        let messageRef = Database.database().reference().child("messages").child(messageID)
        messageRef.observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(
                    fromID: dictionary["fromID"]! as! String,
                    toID: dictionary["toID"]! as! String,
                    timestamp: dictionary["timestamp"]! as! NSNumber,
                    text: dictionary["text"]! as! String
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
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
    }
    
    @objc func handleReload() {
        self.messages = Array(self.messageDictionary.values)
        self.messages.sort(by: {(message1: Message, message2: Message) -> Bool in
            message1.timestamp!.intValue > message2.timestamp!.intValue
        })
        self.tableView.reloadData()
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
        cell.textLabel?.text = message.text
        
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
    
}
