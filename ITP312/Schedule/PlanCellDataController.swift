//
//  PlanCellDataController.swift
//  ITP312
//
//  Created by Jia Rong on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class PlanCellDataController: UIViewController, UITableViewDelegate, UITableViewDataSource {
        
    var selectedPlanName: String?
    var selectedCountry: String?
    var planId: String?
    var searchLocationName: String?
    var locationList = [PlanLocation]()
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    
    var selectedLocationId: String?
    
    @IBOutlet weak var TableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        TableView.delegate = self
        TableView.dataSource = self
        
        
        // Do any additional setup after loading the view.
        
        
        let nameLabelText = selectedPlanName!
        planNameLabel.text = nameLabelText
        planNameLabel.textColor = UIColor.gray
        planNameLabel.font = UIFont(name:"Helvetica-Bold", size: 20.0)
        let countryLabelText = selectedCountry!
        countryNameLabel.text = countryLabelText
        countryNameLabel.textColor = UIColor.blue
        countryNameLabel.font = UIFont(name:"Helvetica", size: 18.0)
        
        print(planId)
        planNameLabel.sizeToFit()
        countryNameLabel.sizeToFit()
        let ref = Database.database().reference()
     
        // Get user value
       
        ref.child("LocationInfo").child(planId!).observeSingleEvent(of: .value) {snapshot in
        // Get all children of travelPlans in database
            print("snapshot children count " , snapshot.childrenCount)
        for case let rest as DataSnapshot in snapshot.children {
            
            // Put all values of children into dictionary
            let restDict = rest.value as? [String: Any]
            print("restdict : " ,restDict)
            // Store values into list if it belongs to current user
            let thisLocationName = restDict!["searchLocationName"] as? String
            let thisLatitude = restDict!["latitude"] as? CLLocationDegrees
            let thisLongitude = restDict!["longitude"] as? CLLocationDegrees
            let thisLocationId = restDict!["locationId"] as? String
            let thisPlanId = self.planId!
            let thisLocDescription = restDict!["locDescription"] as? String
            let thisLocation = PlanLocation(latitude: thisLatitude, longitude: thisLongitude, planId: thisPlanId, locationId: thisLocationId, searchLocationName: thisLocationName, locDescription: thisLocDescription
            )
            self.locationList.append(thisLocation)
            print(self.locationList , "locationList")
                
            
        }
        self.TableView.reloadData()

        
        }
    
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("return locationList tableview: " ,self.locationList.count)
        return self.locationList.count
    }
      
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : PlanLocationCell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! PlanLocationCell
        let p = self.locationList[indexPath.row]
        cell.locationTitle.text = p.locDescription!
        cell.locationTitle.sizeToFit()
        cell.locationSubtitle.text = p.searchLocationName!
        cell.locationSubtitle.sizeToFit()
        
        
        let image : UIImage = UIImage(named: "location")!
        cell.locationIcon.image = image
          
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLocationId = self.locationList[indexPath.row].locationId
        self.performSegue(withIdentifier: "showMapLocationVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showMapLocationVC") {
            let showMapLocationVC = segue.destination as! ShowLocationViewController
            showMapLocationVC.locationId = self.selectedLocationId
            showMapLocationVC.planId = self.planId
    
            
        }
    }
    
    
}
