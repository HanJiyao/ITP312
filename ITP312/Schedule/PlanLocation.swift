//
//  PlanLocation.swift
//  ITP312
//
//  Created by Jia Rong on 10/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class PlanLocation: NSObject {

    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var planId: String?
    var locationId: String?
    var searchLocationName: String?
    var locDescription: String?

    init (latitude: CLLocationDegrees?, longitude: CLLocationDegrees?, planId: String?, locationId: String?, searchLocationName: String?, locDescription: String?) {
        self.latitude = latitude
        self.longitude = longitude
        self.planId = planId
        self.locationId = locationId
        self.searchLocationName = searchLocationName
        self.locDescription = locDescription
    }
}
