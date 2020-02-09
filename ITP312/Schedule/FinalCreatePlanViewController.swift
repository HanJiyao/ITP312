//
//  FinalCreatePlanViewController.swift
//  ITP312
//
//  Created by Jia Rong on 9/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class GlobalData: NSObject {
    static let shared: GlobalData = GlobalData()
    var countryName = ""
    var planId = ""
}
var globalVarStoreCountry = ""


class FinalCreatePlanViewController: UIViewController {
    
    
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var PlanNameText: UITextField!
    
    
    var countryName: String?
    var toDate: String?
    var fromDate: String?
    var planId: String?
    var planCountNumber: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ImageView.image = UIImage(named: "paper-plane")
    }
    
    @IBAction func FinishCreatePlan(_ sender: Any) {
        createData()
        
        
        // Calculate Id for plan
        // If there are no plans, assign plan id as 1
        // If there are plans found, assign them +1
        
            
        // Load existing data into variables
            
        
        
    }
    @IBAction func SaveAndReturnClick(_ sender: Any) {
    }
    
    func createData() {
        // Get current logged in user
        let username = Auth.auth().currentUser?.uid
            
        // Set database reference
        let ref = Database.database().reference()
            
        
        // Get count of children
        ref.child("travelPlans").observeSingleEvent(of: .value) {snapshot in
        // Get all children of travelPlans in database
            print("snapshot children: " ,snapshot.childrenCount)
            let childrenCount = snapshot.childrenCount
            self.planCountNumber = Int(childrenCount)
            if (self.planCountNumber == nil) {
                self.planId = "plan1"
                print("nil")
            } else {
                print(self.planCountNumber!)
                var newId : Int?
                newId = self.planCountNumber! + 1
                let toStringId = String(newId!)
                self.planId = "plan" + toStringId
                print("plan id: " , self.planId!)
            }
            let thisPlanName = self.PlanNameText.text
            let thisCountryName = self.countryName
            let thisFromDate = self.fromDate
            let thisToDate = self.toDate
            let thisPlanId = self.planId
            
            print(thisPlanName!)
            print(thisCountryName!)
            print(thisFromDate!)
            print(thisToDate!)
            print(thisPlanId!)
            self.planId = thisPlanId!
            GlobalData.shared.countryName = thisCountryName!
            GlobalData.shared.planId = thisPlanId!
            
                
            let plan = Plan(planName: thisPlanName!, country: thisCountryName!, user: username!, fromDate: thisFromDate!, toDate: thisToDate!, planId: thisPlanId!)
            print("plan class = " ,plan)
            let planInfoDict = ["planName" : plan.planName,
                "country" : plan.country,
                "user" : plan.user,
                "fromDate": plan.fromDate,
                "toDate": plan.toDate,
                "planId": plan.planId]
            print(planInfoDict)
            ref.child("travelPlans").childByAutoId().setValue(planInfoDict)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "FinalVCToLocationVC") {
            let locationVC = segue.destination as! AddLocationMapViewController
        }
    }

}
