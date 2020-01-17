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
        let toID = user!.id
        let fromID = Auth.auth().currentUser?.uid
        let timestamp: NSNumber = NSNumber(value: Date().timeIntervalSince1970)
        let values = [
            "text": messageTextField.text!,
            "toID":toID!,
            "fromID":fromID!,
            "timestamp":timestamp
            ] as [String : Any]
        guard let key = ref.child("messages").childByAutoId().key else { return }
        let childUpdates = ["/messages/\(key)": values,
                            "/user-messages/\(fromID!)/": ["\(key)":0],
                            "/user-messages/\(toID!)/": ["\(key)":0]
            ] as [String : Any]
        ref.updateChildValues(childUpdates)
//        childRef.updateChildValues(values) {
//            (error, ref) in
//            if error != nil {
//                print(error!)
//                return
//            }
//            let userMessageRef = Database.database().reference().child("user-messages")
//            let messageID = childRef.key
//            userMessageRef.child(fromID!).updateChildValues([messageID: 1]) {
//                (error:Error?, ref:DatabaseReference) in
//                if let error = error {
//                  print("Data could not be saved: \(error).")
//                } else {
//                  print("Data saved successfully in user ref")
//                }
//            }
//
//            userMessageRef.child(toID!).updateChildValues([messageID: 1]){
//                (error:Error?, ref:DatabaseReference) in
//                if let error = error {
//                  print("Data could not be saved: \(error).")
//                } else {
//                  print("Data saved successfully in recipient ref")
//                }
//            }
//        }
        
    }
    @IBAction func handleBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
