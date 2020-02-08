//
//  GuideBookOfferViewController.swift
//  ITP312
//
//  Created by ITP312 on 7/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class GuideBookOfferViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var acceptBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.layer.cornerRadius = 20
        acceptBtn.layer.cornerRadius = 18
        profileImgView.layer.cornerRadius = 60
    }
    
    var user: User?
    var offerID = ""
    
    override func viewWillAppear(_ animated: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference()
        ref.child("user-guides").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                for i in dictionary {
                    let userID = i.key
                    if userID == uid {
                        ref.child("/users/\(i.value)").observeSingleEvent(of: .value) { (snapshot) in
                            if let dictionary = snapshot.value as? [String: AnyObject] {
                                self.user = User(
                                    id: i.key,
                                    name: dictionary["name"]! as! String,
                                    email: dictionary["email"]! as! String,
                                    profileURL: dictionary["profileURL"]! as! String
                                )
                                guard let name = self.user?.name,
                                    let email = self.user?.email,
                                    let imageURL = self.user?.profileURL
                                else {
                                    return
                                }
                                self.offerID = i.value as! String
                                self.nameLabel.text = name
                                self.imageLabel.text = email
                                self.profileImgView.loadImageCache(urlString: imageURL)
                            }
                        }
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    @IBAction func handleAccept(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference()
        ref.child("/guides/\(uid)").updateChildValues(["booked" : true])
        ref.child("/guides/\(uid)").updateChildValues(["offerID" : offerID])
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleReject(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference()
        ref.child("/guides/\(uid)").updateChildValues(["booked" : false])
        ref.child("/guides/\(uid)").updateChildValues(["offerID" : ""])
        dismiss(animated: true, completion: nil)
    }
}
