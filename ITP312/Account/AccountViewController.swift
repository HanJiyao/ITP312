//
//  AccountViewController.swift
//  ITP312
//
//  Created by ITP312 on 31/1/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController, GalleryDelegate {
    
    @IBOutlet weak var greetingLable: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let date = NSDate()
        let calendar = NSCalendar.current
        let currentHour = calendar.component(.hour, from: date as Date)
        let hourInt = Int(currentHour.description)!
        
        if hourInt >= 6 && hourInt <= 12 {
            greetingLable.text = "Good Morning,"
        }
        else if hourInt >= 12 && hourInt <= 16 {
            greetingLable.text = "Good Afternoon,"
        }
        else if hourInt >= 16 && hourInt <= 22 {
            greetingLable.text = "Good Evening,"
        }
        else if hourInt >= 22 && hourInt <= 24 {
            greetingLable.text = "Good Night,"
        }
        else if hourInt >= 0 && hourInt <= 6 {
            greetingLable.text = "Good Night,"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("login check fail")
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let username = dictionary["name"]! as? String
                self.userLabel.text = username
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutErr {
            print(logoutErr)
        }
    }
    
    
    @IBAction func handleLogout(_ sender: Any) {
        logout()
    }
    
    @IBAction func navigateToGalleryBtnClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "GalleryStoryboard", bundle: nil)
        let galleryViewController = storyboard.instantiateViewController(identifier: "Gallery") as! GalleryCollectionViewController
        galleryViewController.returnImage = true
        //        self.navigationController?.pushViewController(galleryViewController, animated: true)
        galleryViewController.delegate = self
        self.present(galleryViewController, animated: true, completion: nil)
        
    }
 
    func doSomethingWith(data: String) {
           print("received data!!!", data)
    }
}
