//
//  GalleryCollectionViewController.swift
//  ITP312
//
//  Created by tyr on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

protocol GalleryDelegate: NSObjectProtocol {
    func doSomethingWith(data: String)
}

class GalleryCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: GalleryDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var galleryList:[GalleryModel] = []
    
    var returnImage = false
    
    let screenSize = UIScreen.main.bounds

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Photo frames"
        print("view did load")
//        loadData()
        //let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()

        //loadGallery()
        loadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow:CGFloat = 4
        let spacingBetweenCells:CGFloat = 16
        
        let totalSpacing = (2 * 16) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
        
        if let collection = self.collectionView{
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
            return CGSize(width: width, height: width)
        }else{
            return CGSize(width: 0, height: 0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        loadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(galleryList.count)
        return galleryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        let onePhotoFrame = galleryList[indexPath.row]
        //        cell.nameLabel.text = onePhotoFrame.name
        //        cell.imageView = UIImageView(image: UIImage(named: onePhotoFrame.imageURL!))
        //        dump(onePhotoFrame)
        //        print(onePhotoFrame.name)
        
        //        Storage.storage().reference(forURL: onePhotoFrame.imageURL!).getData(maxSize: 2000000) { (data, error) in
        //            //https://stackoverflow.com/questions/54029490/firebase-storage-to-uiimageview
        //            print("data", data)
        //            guard let imageData = data, error == nil else {
        //                print("error", error)
        //                return
        //            }
        //            print("image data", imageData)
        //
        //            cell.displayContent(image: UIImage(data: imageData)!, price: onePhotoFrame.price!)
        //
        //        }
        
//        cell.imageView.loadImageCache(urlString: onePhotoFrame.imageURL!)
        cell.imageView.sd_setImage(with: URL(string: onePhotoFrame.imageURL!), placeholderImage: UIImage(named: "image-placeholder"))
        
        cell.nameLabel.text = "$" + onePhotoFrame.price!
        
        
        return cell
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    func loadData() {
        print("loading data")
        let ref = Database.database().reference()
        ref.child("photoframe").queryOrdered(byChild: "timestamp").observe(.value) { (snapshot) in
            self.galleryList.removeAll()
            //            if let snapDict = snapshot.children as? DataSnapshot {
            print("snapshot value", snapshot.value!)
            for child in snapshot.children.allObjects as! [DataSnapshot] { //don't convert into dictionary, dictionary won't maintain order of items
                //print("child val",child.value)
                //print("cihld key", child.key)
                let oneGallery = GalleryModel(data: child.value as! [String : Any])
                self.galleryList.append(oneGallery)
            }

//                for i in (snapshot.value as? [String:AnyObject])! {
//
//                    print("i val", i.value)
//                    print("i key?", i.key)
//                    let oneGallery = GalleryModel(data: i.value as! [String : Any])
//                    self.galleryList.append(oneGallery)
//                }
            
//                let oneGallery = GalleryModel(data: snapshot.value as! [String : Any])
//                self.galleryList.append(oneGallery)
                
                for case let rest as DataSnapshot in snapshot.children {
                    //                print(snapDict)
                    let snapDict = rest.value as? [String: Any]
                    
                    //                print("name", snapDict!["name"] as? String)
                    print("snapdict")
                    print(snapDict!)
                    //                let oneGallery = GalleryModel(id: rest.key, name: snapDict!["name"] as! String, price: snapDict!["price"] as! String, imageURL: snapDict!["imageURL"] as! String)
                    //                let oneGallery = GalleryModel(data: snapDict!)
                    //                self.galleryList.append(oneGallery)
                    //                for child in snapDict{
                    //
                    //                    //                    let shotKey = snapshot.children.nextObject() as! FIRDataSnapshot
                    //                    print(child.key)
                    //                    //                    if let name = child.value as? [String:AnyObject]{
                    ////                    print(child["name"])
                    //                    let oneGallery = GalleryModel(id: child.key, name: snapDict["name"] as! String, price: snapDict["price"] as! String, imageURL: snapDict["imageURL"] as! String)
                    //                    self.galleryList.append(oneGallery)
                    //                }
                }
                //            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                //                for child in result {
                //                    print(child.key)
                //                    let oneGallery = GalleryModel(id: child.key, name: child["name"], price: child["price"] as! String, imageURL: child!["imageURL"] as! String)
                //                    self.galleryList.append(oneGallery)
                //                }
                //            }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            }
            //        DispatchQueue.main.async {
            //
            //            self.collectionView.reloadData()
            //        }
        }
    
    func loadGallery() { //fix all in scope shortcut key = ctrl + opt + cmd + f
        DataManager.loadGallery { (galleryListFromFirebase) in
            self.galleryList = galleryListFromFirebase
            print("gallery list count load from firebase", self.galleryList.count)
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("selected item", indexPath)
//        dump(galleryList[indexPath.row], name: "dump object")
//        print((galleryList[indexPath.row]))
//
//        galleryList[indexPath.row].printObj("This Text")
        print("clicked on one row collectionview")
        
        if !returnImage {
            let storyboard = UIStoryboard(name: "ChatStoryboard", bundle: nil)
            let chatLogViewController = storyboard.instantiateViewController(identifier: "ChatLog") as! ChatLogViewController
            let guideID = "L8GStyrpxtMy7HOC69CfwWOxlt12"
            let ref = Database.database().reference().child("/users/\(guideID)/")
            ref.observe(.value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                let user = User(
                    id: guideID,
                    name: dictionary["name"]! as! String,
                    email: dictionary["email"]! as! String,
                    profileURL: dictionary["profileURL"]! as! String
                )
                chatLogViewController.user = user
                // self.navigationController?.pushViewController(chatLogViewController, animated: true)
                
                //                guard let stringURL = URL(string: self.galleryList[indexPath.row].imageURL!) else {return}
                //                guard let imageRetrieved = UIImage(data: try! Data(contentsOf: stringURL)) else {return}
                //                self.uploadImageToChat(image: imageRetrieved, toID: guideID)
                
                let imageFromCell = self.collectionView.cellForItem(at: indexPath) as? CollectionViewCell
                if let image = imageFromCell?.imageView.image { //or guard let image = ... else return
                    self.uploadImageToChat(image: image, toID: guideID)
                    //                    imageFromCell?.imageView.sd_setImage
                    self.present(chatLogViewController, animated: true, completion: nil)
                }
            })
            
        }
        
        //https://fluffy.es/3-ways-to-pass-data-between-view-controllers/
        if let delegate = delegate {
            delegate.doSomethingWith(data: galleryList[indexPath.row].imageURL!)
            self.dismiss(animated: true, completion: nil)
//            self.navigationController?.popViewController(animated: true)
        }
    
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "uploadPhoto" {
             let destinationVC = segue.destination as! GalleryUploadPhotoFrameViewController
             // Set any variable in ViewController2
             destinationVC.callbackResult = { result in
             // assign passing data etc..
                print("result received!", result)
                print("gallery after upload", self.galleryList.count)
//                self.collectionView.reloadData()
//                self.loadGallery()
             }
         }
      }
    
    func uploadImageToChat(image: UIImage, toID: String?) {
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

}
