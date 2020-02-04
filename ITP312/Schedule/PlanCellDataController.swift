//
//  PlanCellDataController.swift
//  ITP312
//
//  Created by Jia Rong on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import MapKit

class PlanCellDataController: UIViewController {
    
    // !!! TO DO - Use unique identifier of cell from database !!!
    
    var selectedPlanName: String?
    var selectedCountry: String?
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var MapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
        // Do any additional setup after loading the view.
        
        // TO DO - REPLACE WITH DATABASE QUERY USING UNIQUE IDENTIFIER
        let nameLabelText = "Plan Name: " + selectedPlanName!
        planNameLabel.text = nameLabelText
        let countryLabelText = "Country: " + selectedCountry!
        countryNameLabel.text = countryLabelText
        
        planNameLabel.sizeToFit()
        countryNameLabel.sizeToFit()
        
        let searchRequest = MKLocalSearch.Request()
               searchRequest.naturalLanguageQuery = selectedCountry
               let activeSearch = MKLocalSearch(request: searchRequest)
               activeSearch.start { (response, error) in
                   
                   
                   
                   if response == nil {
                       print("ERROR")
                   } else {
                       
                       // Get coordinates of centroid for search result
                       let latitude = response?.boundingRegion.center.latitude
                       let longitude = response?.boundingRegion.center.longitude
                       
                       // Zooming onto coordinate
                       let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                       let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                       let region = MKCoordinateRegion(center: coordinate, span: span)
                       self.MapView.setRegion(region, animated: true)
                       
                       
                   }
                   
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
