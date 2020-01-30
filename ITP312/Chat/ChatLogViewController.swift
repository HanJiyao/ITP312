//
//  ChatLogViewController.swift
//  ITP312
//
//  Created by Han Jiyao on 17/1/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class ChatLogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var navigation: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    var user: User?
    var messages: [Message] = []
    let cellID = "ChatLogCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if user != nil {
            self.navigation.title = user!.name
            observeMessages()
        }
        self.tableView.delegate = self
        tableView.register(ChatLogCell.self, forCellReuseIdentifier: cellID)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor.white
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ChatLogCell
        let message = messages[indexPath.section]
        cell.textView.text = message.text
        cell.bubbleWidthAnchor?.constant = estimateFrameText(text: message.text!).width + 25
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = 80
        
        //get estimated height dynamically
        if let text = messages[indexPath.section].text {
            height = estimateFrameText(text: text).height + 25
        }
        
        return height
    }
    
    private func estimateFrameText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 999)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let userMessageRef = Database.database().reference().child("user-messages").child(uid)
        userMessageRef.observe(.childAdded) { (snapshot) in
            let messageID = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageID)
            messageRef.observe(.value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                let message = Message(
                    fromID: dictionary["fromID"]! as! String,
                    toID: dictionary["toID"]! as! String,
                    timestamp: dictionary["timestamp"]! as! NSNumber,
                    text: dictionary["text"]! as! String
                )
                
                // check if the chatPartner of the selected user is the user passed from the parent
                // only display the message partnerID with the handled user
                
                if message.chatPartnerID() == self.user?.id {
                    self.messages.append(message)
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func sendMessage() {
        if self.messageTextField.text! != "" {
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
            guard let key = ref.childByAutoId().key else { return }
            
            ref.child("messages").updateChildValues(["\(key)":values])
            ref.child("/user-messages/\(fromID!)/").updateChildValues(["\(key)":0])
            ref.child("/user-messages/\(toID!)/").updateChildValues(["\(key)":0])
            
            self.messageTextField.text = nil
        }
    }
    
    @IBAction func handleSend(_ sender: Any) {
        sendMessage()
    }

    @IBAction func handleEnter(_ sender: Any) {
        sendMessage()
    }

    @IBAction func hey(_ sender: Any) {
        sendMessage()
    }
    
    @IBAction func handleBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
