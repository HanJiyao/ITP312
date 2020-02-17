//
//  PhotoViewController.swift
//  ITP312
//
//  Created by tyr on 11/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import INSPhotoGallery
import JJFloatingActionButton
import Firebase

class PhotoViewController: UIViewController, ChatDelegate, FolderDelegate {

    var folderObject: FolderModel?
    
    var useCustomOverlay = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate let actionButton = JJFloatingActionButton()
    
    var selectedImageURLToShare: String?
    var selectedImage: PhotoModel?

    lazy var photos: [INSPhotoViewable] = {
           return [
            INSPhoto(image: UIImage(named: "profile"), thumbnailImage: UIImage(named: "profile")),
            INSPhoto(image: UIImage(named: "profile"), thumbnailImage: UIImage(named: "profile")),
            INSPhoto(image: UIImage(named: "profile"), thumbnailImage: UIImage(named: "profile")),
            INSPhoto(image: UIImage(named: "profile"), thumbnailImage: UIImage(named: "profile")),
            INSPhoto(image: UIImage(named: "profile"), thumbnailImage: UIImage(named: "profile"))
           ]
    }()
    
    lazy var photoList: [PhotoModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never //smooth transition from large title to small

        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        loadPhotos()
        
        for photo in photos {
            if let photo = photo as? INSPhoto {
                photo.attributedTitle = NSAttributedString(string: "Example caption text\ncaption text", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            }
        }
        
        configureActionButton()
        
        self.navigationItem.title = folderObject?.title
    
    }
    
    func configureActionButton() {
        actionButton.buttonColor = .systemBlue
        actionButton.addItem().action = { item in
            print("hello")
            let photoViewController = DataManager.viewControllerFromStoryboard(name: "GalleryStoryboard", identifier: "UploadPhoto") as! UploadPhotoViewController
            photoViewController.folderIDToUploadPhoto = self.folderObject?.key
            self.navigationController?.pushViewController(photoViewController, animated: true)
        }
        actionButton.display(inViewController: self)
    }
    
    func loadPhotos() {
        let ref = DataManager.ref()
        let currentUser = DataManager.currentUser()
        ref.child("folder").child(currentUser).child(folderObject!.key!).child("photo").observe(.value) { snapshot in
            self.photoList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
//                print("child", child.value)
//                print(child.value)
                if let dict = child.value as? [String: AnyObject] {
//                    print(dict["imageURL"])
                    let firebaseimageURL = URL(string: dict["imageURL"] as! String)
//                    let firebaseimageURL = dict["imageURL"] as! String
//                    print(firebaseimageURL)
//                    let onePhoto = INSPhoto(imageURL: firebaseimageURL, thumbnailImageURL: firebaseimageURL)
                    let onePhoto = PhotoModel(data: dict)
//                    let stringURL = URL(string: photoList[indexPath.row].imageURL!)!
//                    let imageRetrieved = UIImage(data: try! Data(contentsOf: stringURL))
                    //        photoList[indexPath.row].thumbnailImage = imageRetrieved
//                    onePhoto.printObj("this photo")
                    onePhoto.attributedTitle = NSAttributedString(string: "Location: \(onePhoto.name!)\nCountry: \(onePhoto.country!)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                    self.photoList.append(onePhoto)
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
}



extension PhotoViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExampleCollectionViewCell", for: indexPath) as! ExampleCollectionViewCell
//        cell.imageView.image = UIImage(systemName: "tray")
//        cell.populateWithPhoto(photoList[indexPath.row])
        cell.setPhotoFB(photoList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("count \(photoList.count)")
        return photoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ExampleCollectionViewCell
        let currentPhoto = photoList[(indexPath as NSIndexPath).row]
        let galleryPreview = INSPhotosViewController(photos: photoList, initialPhoto: currentPhoto, referenceView: cell)
        if useCustomOverlay {
            galleryPreview.overlayView = CustomOverlayView(frame: CGRect.zero)
        }
        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
            if let index = self?.photoList.firstIndex(where: {$0 === photo}) {
                let indexPath = IndexPath(item: index, section: 0)
                return collectionView.cellForItem(at: indexPath) as? ExampleCollectionViewCell
            }
            return nil
        }
        present(galleryPreview, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (UIScreen.main.bounds.width - 20) / 3
        return CGSize(width: size, height: size)
    }
        
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { action in
            
            let folderMenu = UIAction(title: "Share to other folders", image: UIImage(systemName: "folder.badge.plus")) { _ in
                print("folder menu clicked..")
                self.selectedImage = self.photoList[indexPath.row]
                let viewController = DataManager.viewControllerFromStoryboard(name: "DiscoverStoryboard", identifier: "Folder") as! ViewController
                viewController.folderDelegate = self
                viewController.hideActionButton()
                self.present(viewController, animated: true, completion: nil)
            }
            
            let shareMenu = UIAction(title: "Share to chat", image: UIImage(systemName: "ellipses.bubble.fill")) { _ in
                print("share clicked..")
                self.selectedImageURLToShare = self.photoList[indexPath.row].imageURL
                let viewController = DataManager.viewControllerFromStoryboard(name: "ChatStoryboard", identifier: "Chat") as! ChatMainViewController
                viewController.chatDelegate = self
                self.present(viewController, animated: true, completion: nil)
            }
      
            let deleteMenu = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), attributes: .destructive) { _ in
                print("delete clicked.")
                let ref = DataManager.ref()
                let currentUser = DataManager.currentUser()
                ref.child("folder").child(currentUser).child(self.folderObject!.key!).child("photo").child(self.photoList[indexPath.row].key!).removeValue()
                self.photoList.remove(at: indexPath.row)
                collectionView.deleteItems(at: [indexPath])
            }
            return UIMenu(title: "Options", image: nil, identifier: nil, children: [folderMenu, shareMenu, deleteMenu])
        }
        return configuration
    }

    func passChatUser(user: User) {
        user.printObj("sharing to this user...")
        
        let imageCreated = DataManager.createUIImageFromURL(imageURL: selectedImageURLToShare!)
        
        DataManager.uploadImageToChat(image: imageCreated, toID: user.id)
        
        let chatLogViewController = DataManager.viewControllerFromStoryboard(name: "ChatStoryboard", identifier: "ChatLog") as! ChatLogViewController
        chatLogViewController.user = user
        
        self.navigationController?.pushViewController(chatLogViewController, animated: true)
    }
    
    func passFolderID(data: String) {
        print("FOLDER id to share photo to", data)
        let ref = DataManager.ref()
        let currentUser = DataManager.currentUser()
        let folderID = data
        let values = [
            "imageURL": selectedImage!.imageURL!,
            "name": selectedImage!.name!,
            "country": selectedImage!.country!,
            "timestamp": ServerValue.timestamp()
            ] as [String : Any]
        ref.child("folder").child(currentUser).child(folderID).child("photo").childByAutoId().setValue(values) { (err, ref) in
            if err != nil {return}
            DataManager.updateFolderPhotoCount(folderIDToUploadPhoto: folderID)
            print("shared successfully")
        }
    }
    
}

