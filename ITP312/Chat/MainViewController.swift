//
//  MainViewController.swift
//  ITP312
//
//  Created by ITP312 on 15/1/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {

    @IBOutlet weak var navigation: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        let uid = Auth.auth().currentUser?.uid
        if  uid == nil {
            logout()
        } else {
            ref.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.navigation.title = dictionary["name"] as? String
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutErr {
            print(logoutErr)
        }
        let LoginViewController =  self.storyboard?.instantiateViewController(withIdentifier: "Login") as! LoginViewController
        present(LoginViewController, animated: true, completion: nil)
    }
    

    @IBAction func handleLogout(_ sender: Any) {
        logout()
    }
}
