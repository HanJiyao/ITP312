//
//  CreateGuideViewController.swift
//  ITP312
//
//  Created by ITP312 on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase
import RSSelectionMenu

class GuideEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var guideImageView: UIImageView!
    @IBOutlet weak var descTextLabel: UITextView!
    @IBOutlet weak var dateTextLabel: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var descSeperator: UIView!
    @IBOutlet weak var selectServiceBtn: UIButton!
    @IBOutlet weak var serviceSeperator: UIView!
    
    var user: User?
    var guide: Guide?
    var displayService:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeExisting()
        guideImageView.isUserInteractionEnabled = true
        guideImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGuideImage)))
        descTextLabel.delegate = self
        
        saveBtn.layer.cornerRadius = 15
        disableBtn(button: saveBtn)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if guide != nil {
            guideImageView.loadImageCache(urlString: (guide?.imgURL!)!)
            selectServiceBtn.setTitle(guide?.service, for: .normal)
            displayService = guide!.service!
            descTextLabel.text = guide?.desc
            dateTextLabel.text = guide?.date
        }
    }
    
    func observeExisting() {
        Database.database().reference().child("guide").observe(.value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                for i in dictionary {
                    let guide = Guide(dictionary: i.value as! [String : AnyObject])
                    if guide.guideID == Auth.auth().currentUser?.uid {
                        self.guide = guide
                    }
                }
            }
        }
    }
    
    private func disableBtn (button: UIButton) {
        button.backgroundColor = .lightGray
        button.isEnabled = false
    }
    
    private func enableBtn (button: UIButton) {
        button.backgroundColor = .systemBlue
        button.isEnabled = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        validateGuideInput()
    }
    
    private func validateGuideInput () {
        if descTextLabel.text == nil || descTextLabel.text == "" {
            descSeperator.backgroundColor = .red
            disableBtn(button: saveBtn)
        } else {
            descSeperator.backgroundColor = .green
        }
        if displayService == "" {
            serviceSeperator.backgroundColor = .red
            disableBtn(button: saveBtn)
        } else {
            serviceSeperator.backgroundColor = .green
        }
        if descTextLabel.text != "" && displayService != ""{
            descSeperator.backgroundColor = .green
            enableBtn(button: saveBtn)
        }
    }
    
    @objc func handleGuideImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            self.guideImageView.image = selectedImage!
            picker.dismiss(animated: true, completion: nil)
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            self.guideImageView.image = selectedImage!
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    let simpleDataArray = ["Sachin", "Rahul", "Saurav", "Virat", "Suresh", "Ravindra", "Chris"]
    var selectedDataArray = [String]()
    
    @IBAction func selectService(_ sender: Any) {
        let selectionMenu = RSSelectionMenu(selectionStyle: .multiple, dataSource: simpleDataArray) { (cell, name, indexPath) in
            cell.textLabel?.text = name
            cell.tintColor = .systemBlue
        }
        selectionMenu.dismissAutomatically = false

        selectionMenu.show(style: .actionSheet(title: nil, action: "Done", height: nil), from: self)
        selectionMenu.onDismiss = { selectedItems in
            self.displayService =  ""
            for i in selectedItems {
                self.displayService += "\(i), "
            }
            if self.displayService == "" {
                self.selectServiceBtn.setTitle(" Please select at least one service", for: .normal)
                self.selectServiceBtn.setTitleColor(.red, for: .normal)

            } else {
                 self.selectServiceBtn.setTitle(self.displayService, for: .normal)
                self.selectServiceBtn.setTitleColor(.systemBlue, for: .normal)
            }
            self.validateGuideInput()
        }

    }
    
    @IBAction func handleSave(_ sender: Any) {
        let service = displayService
        let desc = descTextLabel.text!
        let date = dateTextLabel.text!
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let data = self.guideImageView.image!.jpegData(compressionQuality: 1)
        let storageRef = Storage.storage().reference().child("guide").child("\(uid).png")
        storageRef.putData(data!, metadata: nil) { (metadata, error) in
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print(error!)
                    return
                }
                let values = [
                    "service":service,
                    "desc": desc,
                    "date": date,
                    "imgURL":downloadURL.absoluteString,
                    "guideID":uid
                ]
                Database.database().reference().child("guide/\(uid)/").updateChildValues(values) {
                    (error:Error?, ref:DatabaseReference) in
                    if let error = error {
                        print("Guide Data could not be saved: \(error).")
                    } else {
                        print("Guide Data saved successfully!")
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func handlePreviewBtn(_ sender: Any) {
        let guideID = Auth.auth().currentUser!.uid
        Database.database().reference().child("/users/\(guideID)/").observe(.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            let user = User(
                id: guideID,
                name: dictionary["name"]! as! String,
                email: dictionary["email"]! as! String,
                profileURL: dictionary["profileURL"]! as! String
            )
            let GuideDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "GuideDetail") as! GuideDetailViewController
            GuideDetailViewController.user = user
            GuideDetailViewController.guide = self.guide
            self.navigationController?.pushViewController(GuideDetailViewController, animated: true)
        })
    }
    
}
