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
    
    
    
    
    
    
    // !!! TO DO - Use unique identifier of cell from database !!!
    
    var selectedPlanName: String?
    var selectedCountry: String?
    var planId: String?
    var searchLocationName: String?
    var locationList = [Location]()
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    
    @IBOutlet weak var TableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
        // Do any additional setup after loading the view.
        
        
        let nameLabelText = "Plan Name: " + selectedPlanName!
        planNameLabel.text = nameLabelText
        let countryLabelText = "Country: " + selectedCountry!
        countryNameLabel.text = countryLabelText
        
        print(planId)
        planNameLabel.sizeToFit()
        countryNameLabel.sizeToFit()
        let ref = Database.database().reference()
        ref.child("LocationInfo").observeSingleEvent(of: .value) {snapshot in
        // Get all children of travelPlans in database
        for case let rest as DataSnapshot in snapshot.children {
            // Put all values of children into dictionary
            let restDict = rest.value as? [String: Any]
            // Store values into list if it belongs to current user
            let thisLocationName = restDict!["searchLocationName"] as? String
            let thisLatitude = restDict!["latitude"] as? CLLocationDegrees
            let thisLongitude = restDict!["longitude"] as? CLLocationDegrees
            let thisLocationId = restDict!["locationId"] as? String
            let thisPlanId = self.planId!
            let thisLocation = Location(latitude: thisLatitude, longitude: thisLongitude, planId: thisPlanId, locationId: thisLocationId, searchLocationName: thisLocationName
            )
            self.locationList.append(thisLocation)
            print(self.locationList , "locationList")
                
            
        }
        
        
        
      
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return self.locationList.count
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell : PlanCell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! PlanCell
          let p = self.locationList[indexPath.row]
          cell.textLabel!.text = p.searchLocationName!
          cell.textLabel?.sizeToFit()
        let image : UIImage = UIImage(named: "location")!

          cell.imageView!.image = image
      
          
    
         
          
          return cell
      }
}
