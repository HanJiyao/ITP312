//
//  Message.swift
//  ITP312
//
//  Created by Han Jiyao on 17/1/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit

class Message: NSObject {

    var fromID: String?
    var toID: String?
    var timestamp: NSNumber?
    var text: String?
    
    init(fromID:String, toID:String, timestamp:NSNumber, text: String) {
        self.fromID = fromID
        self.toID = toID
        self.timestamp = timestamp
        self.text = text
    }
    
}
