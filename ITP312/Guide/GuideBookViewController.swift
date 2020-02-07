//
//  GuideBookViewController.swift
//  ITP312
//
//  Created by ITP312 on 7/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class GuideBookViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var bookTableView: UITableView!
    
    let cellID = "BookCell"
    var users:[User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference()
        ref.child("/user-guides/user-to-guide/").observeSingleEvent(of: .value, with: { (snapshot) in
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
                            self.bookTableView.reloadData()
                        }
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath)
        
        cell.textLabel?.text = users[indexPath.row].name
        
        return cell
    }
    

    
}
