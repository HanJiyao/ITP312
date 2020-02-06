//
//  GalleryViewController.swift
//  ITP312
//
//  Created by tyr on 2/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase
import SwiftUI

class GalleryViewController: UIViewController {
    
    @IBOutlet var theContainer: UIView!
    @IBOutlet weak var galleryLabel: UILabel!
    
    var idToChange = "hello"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidload gallery!")
        // Do any additional setup after loading the view.
        
        //https://stackoverflow.com/a/59014878
        let childView = UIHostingController(rootView: SwiftUIGallery())
        addChild(childView)
        childView.view.frame = theContainer.bounds
        theContainer.addSubview(childView.view)
        childView.didMove(toParent: self)
    }
    
    //https://stackoverflow.com/questions/51638424/swift-4-firebase-how-to-observe-the-snapshot-and-convert-into-object
    
    override func viewDidAppear(_ animated: Bool) {
        print("view did appear gallery! \n" + idToChange)
        
        galleryLabel.text = "Not logged in"
        
        print("email", (Auth.auth().currentUser?.email)!!)
        
        if let currentUser = Auth.auth().currentUser {
            print("current user id", currentUser.uid)
            galleryLabel.text = "Logged in " + currentUser.email!
            let ref = Database.database().reference().child("users").child("\(currentUser.uid)")
            print(ref)
            ref.observe(.value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                print("print user object " + "\(dictionary as AnyObject)")
                print(dictionary["name"]!)
//                                dump(dictionary)
                //                let user = User(
                //                    id: chatPartnerID,
                //                    name: dictionary["name"]! as! String,
                //                    email: dictionary["email"]! as! String,
                //                    profileURL: dictionary["profileURL"]! as! String
                //                )
            }
                
                
            )
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
