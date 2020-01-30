//
//  MainViewController.swift
//  ITP312
//
//  Created by ITP312 on 15/1/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var navigation: UINavigationItem!
    @IBOutlet weak var newMessageImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var messages: [Message] = []
    
    var messageDictionary = [String: Message]()
    
    let cellID = "MessageCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        newMessageImage.isUserInteractionEnabled = true
        newMessageImage.addGestureRecognizer(tapGestureRecognizer)
        
        self.tableView.rowHeight = 80.0
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        
        setCurrentUser()
        
        observeMessage()
    }
    
    func setCurrentUser() {
        print("set up user")
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(clickOnButton), for: .touchUpInside)
        self.navigation.titleView = button
        var ref: DatabaseReference!
        ref = Database.database().reference()
        guard let uid = Auth.auth().currentUser?.uid else {
            print("login fail")
            logout()
            return
        }
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                if self.navigation != nil {
                    button.setTitle(dictionary["name"]! as? String, for: .normal)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        messages.removeAll()
        messageDictionary.removeAll()
        self.tableView.reloadData()
        
        observeMessage()
    }
    
    func observeMessage() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let uidRef = Database.database().reference().child("user-messages").child(uid)
        
        uidRef.observe(.childAdded, with: {(snapshot) in
            let messageID = snapshot.key
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
                        self.messages = Array(self.messageDictionary.values)
                        self.messages.sort(by: {(message1: Message, message2: Message) -> Bool in
                            message1.timestamp!.intValue > message2.timestamp!.intValue
                        })
                    }
                    self.tableView.reloadData()
                }
            })
        })
        
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
    
    @objc func clickOnButton() {
        let chatLogViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatLog") as! ChatLogViewController
        present(chatLogViewController, animated: true, completion: nil)
    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let newMessageController = self.storyboard?.instantiateViewController(withIdentifier: "NewMessage") as! UserListViewController
        newMessageController.messagesController = self
        present(newMessageController, animated: true, completion: nil)
    }
    
    func showChatControllerForUser(_ user: User) {
        let chatLogViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatLog") as! ChatLogViewController
        chatLogViewController.user = user
        print("Chat to \(user)")
        present(chatLogViewController, animated: true)
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutErr {
            print(logoutErr)
        }
        let LoginViewController =  self.storyboard?.instantiateViewController(withIdentifier: "Login") as! LoginViewController
        LoginViewController.messagesController = self
        present(LoginViewController, animated: true, completion: nil)
    }
    

    @IBAction func handleLogout(_ sender: Any) {
        logout()
    }
    
}
