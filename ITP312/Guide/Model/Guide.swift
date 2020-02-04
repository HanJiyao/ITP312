//
//  Guide.swift
//  ITP312
//
//  Created by ITP312 on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class Guide: NSObject {
    
    var service: String?
    var imgURL: String?
    var desc: String?
    var date: String?
    var guideID: String?
    
    // init as a whole dictionary so that the value can be flexiable
    init (dictionary:[String:AnyObject]) {
        super.init()
        service = dictionary["service"] as? String
        imgURL = dictionary["imgURL"] as? String
        desc = dictionary["desc"] as? String
        date = dictionary["date"] as? String
        guideID = dictionary["guideID"] as? String
    }
    
}
