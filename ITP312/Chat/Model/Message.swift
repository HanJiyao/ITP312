//
//  Message.swift
//  ITP312
//
//  Created by Han Jiyao on 17/1/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {

    var fromID: String?
    var toID: String?
    var timestamp: NSNumber?
    var text: String?
    var imageURL: String?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    
//    init(fromID:String, toID:String, timestamp:NSNumber, text: String, imageURL:String) {
//        self.fromID = fromID
//        self.toID = toID
//        self.timestamp = timestamp
//        self.text = text
//        self.imageURL = imageURL
//    }
    
    func chatPartnerID() -> String? {
        return fromID == Auth.auth().currentUser?.uid ? toID : fromID
        // if the message send from current user, set display of message from toID
        // else the message is received by user, display who the message sent fromID
    }
    
    
    // init as a whole dictionary so that the value can be flexiable
    init (dictionary:[String:AnyObject]) {
        super.init()
        fromID = dictionary["fromID"] as? String
        toID = dictionary["toID"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        text = dictionary["text"] as? String
        imageURL = dictionary["imageURL"] as? String
        imageHeight = dictionary["imageHeight"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
    }
    
}
