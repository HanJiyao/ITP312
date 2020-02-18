//
//  UploadPhotoViewController.swift
//  ITP312
//
//  Created by tyr on 11/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import SDWebImage

class UploadPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FolderDelegate {

    var customTableViewController : CustomTableViewController?

    @IBOutlet weak var imageView: UIImageView!
    
    var pictureSelected = false
    
    var photoObject: PhotoModel = PhotoModel(name: "", country: "", latitude: "", longitude: "", imageURL: "", key: "")
    
    var folderIDToUploadPhoto: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        customTableViewController = self.children[0] as? CustomTableViewController
        customTableViewController?.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target:self, action:#selector(imagePressed))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        
        self.navigationItem.title = "Upload photo"
    }
    
    
    @objc func imagePressed() {
        let alert = UIAlertController(style: .actionSheet)
        alert.set(title: "Select one of the following", font: .systemFont(ofSize: 20), color: .black)
        alert.addAction(image: UIImage(systemName: "photo"), title: "Upload from phone gallery", color: .blue, handler: uploadPhotoFromPhone)
        alert.addAction(image: UIImage(systemName: "icloud.and.arrow.up.fill"), title: "Upload from other cloud folder", color: .blue, handler: chooseCloudFolder)
        alert.addAction(title: "Cancel", style: .cancel) //.cancel action will always be at the end
        alert.show(animated: true, vibrate: true)
    }
    
    func uploadPhotoFromPhone(_ alertAction: UIAlertAction) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
