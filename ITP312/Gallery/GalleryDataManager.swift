//
//  GalleryDataManager.swift
//  ITP312
//
//  Created by tyr on 6/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class DataManager: NSObject {
    // Loads the full list of movies from Firebase // and converts it into a [Movie] array.
    //
    // Since this is asynchronous, we need an // onComplete closure, a piece of code that can
    // be triggered to run once the loading from
    // Firebase is complete. //
    static func loadGallery (onComplete: @escaping ([GalleryModel]) -> Void) { // create an empty list.
        
        var galleryList : [GalleryModel] = []
        
        let ref = Database.database().reference()
        
        ref.child("photoframe").queryOrdered(byChild: "timestamp").observe(.value) { (snapshot) in
            
            print("observed!!!!!")
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let oneGallery = GalleryModel(data: child.value as! [String : Any])
                galleryList.append(oneGallery)
            }
            
            onComplete(galleryList)
        }
        
    } //end of loadGallery func
    
    static func insertGallery(_ gallery: GalleryModel) {
        
    }
    
    static func currentUser() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    static func ref() -> DatabaseReference {
        return Database.database().reference()
    }
    
    static func storageRef() -> StorageReference {
        return Storage.storage().reference()
    }
    
    static func viewControllerFromStoryboard (name: String, identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: identifier)
        return viewController
    }
    
    static func updateFolderPhotoCount(folderIDToUploadPhoto: String) {
        let ref = DataManager.ref()
        let currentUser = DataManager.currentUser()
        ref.child("folder").child(currentUser).child(folderIDToUploadPhoto).observe(.value) { (snapshot) in
            let photoCount = snapshot.childSnapshot(forPath: "photo").childrenCount
            ref.child("folder").child(currentUser).child(folderIDToUploadPhoto).updateChildValues(["subtitle": "\(photoCount)"])
        }
    }
    
    static func uploadImageToChat(image: UIImage, toID: String?) -> Void {
        // MARK: TODO: create uiimage download from firebase?
        // FIXME: test
        let imageName = NSUUID().uuidString
        let data = image.jpegData(compressionQuality: 0.3)
        
        let storageRef = Storage.storage().reference().child("message").child(imageName)
        let createStorage = StorageMetadata()
        let createCustom = [
            "imageHeight": "\(image.size.height)",
            "imageWidth": "\(image.size.width)"
        ]
        createStorage.customMetadata = createCustom
        
        storageRef.putData(data!, metadata: createStorage) { (metadata, error) in
            storageRef.downloadURL { (url, error) in
                if let imageURL = url?.absoluteString {
                    let ref = Database.database().reference()
                    //                    let toID = self.user!.id
                    let toID = toID
                    let fromID = Auth.auth().currentUser?.uid
                    let timestamp: NSNumber = NSNumber(value: Date().timeIntervalSince1970)
                    let values = [
                        "toID":toID!,
                        "fromID":fromID!,
                        "timestamp":timestamp,
                        "imageURL": imageURL,
                        "imageHeight": image.size.height,
                        "imageWidth": image.size.width
                        ] as [String : Any]
                    guard let key = ref.childByAutoId().key else { return }
                    
                    ref.child("messages").updateChildValues(["\(key)":values])
                    ref.child("/user-messages/\(fromID!)/\(toID!)/").updateChildValues(["\(key)":0])
                    ref.child("/user-messages/\(toID!)/\(fromID!)/").updateChildValues(["\(key)":0])
                }
            }
        }
    }
    
    static func createUIImageFromURL(imageURL: String) -> UIImage {
        let stringURL = URL(string: imageURL)!
        let imageRetrieved = UIImage(data: try! Data(contentsOf: stringURL))!
        return imageRetrieved
    }
    
    //discardableResult to ignore warning of result unused as there is no appending to folder list in swipephotoviewcontroller createfolder
    @discardableResult static func createFolder(title: String, subtitle: String, countryCode: String? = nil) -> FolderModel {
        let ref = DataManager.ref()
        let currentUser = DataManager.currentUser()
        //        guard let key = ref.child(currentUser).childByAutoId().key else {return}
        let values = [
            "title": title,
            "subtitle": subtitle,
            "image": countryCode ?? "listings",
            "timestamp": ServerValue.timestamp(),
            "key": title,
            "userID": currentUser
            ] as [String : Any]
        ref.child("folder").child(currentUser).child(title).setValue(values)
        let oneFolder = FolderModel(data: values)
        return oneFolder
    }
    
    
    static func passFolderID(data: String, presentFromTopMostViewController: Bool, onComplete: @escaping (UIImage) -> Void){
        print("folder id...", data)
        var imageList: [UIImage] = []
        let ref = DataManager.ref()
        let currentUser = DataManager.currentUser()
        ref.child("folder").child(currentUser).child(data).child("photo").observeSingleEvent(of: .value) { (snapshot) in
            let group = DispatchGroup()
            for case let child as DataSnapshot in snapshot.children {
                group.enter()
                guard let dict = child.value as? [String: Any] else {return}
                let imageURL = URL(string: dict["imageURL"] as! String)
                SDWebImageManager.shared.loadImage(with: imageURL, options: .continueInBackground, progress: nil) { (image, data, error, cacheType, isFinished, url) in
                    if let imageDownloaded = image {
                        imageList.append(imageDownloaded)
                        group.leave()
                    }
                }
            }
            group.notify(queue: .main) {
                print("finished...", imageList.count)
                let alert = UIAlertController(style: .actionSheet)
                var selectedImage: UIImage?
                alert.addImagePicker(flow: .vertical, paging: false, images: imageList, selection: .single(action: { image in
                    selectedImage = image
                }))
                alert.addAction(title: "OK", style: .default, handler: { action in
                    if let image = selectedImage {
                        onComplete(image)
                    }
                })
                alert.addAction(title: "Cancel", style: .cancel)
                
                //need check for top most view controller because current screen could be presented modally already, if yes present on top of most top
                presentFromTopMostViewController
                    ? UIApplication.shared.keyWindowInConnectedScenes?.rootViewController?.presentedViewController?.present(alert, animated: true, completion: nil)
                    : alert.show()
                
            }
        }
    }

    
//         let storyboard = UIStoryboard(name: "GalleryStoryboard", bundle: nil)
//                let photoViewController = storyboard.instantiateViewController(withIdentifier: "UploadPhoto") as! UploadPhotoViewController
    //            self.present(photoViewController, animated: true, completion: nil)
//                self.navigationController?.pushViewController(photoViewController, animated: true)
    
    //
}

extension UIApplication {
    //need check for top most view controller because current screen could be presented modally already, if yes present on top of most top
    // https://stackoverflow.com/questions/11862883/attempt-to-present-uiviewcontroller-on-uiviewcontroller-whose-view-is-not-in-the
    // https://stackoverflow.com/questions/57134259/how-to-resolve-keywindow-was-deprecated-in-ios-13-0
    // The app's key window taking into consideration apps that support multiple scenes.
    var keyWindowInConnectedScenes: UIWindow? {
        return windows.first(where: { $0.isKeyWindow })
    }
}
