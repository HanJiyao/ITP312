//
//  GalleryModel.swift
//  ITP312
//
//  Created by tyr on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit

class GalleryModel: NSObject {
    
    var id: String?
    var name: String?
    var price: String?
    var imageURL: String?
    
    init(id:String, name: String, price: String, imageURL: String) {
        self.id = id
        self.name = name
        self.price = price
        self.imageURL = imageURL
    }
    
}
