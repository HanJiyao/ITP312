//
//  GuideBookRequestViewController.swift
//  ITP312
//
//  Created by ITP312 on 7/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class GuideBookRequestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var bookTableView: UITableView!
    
    let cellID = "BookCell"
    var users:[User] = []
    var status:[Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookTableView.delegate = self
        bookTableView.layer.cornerRadius = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference()
        ref.child("user-guides").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.users.removeAll()
                self.status = []
                for i in dictionary {
                    let userID = i.value as! String
                    if userID == uid {
                        ref.child("/users/\(i.key)").observeSingleEvent(of: .value) { (snapshot) in
                            if let dictionary = snapshot.value as? [String: AnyObject] {
                                let user = User(
                                    id: i.key,
                                    name: dictionary["name"]! as! String,
                                    email: dictionary["email"]! as! String,
                                    profileURL: dictionary["profileURL"]! as! String
                                )
                                ref.child("/guides/\(i.key)").observe(.value) { (snapshot) in
                                    if let dictionary = snapshot.value as? [String: AnyObject] {
                                        print(dictionary)
                                        let offerID = dictionary["offerID"] as? String
                                        let booked = dictionary["booked"] as! Bool
                                        if offerID == uid {
                                            self.status.append(2)
                                        } else if offerID != uid && booked {
                                            self.status.append(1)
                                        } else {
                                            self.status.append(0)
                                        }
                                        self.users.append(user)
                                    }
                                    self.bookTableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        status.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath)
        
        cell.textLabel?.text = users[indexPath.row].name
        if status[indexPath.row] == 2 {
            cell.detailTextLabel?.text = "Accept"
            cell.detailTextLabel?.textColor = .systemGreen
        } else if status[indexPath.row] == 1 {
            cell.detailTextLabel?.text = "Pending"
            cell.detailTextLabel?.textColor = .orange
        } else if status[indexPath.row] == 0 {
            cell.detailTextLabel?.text = "Reject"
            cell.detailTextLabel?.textColor = .red
        }
        
        return cell
    }
    

    
}
