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
    @IBOutlet weak var fromDateTextLabel: UITextView!
    @IBOutlet weak var toDateTextLabel: UITextView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var descSeperator: UIView!
    @IBOutlet weak var selectServiceBtn: UIButton!
    @IBOutlet weak var serviceSeperator: UIView!
    @IBOutlet weak var dateSeperator: UIView!
    @IBOutlet weak var previewBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var countryBtn: UIButton!
    
    var user: User?
    var guide: Guide?
    var displayService:String = ""
    var guideDates:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeExisting()
        guideImageView.isUserInteractionEnabled = true
        guideImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGuideImage)))
        descTextLabel.delegate = self
        fromDateTextLabel.delegate = self
        toDateTextLabel.delegate = self
        previewBtn.layer.cornerRadius = 15
        saveBtn.layer.cornerRadius = 15
        disableBtn(button: saveBtn)
        disableBtn(button: previewBtn)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if guide != nil {
            if guide?.imgURL != nil {
                guideImageView.loadImageCache(urlString: (guide?.imgURL!)!)
            }
            selectServiceBtn.setTitle(guide?.service, for: .normal)
            displayService = guide!.service!
            descTextLabel.text = guide?.desc
            fromDateTextLabel.text = guide?.fromDate
            toDateTextLabel.text = guide?.toDate
        } else {
           deleteBtn.isHidden = true
        }
    }
    
    func observeExisting() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("guides/\(uid)").observe(.value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let guide = Guide(dictionary: dictionary )
                self.guide = guide
                for i in (dictionary["guideDates"] as? [String:AnyObject])! {
                    self.guideDates.append(i.key)
                }
            }
        }
    }
    
    
    private func disableBtn (button: UIButton) {
        if button.titleLabel?.text! == "Save" {
            button.backgroundColor = .lightGray
        }
        button.isEnabled = false
    }
    
    private func enableBtn (button: UIButton) {
        if button.titleLabel?.text! == "Save" {
            button.backgroundColor = .systemBlue
        }
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
            disableBtn(button: previewBtn)
        } else if desc != guide?.desc {
            descSeperator.backgroundColor = .systemGreen
        }
        if displayService == "" {
            serviceSeperator.backgroundColor = .red
            disableBtn(button: saveBtn)
            disableBtn(button: previewBtn)
        } else if displayService != guide?.service {
            serviceSeperator.backgroundColor = .systemGreen
        }
        let fromDate = fromDateTextLabel.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let toDate = toDateTextLabel.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if  fromDate == "" ||  toDate == "" {
            dateSeperator.backgroundColor = .red
            disableBtn(button: saveBtn)
            disableBtn(button: previewBtn)
        } else if fromDate != guide?.fromDate || toDate != guide?.toDate {
            dateSeperator.backgroundColor = .systemGreen
        }
        if desc != "" && displayService != "" && toDate != "" && fromDate != "" {
            guide = Guide(dictionary:
                [
                    "guideID": Auth.auth().currentUser?.uid as AnyObject,
                    "service": displayService as AnyObject,
                    "desc": desc as AnyObject,
                    "fromDate": fromDate as AnyObject,
                    "toDate":toDate as AnyObject
                ]
            )
            enableBtn(button: saveBtn)
            enableBtn(button: previewBtn)
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
        if let serviceList = self.guide?.service!.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ") {
            selectionMenu.setSelectedItems(items: serviceList) { (item, index, bol, items) in
            }
        }
        selectionMenu.show(style: .actionSheet(title: nil, action: "Done", height: nil), from: self)
        selectionMenu.onDismiss = { selectedItems in
            print(selectedItems)
            self.displayService =  ""
            if selectedItems.count != 0 {
                for i in selectedItems {
                    if i != selectedItems.last {
                        self.displayService += "\(i), "
                    }
                    else
                    {
                        self.displayService += "\(i)"
                    }
                }
            }
            if self.displayService == "" {
                self.selectServiceBtn.setTitle("Please select at least one service", for: .normal)
                self.selectServiceBtn.setTitleColor(.red, for: .normal)

            } else {
                self.selectServiceBtn.setTitle(self.displayService, for: .normal)
                self.selectServiceBtn.setTitleColor(.systemBlue, for: .normal)
            }
            self.validateGuideInput()
        }

    }
    
    @IBAction func handleCalender(_ sender: Any) {
        guard let guideCalenderViewController = self.storyboard?.instantiateViewController(withIdentifier: "GuideCalender") as? GuideCalenderViewController else { return }
        if self.guideDates.count != 0 {
            var datesRange:[Date] = []
            for i in self.guideDates {
                let date = guideCalenderViewController.formatter.date(from: i)
                datesRange.append(date!)
            }
            datesRange = datesRange.sorted(by: { $0.compare($1) == .orderedAscending })
            guideCalenderViewController.datesRange = datesRange
            guideCalenderViewController.firstDate = datesRange.first
            guideCalenderViewController.lastDate = datesRange.last
        }
        guideCalenderViewController.guideRole = true
        guideCalenderViewController.callbackClosure = { [self] in
            self.fromDateTextLabel.text = guideCalenderViewController.startDateLabel.text!
            self.toDateTextLabel.text = guideCalenderViewController.endDateLabel.text!
            self.guideDates.removeAll()
            for i in guideCalenderViewController.datesRange {
                let date = guideCalenderViewController.formatter.string(from: i)
                self.guideDates.append(date)
            }
            self.validateGuideInput()
         }
         present(guideCalenderViewController, animated: true, completion: nil)
    }
    
    @IBAction func handleSave(_ sender: Any) {
        let service = displayService
        let desc = descTextLabel.text!
        let fromDate = fromDateTextLabel.text!
        let toDate = toDateTextLabel.text!
        var guideDictionary:[String:Int] = [:]
        for i in self.guideDates {
            guideDictionary[i] = 0
        }
        let country = countryBtn.titleLabel!.text!
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let data = self.guideImageView.image!.jpegData(compressionQuality: 1)
        let storageRef = Storage.storage().reference().child("guides").child("\(uid).png")
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
                    "guideID":uid,
                    "offerID":"",
                    "booked":false,
                    "guideDates":guideDictionary,
                    "country":country,
                    ] as [String : Any]
                Database.database().reference().child("guides/\(uid)/").setValue(values) {
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
            let guideDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "GuideDetail") as! GuideDetailViewController
            guideDetailViewController.user = user
            guideDetailViewController.guide = self.guide
            guideDetailViewController.preview = true
            self.navigationController?.pushViewController(guideDetailViewController, animated: true)
        })
    }
    
    @IBAction func handleDelete(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("/guides/\(uid)").removeValue()
        Database.database().reference().child("/user-guide/\(uid)").removeValue()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func handleSelectCountry(_ sender: Any) {
        let alert = UIAlertController(style: .actionSheet, message: "Select Country")
        alert.addLocalePicker(type: .country) { info in
            if info != nil {
                self.countryBtn.setTitle(info!.country, for: .normal)
            }
        }
        alert.addAction(title: "cancel", style: .cancel)
        alert.show()
    }
}
