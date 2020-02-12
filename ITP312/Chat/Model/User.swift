//
//  User.swift
//  ITP312
//
//  Created by ITP312 on 15/1/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var id: String?
    var name: String?
    var email: String?
    var profileURL: String?
    
    init(id:String, name: String, email: String, profileURL: String) {
        self.id = id
        self.name = name
        self.email = email
        self.profileURL = profileURL
    }
    
}
