//
//  MapViewController.swift
//  SDDP_Project_JR
//
//  Created by Jia Rong on 3/2/20.
//  Copyright © 2020 Jia Rong. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var MVController: MKMapView!
    @IBOutlet weak var searchTextField: SearchTextField!
    
    var planName: String?
    var countryName: String?
    override func viewDidLoad() {
        super.viewDidLoad()
    
    

        // Do any additional setup after loading the view.
    }

    
    @IBAction func searchTextField(_ sender: SearchTextField) {
    }
    
    @IBAction func searchTextFieldEndEditing(_ sender: Any) {
        
        // Get selected country string
        let countrySelected = searchTextField.text
        countryName = countrySelected
    
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
        searchRequest.naturalLanguageQuery = countrySelected
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            
            activityIndicator.stopAnimating()
            // UIApplication.shared.endIgnoringInteractionEvents()
            
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
                self.MVController.setRegion(region, animated: true)
                
                
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "dataBackToPlanInfo") {
            let planInfoVC = segue.destination as! PlanInfoViewController
            planInfoVC.countryName = countryName
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
