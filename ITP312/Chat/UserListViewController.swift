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
            
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        self.tableView.rowHeight = 75.0
        self.tableView.delegate = self

        fetchUser()
        
    }
    
    func fetchUser() {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                for i in dictionary {
                    self.users.append(User(
                        id: i.key,
                        name: i.value["name"]!! as! String,
                        email: i.value["email"]!! as! String,
                        profileURL: i.value["profileURL"]!! as! String
                    ))
                }
                self.tableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.users[indexPath.row]
        let chatLogViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatLog") as! ChatLogViewController
        chatLogViewController.user = user
        present(chatLogViewController, animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
