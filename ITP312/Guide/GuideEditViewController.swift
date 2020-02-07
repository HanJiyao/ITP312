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
import SwiftValidator

class GuideEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var guideImageView: UIImageView!
    @IBOutlet weak var descTextLabel: UITextView!
    @IBOutlet weak var fromDateTextLabel: UITextView!
    @IBOutlet weak var toDateTextLabel: UITextView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var descSeperator: UIView!
    @IBOutlet weak var selectServiceBtn: UIButton!
    @IBOutlet weak var serviceSeperator: UIView!
    @IBOutlet weak var dateSeperator: UIView!
    
    var user: User?
    var guide: Guide?
    var displayService:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeExisting()
        guideImageView.isUserInteractionEnabled = true
        guideImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGuideImage)))
        descTextLabel.delegate = self
        fromDateTextLabel.delegate = self
        toDateTextLabel.delegate = self
        
        saveBtn.layer.cornerRadius = 15
        disableBtn(button: saveBtn)
        
//        validator.registerField(fromDateTextLabel, rules: [RequiredRule()])
//        validator.registerField(toDateTextLabel, rules: [RequiredRule()])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if guide != nil {
            guideImageView.loadImageCache(urlString: (guide?.imgURL!)!)
            selectServiceBtn.setTitle(guide?.service, for: .normal)
            displayService = guide!.service!
            descTextLabel.text = guide?.desc
            fromDateTextLabel.text = guide?.fromDate
            toDateTextLabel.text = guide?.toDate
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
        print("validate input")
        validateGuideInput()
    }
        
    private func validateGuideInput () {

        let desc = descTextLabel.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if  desc == "" {
            descSeperator.backgroundColor = .red
            disableBtn(button: saveBtn)
        } else {
            descSeperator.backgroundColor = .systemGreen
        }
        if displayService == "" {
            serviceSeperator.backgroundColor = .red
            disableBtn(button: saveBtn)
        } else {
            serviceSeperator.backgroundColor = .systemGreen
        }
        let fromDate = fromDateTextLabel.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let toDate = toDateTextLabel.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if  fromDate == "" ||  toDate == "" {
            dateSeperator.backgroundColor = .red
            disableBtn(button: saveBtn)
        } else {
            dateSeperator.backgroundColor = .systemGreen
        }
        if desc != "" && displayService != "" && toDate != "" && fromDate != "" {
            enableBtn(button: saveBtn)
        }
    }
    
    func validationSuccessful() {
        saveGuideData()
    }

    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
      // turn the fields to red
      for (field, error) in errors {
        if let field = field as? UITextField {
          field.layer.borderColor = UIColor.red.cgColor
          field.layer.borderWidth = 1.0
        }
        error.errorLabel?.text = error.errorMessage // works if you added labels
        error.errorLabel?.isHidden = false
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
    
    let serviceDataArray = [
        "Pick up & Driving Tours",
        "Shopping",
        "Food & Restaurants",
        "Sports & Recreation",
        "History & Culture",
        "Art & Museums",
        "Nightlife & Bars",
        "Exploration & Sightseeing",
        "Translation & Interpretation"
    ]
    var selectedDataArray = [String]()
    
    @IBAction func selectService(_ sender: Any) {
        let selectionMenu = RSSelectionMenu(selectionStyle: .multiple, dataSource: serviceDataArray) { (cell, name, indexPath) in
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
    
    @IBAction func handleCalender(_ sender: Any) {
        let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        
        guard let guideCalenderViewController = self.storyboard?.instantiateViewController(withIdentifier: "GuideCalender") as? GuideCalenderViewController else { return }
        if let fromDate = formatter.date(from: fromDateTextLabel.text!), let toDate = formatter.date(from: toDateTextLabel.text!) {
            guideCalenderViewController.datesRange = guideCalenderViewController.datesRange(from: fromDate, to: toDate)
            guideCalenderViewController.firstDate = fromDate
            guideCalenderViewController.lastDate = toDate
        }
        guideCalenderViewController.callbackClosure = { [weak self] in
            self?.fromDateTextLabel.text = guideCalenderViewController.startDateLabel.text!
            self?.toDateTextLabel.text = guideCalenderViewController.endDateLabel.text!
            self?.validateGuideInput()
         }
         present(guideCalenderViewController, animated: true, completion: nil)
    }
    
    private func saveGuideData() {
        let service = displayService
        let desc = descTextLabel.text!
        let fromDate = fromDateTextLabel.text!
        let toDate = toDateTextLabel.text!
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
                    "fromDate": fromDate,
                    "toDate":toDate,
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
    
    @IBAction func handleSave(_ sender: Any) {
        saveGuideData()
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
