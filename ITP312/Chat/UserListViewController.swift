//
//  UserListViewController.swift
//  ITP312
//
//  Created by ITP312 on 15/1/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class UserListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var users:[User] = []
    let cellID = "userCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        self.tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        self.tableView.rowHeight = 75.0
        self.tableView.delegate = self

        fetchUser()
        
    }
    
    func fetchUser() {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("user-guides").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                for i in dictionary {
                    let userID = i.value as! String
                    if userID == Auth.auth().currentUser!.uid {
                        ref.child("/users/\(i.key)").observeSingleEvent(of: .value) { (snapshot) in
                            if let dictionary = snapshot.value as? [String: AnyObject] {
                                let user = User(
                                    id: i.key,
                                    name: dictionary["name"]! as! String,
                                    email: dictionary["email"]! as! String,
                                    profileURL: dictionary["profileURL"]! as! String
                                )
                                self.users.append(user)
                            }
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
        let user = self.users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        if let profileImageUrl = user.profileURL {
            cell.profileImage.loadImageCache(urlString: profileImageUrl)
        }
        return cell
    }
    
    var messagesController: ChatMainViewController?
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true){
            print("Dismiss completed")
            let user = self.users[indexPath.row]
            self.messagesController?.showChatControllerForUser(user)
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
