//
//  GalleryUploadPhotoFrameViewController.swift
//  ITP312
//
//  Created by tyr on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class GalleryUploadPhotoFrameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UITextField!
    
    @IBOutlet weak var priceLabel: UITextField!
    
    var pictureSelected = false
    
    var callbackResult: ((_ data: String) -> ())? //https://stackoverflow.com/questions/56800425/how-to-reload-data-in-uitableview-when-popping-view-controller

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target:self, action:#selector(imagePressed))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
    }
    
    
    @IBAction func createPhotoFrameBtnClicked(_ sender: Any) {
        let ref: DatabaseReference!
        ref = Database.database().reference()
                
        if (descriptionLabel.text == "" || priceLabel.text == "" || !pictureSelected) {
            var alertMsg = "Please fill all necessary details"
            if !pictureSelected {
                alertMsg = "Please select an image"
            }
            let alert = UIAlertController(title: "Hold on!", message: alertMsg, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
            self.present(alert, animated: true)
            return
        }
        

        let imageJPEG = imageView.image?.jpegData(compressionQuality: 0.7)
//        let uid = Auth.auth().currentUser?.uid

        let storageRef = Storage.storage().reference().child("photoframe").child("\(UUID().uuidString).png")
        
        storageRef.putData(imageJPEG!, metadata: nil) { (metadata, error) in
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print(error!)
                    return
                }
                let values = [
                    "name": self.descriptionLabel.text!,
                    "price": self.priceLabel.text!,
                    "imageURL": downloadURL.absoluteString,
                    "userID": Auth.auth().currentUser?.uid,
                    "timestamp": ServerValue.timestamp()
                    ] as [String : Any]
                ref.child("photoframe").childByAutoId().setValue(values) {
                    (error:Error?, ref:DatabaseReference) in
                    if let error = error {
                        print("Data could not be saved: \(error).")
                    } else {
                        print("Data saved successfullyss!")

                        self.callbackResult?("hello")
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    @objc func imagePressed() {
        imagePicker.delegate = self
//        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("select finish")
        imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        pictureSelected = true
        dismiss(animated: true)
    }
    
    
}
