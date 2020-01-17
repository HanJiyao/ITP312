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
        
        self.tableView.rowHeight = 80.0
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        
        observeMessage()
    }
    
    func observeMessage() {
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded)
                     { (snapshot, key) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
            let message = Message(
                fromID: dictionary["fromID"]! as! String,
                toID: dictionary["toID"]! as! String,
                timestamp: dictionary["timestamp"]! as! NSNumber,
                text: dictionary["text"]! as! String
            )
            
            if let toID = message.toID {
                self.messageDictionary[toID] = message
                self.messages = Array(self.messageDictionary.values)
                self.messages.sort(by: {(message1: Message, message2: Message) -> Bool in
                    message1.timestamp!.intValue > message2.timestamp!.intValue
                })
            }
            self.tableView.reloadData()
            }
        }
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
    
    @objc func clickOnButton() {
        let chatLogViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatLog") as! ChatLogViewController
        present(chatLogViewController, animated: true, completion: nil)
    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let userListViewController = self.storyboard?.instantiateViewController(withIdentifier: "NewMessage") as! UserListViewController
        present(userListViewController, animated: true, completion: nil)
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutErr {
            print(logoutErr)
        }
        let LoginViewController =  self.storyboard?.instantiateViewController(withIdentifier: "Login") as! LoginViewController
        present(LoginViewController, animated: true, completion: nil)
    }
    

    @IBAction func handleLogout(_ sender: Any) {
        logout()
    }
    
}
