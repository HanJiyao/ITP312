//
//  Plan.swift
//  SDDP_Project_JR
//
//  Created by Jia Rong on 21/1/20.
//  Copyright © 2020 Jia Rong. All rights reserved.
//

import UIKit

class Plan: NSObject {
    var planName: String?
    var country: String
    var user: String
    var fromDate: String
    var toDate: String
    init (planName: String?, country: String, user: String, fromDate: String, toDate: String) {
        self.planName = planName
        self.country = country
        self.user = user
        self.fromDate = fromDate
        self.toDate = toDate
    }
    
}
