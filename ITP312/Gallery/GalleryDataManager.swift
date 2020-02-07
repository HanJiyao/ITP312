//
//  GalleryDataManager.swift
//  ITP312
//
//  Created by tyr on 6/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

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
}

