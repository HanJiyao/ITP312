//
//  CreateGuideViewController.swift
//  ITP312
//
//  Created by ITP312 on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class GuideEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var guideImageView: UIImageView!
    @IBOutlet weak var serviceTextLabel: UITextField!
    @IBOutlet weak var descTextLabel: UITextView!
    @IBOutlet weak var dateTextLabel: UITextField!
    
    var guide: Guide?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guideImageView.isUserInteractionEnabled = true
        guideImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGuideImage)))
        if guide != nil {
            guideImageView.loadImageCache(urlString: (guide?.imgURL!)!)
            serviceTextLabel.text = guide?.service
            descTextLabel.text = guide?.desc
            dateTextLabel.text = guide?.date
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

    @IBAction func handleSave(_ sender: Any) {
        let service = serviceTextLabel.text!
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
}
