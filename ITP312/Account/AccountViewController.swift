//
//  AccountViewController.swift
//  ITP312
//
//  Created by ITP312 on 31/1/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
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
