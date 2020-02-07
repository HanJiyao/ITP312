//
//  ChatLogViewController.swift
//  ITP312
//
//  Created by Han Jiyao on 17/1/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class ChatLogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomBar: UIStackView!
    @IBOutlet weak var sendImageViewButton: UIImageView!
    
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
        tabBarController?.tabBar.isHidden = true
        
        sendImageViewButton.isUserInteractionEnabled = true
        sendImageViewButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSendImageTap)))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleSendImageTap () {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
            picker.dismiss(animated: true, completion: nil)
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
            picker.dismiss(animated: true, completion: nil)
        }
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorage(image: selectedImage)
        }
    }
    
    func uploadToFirebaseStorage(image: UIImage){
        let imageName = NSUUID().uuidString
        let data = image.jpegData(compressionQuality: 0.3)
        let storageRef = Storage.storage().reference().child("message").child(imageName)
        storageRef.putData(data!, metadata: nil) { (metadata, error) in
            storageRef.downloadURL { (url, error) in
                if let imageURL = url?.absoluteString {
                    let ref = Database.database().reference()
                    let toID = self.user!.id
                    let fromID = Auth.auth().currentUser?.uid
                    let timestamp: NSNumber = NSNumber(value: Date().timeIntervalSince1970)
                    let values = [
                        "toID":toID!,
                        "fromID":fromID!,
                        "timestamp":timestamp,
                        "imageURL": imageURL,
                        "imageHeight": image.size.height,
                        "imageWidth": image.size.width
                        ] as [String : Any]
                    guard let key = ref.childByAutoId().key else { return }
                    
                    ref.child("messages").updateChildValues(["\(key)":values])
                    ref.child("/user-messages/\(fromID!)/\(toID!)/").updateChildValues(["\(key)":0])
                    ref.child("/user-messages/\(toID!)/\(fromID!)/").updateChildValues(["\(key)":0])
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
        let indexPath = IndexPath(item: 0, section: self.messages.count - 1)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
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
        if message.text != nil {
            cell.bubbleWidthAnchor?.constant = estimateFrameText(text: message.text!).width + 25
        } else if message.imageURL != nil {
            // in here mean image message
            cell.bubbleWidthAnchor?.constant = 200
        }
        return cell
        
    }
    
    private func setUpCell(cell: ChatLogCell, message: Message) {
        
        if let profileImageURL = self.user?.profileURL {
            cell.profileImage.loadImageCache(urlString: profileImageURL)
        }
        if message.text != nil {
            if message.fromID == Auth.auth().currentUser?.uid {
                // the message from the user
                cell.bubbleView.image = nil
                cell.bubbleView.backgroundColor = ChatLogCell.blueColor
                cell.textView.textColor = UIColor.white
                cell.profileImage.isHidden = true
                cell.bubbleViewRightAnchor?.isActive = true
                cell.bubbleViewLeftAnchor?.isActive = false
                cell.bubbleView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner,]
            } else {
                cell.bubbleView.image = nil
                cell.bubbleView.backgroundColor = UIColor.init(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
                cell.textView.textColor = UIColor.black
                cell.profileImage.isHidden = false
                cell.bubbleViewRightAnchor?.isActive = false
                cell.bubbleViewLeftAnchor?.isActive = true
                cell.bubbleView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner,]
            }
        } else if message.imageURL != nil {
            cell.bubbleView.loadImageCache(urlString: message.imageURL!)
            // cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
            if message.fromID == Auth.auth().currentUser?.uid {
                cell.profileImage.isHidden = true
                cell.bubbleViewRightAnchor?.isActive = true
                cell.bubbleViewLeftAnchor?.isActive = false
            } else {
                cell.profileImage.isHidden = false
                cell.bubbleViewRightAnchor?.isActive = false
                cell.bubbleViewLeftAnchor?.isActive = true
            }
        }
//        } else {
//            // cell.messageImageView.isHidden = true
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = 80
        
        //get estimated height dynamically
        let message = messages[indexPath.section]
        if let text = message.text {
            height = estimateFrameText(text: text).height + 25
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            // h1 / w1 = h2 / w2 where two recangle is proportional relationed
            // solve for h1 = h2 / w2 * w1
            height = CGFloat(imageHeight / imageWidth * 200)
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
                    dictionary: dictionary
                )
                
                // check if the chatPartner of the selected user is the user passed from the parent
                // only display the message partnerID with the handled user
                
                self.messages.append(message)
                self.tableView.reloadData()
                
                //scroll to the last index
                let indexPath = IndexPath(item: 0, section: self.messages.count - 1)
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
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
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
