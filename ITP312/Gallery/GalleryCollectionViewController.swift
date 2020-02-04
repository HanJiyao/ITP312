//
//  GalleryCollectionViewController.swift
//  ITP312
//
//  Created by tyr on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase


class GalleryCollectionViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var galleryList:[GalleryModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Photo frames"
        print("view did load")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
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
        print(onePhotoFrame.name)
        
        Storage.storage().reference(forURL: onePhotoFrame.imageURL!).getData(maxSize: 2000000) { (data, error) in
            //https://stackoverflow.com/questions/54029490/firebase-storage-to-uiimageview
            print("data", data)
            guard let imageData = data, error == nil else {
                print("error", error)
                return
            }
            print("image data", imageData)
           
            cell.displayContent(image: UIImage(data: imageData)!, price: onePhotoFrame.price!)

        }
        
            //cell.displayContent(image: UIImage(data: url!), name: onePhotoFrame.name)
        
//        cell.displayContent(image: UIImage(named: onePhotoFrame!.imageURL), name: onePhotoFrame.name)

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
    
    //https://medium.com/yay-its-erica/creating-a-collection-view-swift-3-77da2898bb7c
    func loadData() {
        print("loading data")
        let ref = Database.database().reference()
        ref.child("photoframe").observe(.value) { (snapshot) in
            self.galleryList = []
            //            if let snapDict = snapshot.children as? DataSnapshot {
            for case let rest as DataSnapshot in snapshot.children {
                //                print(snapDict)
                let snapDict = rest.value as? [String: Any]
                
                print("name", snapDict!["name"] as? String)
                let oneGallery = GalleryModel(id: rest.key, name: snapDict!["name"] as! String, price: snapDict!["price"] as! String, imageURL: snapDict!["imageURL"] as! String)
                self.galleryList.append(oneGallery)
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
            self.collectionView.reloadData()

        }
//        DispatchQueue.main.async {
//
//            self.collectionView.reloadData()
//        }
    }
    
}
