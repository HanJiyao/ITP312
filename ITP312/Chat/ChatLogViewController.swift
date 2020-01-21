//
//  ChatLogViewController.swift
//  ITP312
//
//  Created by Han Jiyao on 17/1/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class ChatLogViewController: UIViewController
//UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var navigation: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    var user: User?
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if user != nil {
            self.navigation.title = user!.name
        }
        //self.tableView.delegate = self
    }
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        messages.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        <#code#>
//    }
    
    func observeMessages() {
        
    }
    
    @IBAction func handleSend(_ sender: Any) {
        let ref = Database.database().reference()
        let toID = Auth.auth().currentUser?.uid
        let fromID = user!.id
        let timestamp: NSNumber = NSNumber(value: Date().timeIntervalSince1970)
        let values = [
            "text": messageTextField.text!,
            "toID":toID!,
            "fromID":fromID!,
            "timestamp":timestamp
            ] as [String : Any]
        guard let key = ref.childByAutoId().key else { return }
        
        ref.child("messages").updateChildValues(["\(key)":values])
        ref.child("/user-messages/\(fromID!)/").updateChildValues(["\(key)":0])
        ref.child("/user-messages/\(toID!)/").updateChildValues(["\(key)":0])
        
        
    }
    @IBAction func handleBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
