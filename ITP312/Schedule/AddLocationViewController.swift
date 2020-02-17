//
//  AddLocationViewController.swift
//  ITP312
//
//  Created by Jia Rong on 10/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class AddLocationViewController: UIViewController {

    var planId: String?
    @IBOutlet weak var SearchLocationText: SearchLocation!
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var planCountNumber: Int?
    var locationId: String?
    var searchLocationName: String?
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var locDescText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locDescText.borderStyle = .none
        locDescText.layer.backgroundColor = UIColor.white.cgColor

        locDescText.layer.masksToBounds = false
        locDescText.layer.shadowColor = UIColor.gray.cgColor
        locDescText.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        locDescText.layer.shadowOpacity = 1.0
        locDescText.layer.shadowRadius = 0.0

        // Do any additional setup after loading the view.
    }
    
    @IBAction func SearchLocationTextDidEnd(_ sender: Any) {
         let locationSelected = SearchLocationText.text
        print(locationSelected)
        self.searchLocationName = locationSelected!
        
        // UIApplication.shared.beginIgnoringInteractionEvents()
            
        // Loading
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
            
        self.view.addSubview(activityIndicator)
            
        // Create Search Request to query country string
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = locationSelected
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
                
        activityIndicator.stopAnimating()
        // UIApplication.shared.endIgnoringInteractionEvents()
                
        if response == nil {
            print("ERROR")
        } else {
            // Reset annotations
            let annotations = self.MapView.annotations
            self.MapView.removeAnnotations(annotations)
                    
            // Get coordinates of centroid for search result
            let latitude = response?.boundingRegion.center.latitude
            let longitude = response?.boundingRegion.center.longitude
        
            
            // Create annotation
            let annotation = MKPointAnnotation()
            annotation.title = locationSelected
            annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
            self.MapView.addAnnotation(annotation)
                    
            // Zooming onto coordinate
            let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
            let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            self.MapView.setRegion(region, animated: true)
            
            self.latitude = latitude
            self.longitude = longitude
                    
        }
                
        }
            
        }
    @IBAction func ConfirmLocationClick(_ sender: Any) {
        let ref = Database.database().reference()
        
                
            
            // Get count of children
            ref.child("LocationInfo").observeSingleEvent(of: .value) {snapshot in
            // Get all children of travelPlans in database
                print("snapshot children: " ,snapshot.childrenCount)
                let childrenCount = snapshot.childrenCount
                self.planCountNumber = Int(childrenCount)
                if (self.planCountNumber == nil) {
                    self.locationId = "location1"
                    print("nil")
                } else {
                    print(self.planCountNumber!)
                    var newId : Int?
                    newId = self.planCountNumber! + 1
                    let toStringId = String(newId!)
                    self.locationId = "location" + toStringId
                    print("location id: " , self.locationId!)
                }
                
                let thisPlanId = GlobalData.shared.planId
                let thisLatitude = self.latitude
                let thisLongitude = self.longitude
                let thisLocationId = self.locationId
                let thisLocDesc = self.locDescText.text
                
                print(thisPlanId)
                print(thisLatitude!)
                print(thisLongitude!)
                print(thisLocationId!)
                    
                let location = PlanLocation(latitude: thisLatitude!, longitude: thisLongitude!, planId: thisPlanId, locationId: thisLocationId!, searchLocationName: self.searchLocationName!, locDescription: thisLocDesc)
                print("location class = " ,location)
                let locationInfoDict = ["latitude" : location.latitude!,
                                        "longitude" : location.longitude!,
                                        "planId" : location.planId!,
                                        "locationId" : location.locationId!,
                    "searchLocationName" : location.searchLocationName!,
                    "locDescription" : location.locDescription!] as [String : Any]
          
                print(locationInfoDict)
                ref.child("LocationInfo").child(thisPlanId).childByAutoId().setValue(locationInfoDict)
            }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "AddLocReturnViewLocVC") {
            let PlanCellVC = segue.destination as! PlanCellDataController
            if (PlanGlobalData.shared.planId != "") {
                PlanCellVC.planId = PlanGlobalData.shared.planId
                PlanCellVC.selectedPlanName = PlanGlobalData.shared.planName
                PlanCellVC.selectedCountry = PlanGlobalData.shared.countryName
            } else {
                PlanCellVC.planId = GlobalData.shared.planId
                PlanCellVC.selectedPlanName = PlanGlobalData.shared.planName
                PlanCellVC.selectedCountry = GlobalData.shared.countryName
            }
        }
    }
    
    
    }
   
  

    

 
