//
//  ShowLocationViewController.swift
//  ITP312
//
//  Created by Jia Rong on 10/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class ShowLocationViewController: UIViewController {

    @IBOutlet weak var MapView: MKMapView!
    var locationId: String?
    var planId: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ref = Database.database().reference()
        
        print("location id" ,self.locationId!)
        // Retrieve all locations based on plan ID
        ref.child("LocationInfo").child(self.planId!).queryOrdered(byChild: "locationId").queryEqual(toValue: self.locationId).observeSingleEvent(of: .value, with: { snap in
            for case let rest as DataSnapshot in snap.children {
            let dict = rest.value as? [String: Any]
            print("dict: " ,dict!)
            let latitude: CLLocationDegrees = dict!["latitude"] as! CLLocationDegrees
            let longitude: CLLocationDegrees = dict!["longitude"] as! CLLocationDegrees
            let searchLocationName: String? = dict!["searchLocationName"] as? String
            let locationDesc: String? = dict!["locDescription"] as? String
            
            
            // Reset annotations
            let annotations = self.MapView.annotations
            self.MapView.removeAnnotations(annotations)
            
            // Create annotation
            let annotation = MKPointAnnotation()
            annotation.title = locationDesc!
            annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            
            self.MapView.addAnnotation(annotation)
                        
            // Zooming onto coordinate
            let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            self.MapView.setRegion(region, animated: true)
            }
    })
       
    
            
        

        // Do any additional setup after loading the view.
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