//        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("select finish")
        imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        pictureSelected = true
        dismiss(animated: true)
    }
    
    func chooseCloudFolder(_ alertAction: UIAlertAction) {
        print("choose folder...")
        let viewController = DataManager.viewControllerFromStoryboard(name: "DiscoverStoryboard", identifier: "Folder") as! ViewController
        viewController.folderDelegate = self
        viewController.hideActionButton()
        present(viewController, animated: true, completion: nil)
    }
    
    func passFolderID(data: String) {
        DataManager.passFolderID(data: data, presentFromTopMostViewController: false) { (image) in
            self.imageView.image = image
            self.pictureSelected = true
        }
    }
    

    @IBAction func uploadBtnClicked(_ sender: Any) {
        
        if (photoObject.country == "" || photoObject.name == "" || !pictureSelected) {
            var alertMsg = "Please check that you have selected country and location!"
            if !pictureSelected {
                alertMsg = "Please select an image"
            }
            let alert = UIAlertController(title: "Hold on!", message: alertMsg, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        //print("country at end", customTableViewController?.countryLabel.text)
        let imageJPEG = imageView.image?.jpegData(compressionQuality: 0.7)
        //        let storageRef = Storage.storage().reference().child("photoframe").child("\(UUID().uuidString).png")
        let currentUser = DataManager.currentUser()
        let storageRef = DataManager.storageRef().child("folder").child(currentUser).child(folderIDToUploadPhoto!).child("\(UUID().uuidString).png")
        let ref = DataManager.ref()
        print(photoObject)
        guard let photoShareToCountry = self.customTableViewController?.shareToggleSwitch.isOn else {return}
        
        DataManager.showProgressBar()
        
        storageRef.putData(imageJPEG!, metadata: nil) { (metadata, error) in
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print(error!)
                    return
                }
                guard let key =  ref.child("folder").child(currentUser).child(self.folderIDToUploadPhoto!).child("photo").childByAutoId().key else {return}
                let values = [
                    "name": self.photoObject.name!,
                    "country": self.photoObject.country!,
                    "imageURL": downloadURL.absoluteString,
                    "latitude": self.photoObject.latitude!,
                    "longitude": self.photoObject.longitude!,
                    "userID": currentUser,
                    "timestamp": ServerValue.timestamp(),
                    "privacy": "\(photoShareToCountry)",
                    "key": key
                    ] as [String : Any]
                ref.child("folder").child(currentUser).child(self.folderIDToUploadPhoto!).child("photo").child(key).setValue(values) {
                    (error:Error?, reference:DatabaseReference) in
                    if let error = error {
                        print("Data could not be saved: \(error).")
                    } else {
                        print("Data saved successfullyss!")
//                        self.dismiss(animated: true, completion: nil)
                        if photoShareToCountry {
                            let countryValues = [
                                "name": self.photoObject.name!,
                                "country": self.photoObject.country!,
                                "imageURL": downloadURL.absoluteString,
                                "timestamp": ServerValue.timestamp()
                            ] as [String : Any]
                            print("sharing to country", self.photoObject.country!)
                            ref.child("country").child(self.photoObject.country!).childByAutoId().setValue(countryValues)
                        }
                        
                        ref.child("folder").child(currentUser).child(self.folderIDToUploadPhoto!).observe(.value) { (snapshot) in
                            let photoCount = snapshot.childSnapshot(forPath: "photo").childrenCount
                            ref.child("folder").child(currentUser).child(self.folderIDToUploadPhoto!).updateChildValues(["subtitle": "\(photoCount)"])
                            
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
        
    }
    
}

protocol ProfileTableViewControllerDelegate: UploadPhotoViewController {
    func countryRowTapped()
    func locationRowTapped()
}

class CustomTableViewController: UITableViewController {
    
    weak var delegate : ProfileTableViewControllerDelegate?
    
    @IBOutlet weak var countryLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet var customTableViewOutlet: UITableView!
    
    @IBOutlet weak var shareToggleSwitch: UISwitch!
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let delegate = delegate {
            if indexPath.row == 0 { delegate.countryRowTapped() }
            else if indexPath.row == 1 { delegate.locationRowTapped() }
            else { shareToggleSwitch.setOn(!shareToggleSwitch.isOn, animated: true) }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let footerView = UIView()
//        footerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1)
//        footerView.backgroundColor = tableView.separatorColor
        customTableViewOutlet.tableFooterView = UIView() //hides last empty line (3rd row) below the 2 rows
        customTableViewOutlet.alwaysBounceVertical = false //prevent scrolling drag drop
    }
    
    
}


extension UploadPhotoViewController : ProfileTableViewControllerDelegate {
    
    func countryRowTapped() {
        showCountryAlert(showLocation: false)
    }
    
    func showCountryAlert(showLocation: Bool) {
        let alert = UIAlertController(style: .actionSheet, title: "Select Country")
        alert.addLocalePicker(type: .country) { info in
            self.customTableViewController?.countryLabel.text = info?.country
            self.photoObject.country = info?.country
            if showLocation {self.showLocationAlert()}
        }
        alert.addAction(title: "Cancel", style: .cancel)
        alert.show()
    }
    
    func locationRowTapped() {
        let country = customTableViewController?.countryLabel.text
        country == "Select" ? showCountryAlert(showLocation: true) : showLocationAlert()
    }
    
    func showLocationAlert() {
        
        let searchRequest = MKLocalSearch.Request()
        let country = customTableViewController?.countryLabel.text
        searchRequest.naturalLanguageQuery = country
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            if response == nil {
                print("ERROR")
            } else {
                // Get coordinates of centroid for search result
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                // Zooming onto coordinate
                let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                
                let alert = UIAlertController(style: .actionSheet, title: "Country: " + country!)
                alert.addLocationPicker(region: region) { location in
                    let checkText = location?.name != nil ? location?.name
                        : location?.placemark.postalAddress?.street != "" ? location?.placemark.postalAddress?.street
                        : location?.placemark.postalAddress?.city != "" ? location?.placemark.postalAddress?.city
                        : location?.placemark.country
                    self.customTableViewController?.locationLabel.text = checkText
                    self.photoObject.name = checkText
                    self.photoObject.country = country!
                    self.photoObject.latitude = "\(location!.coordinate.latitude)"
                    self.photoObject.longitude = "\(location!.coordinate.longitude)"
                    
                }
                alert.addAction(title: "Cancel", style: .cancel)
                alert.show()
            }
        }
    }
}
