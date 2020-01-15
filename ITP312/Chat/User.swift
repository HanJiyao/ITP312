//
//  User.swift
//  ITP312
//
//  Created by ITP312 on 15/1/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var name: String?
    var email: String?
    
    init(name: String, email: String) {
        self.name = name
        self.email = email
    }
    
}
