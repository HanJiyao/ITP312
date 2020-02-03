//
//  ChatViewController.swift
//  ITP312
//
//  Created by ITP312 on 14/1/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var loginRegisterSegment: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorTextField: UILabel!
    @IBOutlet weak var loginRegisterButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if errorTextField != nil {
            errorTextField.text! = ""
        }
        
        loginRegisterButton.layer.cornerRadius = 18
//        loginRegisterSegment.layer.borderColor = UIColor.init(red: 0, green: 0 , blue: 0, alpha: 0.2).cgColor
//        loginRegisterSegment.layer.borderWidth = 1
//        loginRegisterSegment.layer.cornerRadius = 15
//        loginRegisterSegment.layer.masksToBounds = true

        nameTextField.setBottomBorder()
        emailTextField.setBottomBorder()
        passwordTextField.setBottomBorder()
    }
    
    @objc func handleProfileImage (){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            self.profileImageView.image = selectedImage!
            picker.dismiss(animated: true, completion: nil)
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            self.profileImageView.image = selectedImage!
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    // var messagesController: ChatMainViewController?
    
    private func handleLoginRegister(){
        let ref: DatabaseReference!
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
                let data = self.profileImageView.image!.jpegData(compressionQuality: 0.3)
                let storageRef = Storage.storage().reference().child("profile").child("\(uid).png")
                storageRef.putData(data!, metadata: nil) { (metadata, error) in
                    storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            print(error!)
                            return
                        }
                        let values = ["name":name, "email":email, "profileURL":downloadURL.absoluteString]
                        ref.child("users").child(uid).updateChildValues(values) {
                            (error:Error?, ref:DatabaseReference) in
                            if let error = error {
                                print("Data could not be saved: \(error).")
                            } else {
                                print("Data saved successfully!")
                                // self.messagesController?.setCurrentUser()
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        } else {
            Auth.auth().signIn(withEmail: email, password: password, completion: {
                (user, err) in
                if err != nil {
                    self.errorTextField.text = err?.localizedDescription
                } else {
                    // self.messagesController?.setCurrentUser()
                    self.dismiss(animated: true)
                }
            })
        }
    }
    
    @IBAction func handleRegister(_ sender: Any) {
        handleLoginRegister()
    }
    
    @IBAction func segementChanged(_ sender: Any) {
        let state = loginRegisterSegment.titleForSegment(at: loginRegisterSegment.selectedSegmentIndex)
        if loginRegisterSegment.selectedSegmentIndex == 0 {
            nameTextField.isHidden = false
            profileImageView.isUserInteractionEnabled = true
            profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImage)))
        } else {
            nameTextField.isHidden = true
            profileImageView.isUserInteractionEnabled = false
            profileImageView.removeGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImage)))
        }
        loginRegisterButton.setTitle(state, for: UIControl.State.normal)
    }
    
    @IBAction func handleEnter(_ sender: Any) {
        handleLoginRegister()
    }
    
    @IBAction func handleLoginImage(_ sender: Any) {
        if loginRegisterSegment.selectedSegmentIndex == 0 {
            
        }
    }
}

extension UITextField {
    func setBottomBorder() {
        self.borderStyle = UITextField.BorderStyle.none
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.init(red: 0, green: 0 , blue: 0, alpha: 0.2).cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
