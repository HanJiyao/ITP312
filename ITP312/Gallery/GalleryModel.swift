//
//  GalleryModel.swift
//  ITP312
//
//  Created by tyr on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import INSPhotoGallery

class GalleryModel: NSObject {
    
    var name: String?
    var price: String?
    var imageURL: String?
    var userID: String?
    var timestamp: String?
    
    init(name: String, price: String, imageURL: String, userID: String, timestamp: String) {
        self.name = name
        self.price = price
        self.imageURL = imageURL
        self.userID = userID
        self.timestamp = timestamp
    }
    
    init(data: [String: Any]) {
        self.name = data["name"] as? String
        self.price = data["price"] as? String
        self.imageURL = data["imageURL"] as? String
        self.userID = data["userID"] as? String
        self.timestamp = data["timestamp"] as? String
    }
    
}

class PhotoModel: NSObject, INSPhotoViewable {
    
    var image: UIImage?
    
    var thumbnailImage: UIImage?
    
    func loadImageWithCompletionHandler(_ completion: @escaping (UIImage?, Error?) -> ()) {
        
    }
    
    func loadThumbnailImageWithCompletionHandler(_ completion: @escaping (UIImage?, Error?) -> ()) {
        
    }
    
    var name: String?
    var country: String?
    var latitude: String?
    var longitude: String?
    var imageURL: String?
    var key: String?
    var attributedTitle: NSAttributedString?
    
    init(name: String, country: String, latitude: String, longitude: String, imageURL: String, key: String) {
        self.name = name
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.imageURL = imageURL
        self.key = key
    }
    
    init(data: [String: Any]) {
        self.name = data["name"] as? String
        self.country = data["country"] as? String
        self.latitude = data["latitude"] as? String
        self.longitude = data["longitude"] as? String
        self.imageURL = data["imageURL"] as? String
        self.key = data["key"] as? String
    }
    
}


class FolderModel: NSObject {
    
    var title: String?
    var subtitle: String?
    var image: String?
    var key: String?
    var userID: String?
    
    init(title: String, subtitle: String, image: String, key: String, userID: String) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.key = key
        self.userID = userID
    }
    
    init(data: [String: Any]) {
        self.title = data["title"] as? String
        self.subtitle = data["subtitle"] as? String
        self.image = data["image"] as? String
        self.key = data["key"] as? String
        self.userID = data["userID"] as? String
    }
}

class CardModel: NSObject {
    
    var name: String?
    var country: String?
    var imageURL: String?
    var timestamp: String?
    
    init(data: [String: Any]) {
        self.name = data["name"] as? String
        self.country = data["country"] as? String
        self.imageURL = data["imageURL"] as? String
        self.timestamp = data["timestamp"] as? String
    }
    
}
