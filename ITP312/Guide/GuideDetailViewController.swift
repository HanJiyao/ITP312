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
    var guide:Guide?
    @IBOutlet weak var guideImageView: UIImageView!
    @IBOutlet weak var userNameTextLabel: UILabel!
    @IBOutlet weak var serviceTextLabel: UITextView!
    @IBOutlet weak var descTextLabel: UITextView!
    @IBOutlet weak var dateTextLabel: UITextView!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var userProfileImg: UIImageView!
    @IBOutlet weak var userProfileOuter: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatButton.layer.cornerRadius = 15
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        if uid == guide?.guideID {
            chatButton.isHidden = true
        }
        guideImageView.loadImageCache(urlString: (guide?.imgURL!)!)
        userProfileImg.loadImageCache(urlString: (user?.profileURL!)!)
        userProfileImg.layer.cornerRadius = 30
        userProfileImg.clipsToBounds = true
        userProfileImg.layer.borderColor = CGColor.init(srgbRed: 1, green: 1, blue: 1, alpha: 1)
        userProfileImg.layer.borderWidth = 3
        userProfileOuter.layer.cornerRadius = 30
        userProfileOuter.layer.shadowRadius = 10
        userProfileOuter.layer.shadowOffset = CGSize.zero
        userProfileOuter.layer.shadowColor = UIColor.black.cgColor
        userProfileOuter.layer.shadowOpacity = 0.3
        userNameTextLabel.text = user?.name
        descTextLabel.text = guide?.desc
        serviceTextLabel.text = guide?.service
        dateTextLabel.text = guide?.date
    }

    @IBAction func handleRedirectChat(_ sender: Any) {
//        guard let uid = Auth.auth().currentUser?.uid else {
//            return
//        }
//        if uid == guide?.guideID {
//            let GuideEditViewController = self.storyboard?.instantiateViewController(withIdentifier: "CreateGuide") as! GuideEditViewController
//            GuideEditViewController.guide = guide
//            self.navigationController?.pushViewController(GuideEditViewController, animated: true)
//        } else {
            let chatLogViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatLog") as! ChatLogViewController
            chatLogViewController.user = user
            self.navigationController?.pushViewController(chatLogViewController, animated: true)
//        }
    }
}
