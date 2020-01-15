//
//  ChatViewController.swift
//  ITP312
//
//  Created by ITP312 on 14/1/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var loginRegisterSegment: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorTextField: UILabel!
    @IBOutlet weak var loginRegisterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if errorTextField != nil {
            errorTextField.text! = ""
        }
    }
    
    @IBAction func handleRegister(_ sender: Any) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        let name = nameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if loginRegisterSegment.selectedSegmentIndex == 0 {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if error != nil {
                    self.errorTextField.text = error?.localizedDescription
                }
                
                guard let uid = authResult?.user.uid else {
                    return
                }
                
                let values = ["name":name, "email":email]
                ref.child("users").child(uid).updateChildValues(values) {
                    (error:Error?, ref:DatabaseReference) in
                    if let error = error {
                        print("Data could not be saved: \(error).")
                    } else {
                        print("Data saved successfully!")
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        } else {
            Auth.auth().signIn(withEmail: email, password: password, completion: {
                (user, err) in
                if err != nil {
                    self.errorTextField.text = err?.localizedDescription
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    @IBAction func segementChanged(_ sender: Any) {
        let state = loginRegisterSegment.titleForSegment(at: loginRegisterSegment.selectedSegmentIndex)
        if loginRegisterSegment.selectedSegmentIndex == 0 {
            nameTextField.isHidden = false
        } else {
            nameTextField.isHidden = true
        }
        loginRegisterButton.setTitle(state, for: UIControl.State.normal)
        
    }
}
