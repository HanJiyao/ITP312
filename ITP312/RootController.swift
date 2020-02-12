//
//  ViewController.swift
//  ITP312
//
//  Created by ITP312 on 14/1/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class RootViewController: UITabBarController {

    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            let uid = auth.currentUser?.uid
            if uid != nil {
                print("Logged in as \(uid!)")
            } else {
                print("User not login")
                let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! LoginViewController
                self.present(loginViewController, animated: true, completion: nil)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }

}

