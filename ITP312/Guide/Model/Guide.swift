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
    var fromDate: String?
    var toDate:String?
    var guideID: String?
    var guideName: String?
    var booked: Bool?
    var offerID: String?
    
    // init as a whole dictionary so that the value can be flexiable
    init (dictionary:[String:AnyObject]) {
        super.init()
        service = dictionary["service"] as? String
        imgURL = dictionary["imgURL"] as? String
        desc = dictionary["desc"] as? String
        fromDate = dictionary["fromDate"] as? String
        toDate = dictionary["toDate"] as? String
        guideID = dictionary["guideID"] as? String
        guideName = dictionary["guideName"] as? String
        booked = dictionary["booked"] as? Bool
        offerID = dictionary["offerID"] as? String
    }
    
}
