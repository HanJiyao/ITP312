//
//  ChatLogViewController.swift
//  ITP312
//
//  Created by Han Jiyao on 17/1/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase
import DropDown

class ChatLogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomBar: UIStackView!
    @IBOutlet weak var sendImageViewButton: UIImageView!
    @IBOutlet weak var fromLanguage: UIButton!
    @IBOutlet weak var toLanguage: UIButton!
    @IBOutlet weak var translationSwitch: UISwitch!
    @IBOutlet weak var topBar: UIStackView!
    @IBOutlet weak var smartReplyBtn: UIButton!
    @IBOutlet weak var replyBtn1: UIButton!
    @IBOutlet weak var replyBtn2: UIButton!
    @IBOutlet weak var replyBtn3: UIButton!
    
    
    var user: User?
    var messages: [Message] = []
    let cellID = "ChatLogCell"
    
    var conversation: [TextMessage] = []
    
    var bottomBarBottomAnchor: NSLayoutConstraint?
    let dropDown1 = DropDown()
    let dropDown2 = DropDown()
    let englishChineseTranslator = NaturalLanguage.naturalLanguage().translator(options:
        TranslatorOptions(sourceLanguage: .en, targetLanguage: .zh)
    )
    let chineseEnglishTranslator = NaturalLanguage.naturalLanguage().translator(options:
        TranslatorOptions(sourceLanguage: .zh, targetLanguage: .en)
    )
    let englishGermanyTranslator = NaturalLanguage.naturalLanguage().translator(options:
        TranslatorOptions(sourceLanguage: .en, targetLanguage: .de)
    )
    let germanyEnglishTranslator = NaturalLanguage.naturalLanguage().translator(options:
        TranslatorOptions(sourceLanguage: .de, targetLanguage: .en)
    )
    let japEngTranslator = NaturalLanguage.naturalLanguage().translator(options:
        TranslatorOptions(sourceLanguage: .ja, targetLanguage: .en)
    )
    let engJapTranslator = NaturalLanguage.naturalLanguage().translator(options:
        TranslatorOptions(sourceLanguage: .en, targetLanguage: .ja)
    )
    let malayEngTranslator = NaturalLanguage.naturalLanguage().translator(options:
    TranslatorOptions(sourceLanguage: .ms, targetLanguage: .en)
    )
    let engMalayTranslator = NaturalLanguage.naturalLanguage().translator(options:
    TranslatorOptions(sourceLanguage: .en, targetLanguage: .ms)
    )
    let russEngTranslator = NaturalLanguage.naturalLanguage().translator(options:
    TranslatorOptions(sourceLanguage: .ru, targetLanguage: .en)
    )
    let engRussTranslator = NaturalLanguage.naturalLanguage().translator(options:
        TranslatorOptions(sourceLanguage: .en, targetLanguage:.ru)
    )
    
    var translation = false
    
    lazy var vision = Vision.vision()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if user != nil {
            self.navigationItem.title = user!.name
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.replyBtn1.addTarget(self, action: #selector(self.selectReply), for: .touchDown)
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
        
        
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: false,
            allowsBackgroundDownloading: true
        )
        
        translationSwitch.isOn = false
        
        englishChineseTranslator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
        }
        chineseEnglishTranslator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
        }
        engJapTranslator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
        }
        japEngTranslator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
        }
        germanyEnglishTranslator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
        }
        englishGermanyTranslator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
        }
        russEngTranslator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
        }
        engRussTranslator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
        }
        malayEngTranslator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
        }
        engMalayTranslator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
        }
        
        topBar.layer.borderColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.05).cgColor
        topBar.layer.borderWidth = 1
        
        dropDown1.anchorView = fromLanguage
        // UIView or UIBarButtonItem
        dropDown1.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            // Setup your custom UI components
            cell.optionLabel.textAlignment = .center
        }
        // The list of items to display. Can be changed dynamically
        dropDown1.dataSource = ["English", "Chinese", "Japnese", "Germany", "Russian"]
        dropDown1.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.fromLanguage.setTitle(item, for: .normal)
            self.handleTranslate(language: item)
        }
