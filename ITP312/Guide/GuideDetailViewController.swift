//
//  GuideDetailViewController.swift
//  ITP312
//
//  Created by ITP312 on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase
import ShadowView

class GuideDetailViewController: UIViewController {

    var user: User?
    var guide: Guide?
    var preview = false
    
    @IBOutlet weak var guideImageView: UIImageView!
    @IBOutlet weak var userNameTextLabel: UILabel!
    @IBOutlet weak var serviceTextLabel: UITextView!
    @IBOutlet weak var descTextLabel: UITextView!
    @IBOutlet weak var dateTextLabel: UITextView!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var userProfileImg: UIImageView!
    @IBOutlet weak var userProfileOuter: UIView!
    @IBOutlet weak var bookBtn: UIButton!
    @IBOutlet weak var bottomBar: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatButton.layer.cornerRadius = 15
        chatButton.layer.borderColor = UIColor.systemBlue.cgColor
        chatButton.layer.borderWidth = 1
        bookBtn.layer.cornerRadius = 15
        
        userProfileImg.layer.cornerRadius = 30
        userProfileImg.clipsToBounds = true
        userProfileImg.layer.borderColor = CGColor.init(srgbRed: 1, green: 1, blue: 1, alpha: 1)
        userProfileImg.layer.borderWidth = 3
        userProfileOuter.layer.cornerRadius = 30
        userProfileOuter.layer.shadowRadius = 10
        userProfileOuter.layer.shadowOffset = CGSize.zero
        userProfileOuter.layer.shadowColor = UIColor.black.cgColor
        userProfileOuter.layer.shadowOpacity = 0.3
        
        if preview {
            bottomBar.isHidden = true
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let guideID = guide?.guideID else {
            return
        }
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                for i in dictionary {
                    if i.key == guideID {
                        self.user = User(
                            id: i.key,
                            name: i.value["name"]!! as! String,
                            email: i.value["email"]!! as! String,
                            profileURL: i.value["profileURL"]!! as! String
                        )
                        if self.guide?.imgURL != nil {
                            self.guideImageView.loadImageCache(urlString: (self.guide?.imgURL!)!)
                        }
                        self.userProfileImg.loadImageCache(urlString: (self.user?.profileURL!)!)
                        self.userNameTextLabel.text = self.user?.name
                        self.descTextLabel.text = self.guide?.desc
                        self.serviceTextLabel.text = self.guide?.service
                        self.dateTextLabel.text = "\(self.guide!.fromDate!) to \(self.guide!.toDate!)"
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        if let booked = guide?.booked{
            if booked {
                bookBtn.setTitle("Booked", for: .normal)
                bookBtn.backgroundColor = .lightGray
                bookBtn.isEnabled = false
            }
        }
    }

    @IBAction func handleRedirectChat(_ sender: Any) {
        let chatLogViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatLog") as! ChatLogViewController
        chatLogViewController.user = user
        // self.navigationController?.pushViewController(chatLogViewController, animated: true)
        present(chatLogViewController, animated: true, completion: nil)
    }
    @IBAction func handleBook(_ sender: Any) {
        guard  let uid = Auth.auth().currentUser?.uid, let guidID = guide?.guideID else {
            return
        }
        let ref = Database.database().reference()
        
        ref.child("/guides/\(guidID)").updateChildValues(["booked":true])
        ref.child("/user-guides/guide-to-user/").updateChildValues([guidID:uid])
        ref.child("/user-guides/user-to-guide/\(uid)/\(guidID)/").updateChildValues(["status":0])
        
        bookBtn.setTitle("Booked", for: .normal)
        bookBtn.backgroundColor = .lightGray
        bookBtn.isEnabled = false
    }
}
