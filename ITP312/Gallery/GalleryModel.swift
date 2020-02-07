//
//  GalleryModel.swift
//  ITP312
//
//  Created by tyr on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit

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