//        dropDown2.anchorView = toLanguage
//        // UIView or UIBarButtonItem
//        dropDown2.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
//           // Setup your custom UI components
//           cell.optionLabel.textAlignment = .center
//        }
//        // The list of items to display. Can be changed dynamically
//        dropDown2.dataSource = ["English", "Chinese", "Japnese", "Germany", "Russian"]
//        dropDown2.selectionAction = { [unowned self] (index: Int, item: String) in
//           print("Selected item: \(item) at index: \(index)")
//           self.toLanguage.setTitle(item, for: .normal)
//        }
        
        
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
        
        let createStorage = StorageMetadata()
        let createCustom = [
            "imageHeight": "\(image.size.height)",
            "imageWidth": "\(image.size.width)"
        ]
        createStorage.customMetadata = createCustom
        
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
                    
                    let options = VisionCloudDetectorOptions()
                    options.modelType = .latest
                    options.maxResults = 2
                    let cloudDetector = self.vision.cloudLandmarkDetector(options: options)
                        let visionImage = VisionImage(image: image)
                        cloudDetector.detect(in: visionImage) { landmarks, error in
                          guard error == nil, let landmarks = landmarks, !landmarks.isEmpty else {
                            print(error)
                            return
                          }

                          for landmark in landmarks {
            //                let landmarkDesc = landmark.landmark
            //                let boundingPoly = landmark.frame
            //                let entityId = landmark.entityId

                            // A landmark can have multiple locations: for example, the location the image
                            // was taken, and the location of the landmark depicted.
                            for location in landmark.locations! {
                                print(landmark.landmark)
                                
                            }
                            
                            self.replyBtn1.setTitle(landmarks[0].landmark, for: .normal)

                           // let confidence = landmark.confidence
                        }
                    }
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
//             cell.messageImageView.isHidden = true
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
                
                // Then, for each message sent and received:
                if message.text != nil {
                    let MLmessage = TextMessage(
                        text: message.text!,
                        timestamp: TimeInterval(truncating: message.timestamp!),
                        userID: message.fromID!,
                        isLocalUser: true)
                    self.conversation.append(MLmessage)
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
            
            // the structure of the user-message is to store the message relationship
            // that the message id is stored under both sender and receiver that can easily filtered and retrive later
            
            ref.child("messages").updateChildValues(["\(key)":values])
            ref.child("/user-messages/\(fromID!)/\(toID!)/").updateChildValues(["\(key)":0])
            ref.child("/user-messages/\(toID!)/\(fromID!)/").updateChildValues(["\(key)":0])
            
            self.messageTextField.text = nil
        }
    }
    
    func handleTranslate(language: String) {
//        guard let uid = Auth.auth().currentUser?.uid, let toID = user?.id else {
//            return
//        }
//        self.messages = []
//        let userMessageRef = Database.database().reference().child("user-messages").child(uid).child(toID)
//        userMessageRef.observe(.childAdded) { (snapshot) in
//            let messageID = snapshot.key
//            let messageRef = Database.database().reference().child("messages").child(messageID)
//            messageRef.observe(.value, with: { (snapshot) in
//                guard let dictionary = snapshot.value as? [String: AnyObject] else {
//                    return
//                }
//                let message = Message(
//                    dictionary: dictionary
//                )
        for message in self.messages {
            if self.translationSwitch.isOn && message.text != nil {
                if language == "Chinese" {
                    self.chineseEnglishTranslator.translate(message.text!) { translatedText, error in
                        guard error == nil, let translatedText = translatedText else { return }
                        print(translatedText)
                        message.text = translatedText
                        self.tableView.reloadData()
                    }
                } else if language=="Japnese" {
                    self.japEngTranslator.translate(message.text!) { translatedText, error in
                        guard error == nil, let translatedText = translatedText else { return }
                        print(translatedText)
                        message.text = translatedText
                        self.tableView.reloadData()
                    }
                } else if language=="Germany" {
                    self.germanyEnglishTranslator.translate(message.text!) { translatedText, error in
                        guard error == nil, let translatedText = translatedText else { return }
                        print(translatedText)
                        message.text = translatedText
                        self.tableView.reloadData()
                    }
                } else if language=="Malay" {
                    self.malayEngTranslator.translate(message.text!) { translatedText, error in
                        guard error == nil, let translatedText = translatedText else { return }
                        print(translatedText)
                        message.text = translatedText
                        self.tableView.reloadData()
                    }
                } else if language=="Russian" {
                    self.russEngTranslator.translate(message.text!) { translatedText, error in
                        guard error == nil, let translatedText = translatedText else { return }
                        print(translatedText)
                        message.text = translatedText
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

//            })
//        }
//    }
    
    @IBAction func handleSend(_ sender: Any) {
        sendMessage()
    }

    @IBAction func handleEnter(_ sender: Any) {
        sendMessage()
    }
    
    @IBAction func handleFromLanguage(_ sender: Any) {
        dropDown1.show()
    }
    
    @IBAction func handleToLanguage(_ sender: Any) {
        // dropDown2.show()
    }
    
    @IBAction func handleToggle(_ sender: Any) {
        if translationSwitch.isOn {
            let lan = fromLanguage.titleLabel!.text!
            handleTranslate(language: lan)
        } else {
            self.messages = []
            observeMessages()
        }
    }
    
    @IBAction func handleSmartReply(_ sender: Any) {
        let naturalLanguage = NaturalLanguage.naturalLanguage()
        naturalLanguage.smartReply().suggestReplies(for: conversation) { result, error in
            guard error == nil, let result = result else {
                return
            }
            if (result.status == .notSupportedLanguage) {
                // The conversation's language isn't supported, so the
                // the result doesn't contain any suggestions.
                print("not support language")
                self.replyBtn1.setTitle("not support language", for: .normal)
            } else if (result.status == .success) {
                for suggestion in result.suggestions {
                    print("Suggested reply: \(suggestion.text)")
                }
                self.replyBtn1.setTitle(result.suggestions[0].text, for: .normal)
                self.replyBtn2.setTitle(result.suggestions[1].text, for: .normal)
                self.replyBtn3.setTitle(result.suggestions[2].text, for: .normal)
                
            }
        }
    }
    
    @objc func selectReply() {
        print("smart reply")
        self.messageTextField.text = self.replyBtn1.titleLabel!.text
    }
    
}
