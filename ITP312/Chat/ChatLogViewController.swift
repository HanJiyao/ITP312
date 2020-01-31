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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomBar: UIStackView!
    
    var user: User?
    var messages: [Message] = []
    let cellID = "ChatLogCell"
    
    var bottomBarBottomAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if user != nil {
            self.navigationItem.title = user!.name
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            observeMessages()
        }
        self.tableView.delegate = self
        tableView.register(ChatLogCell.self, forCellReuseIdentifier: cellID)
        
        setUpKeyboardObservers()
        
        bottomBarBottomAnchor =  bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomBarBottomAnchor?.isActive = true
        
        tableView.keyboardDismissMode = .interactive
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setUpKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardShow(notification: NSNotification){
        // get keyboard height
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            bottomBarBottomAnchor?.constant = -keyboardHeight
        }
        if let keyboardDuration: Double = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            UIView.animate(withDuration: keyboardDuration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func handleKeyboardHide(notification: NSNotification){
        bottomBarBottomAnchor?.constant = 0
        if let keyboardDuration: Double = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            UIView.animate(withDuration: keyboardDuration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // add space between cell
    func numberOfSections(in tableView: UITableView) -> Int {
        return messages.count
    }
    
    // change section header color white
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor.white
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ChatLogCell
        let message = messages[indexPath.section]
        cell.textView.text = message.text
        
        setUpCell(cell: cell, message: message)
        
        cell.bubbleWidthAnchor?.constant = estimateFrameText(text: message.text!).width + 25
        return cell
        
    }
    
    private func setUpCell(cell: ChatLogCell, message: Message) {
        
        if let profileImageURL = self.user?.profileURL {
            cell.profileImage.loadImageCache(urlString: profileImageURL)
        }
        
        if message.fromID == Auth.auth().currentUser?.uid {
            // the message from the user
            cell.bubbleView.backgroundColor = ChatLogCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImage.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            cell.bubbleView.backgroundColor = UIColor.init(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
            cell.textView.textColor = UIColor.black
            cell.profileImage.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
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
        
        // need to append both the logged in user id and the partner id which passed from the user
        
        guard let uid = Auth.auth().currentUser?.uid, let toID = user?.id else {
            return
        }
        let userMessageRef = Database.database().reference().child("user-messages").child(uid).child(toID)
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
                
                self.messages.append(message)
                self.tableView.reloadData()
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
            
            // the structure of the user-message is to store the message relationship
            // that the message id is stored under both sender and receiver that can easily filtered and retrive later
            
            ref.child("messages").updateChildValues(["\(key)":values])
            ref.child("/user-messages/\(fromID!)/\(toID!)/").updateChildValues(["\(key)":0])
            ref.child("/user-messages/\(toID!)/\(fromID!)/").updateChildValues(["\(key)":0])
            
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
}
