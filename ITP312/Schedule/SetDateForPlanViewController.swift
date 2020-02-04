//
//  SetDateForPlanViewController.swift
//  ITP312
//
//  Created by Jia Rong on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class SetDateForPlanViewController: UIViewController {
    
    @IBOutlet weak var fromDateText: UITextField!
    @IBOutlet weak var toDateField: UITextField!
    @IBOutlet weak var presentImgView: UIImageView!
    @IBOutlet weak var fromPlaceLabel: UILabel!
    @IBOutlet weak var toPlaceLabel: UILabel!
    @IBOutlet weak var dateSummaryLabel: UILabel!
    
    var planName: String?
    var countryName: String?
    var fromDate: String?
    var toDate: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        // Set styles of relevant textfields
        presentImgView.image = UIImage(named: "newyork")
        fromPlaceLabel.text = "Singapore"
        toPlaceLabel.text = countryName
        fromPlaceLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        toPlaceLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        fromPlaceLabel.textColor = UIColor.white
        toPlaceLabel.textColor = UIColor.white
        fromPlaceLabel.sizeToFit()
        toPlaceLabel.sizeToFit()
        self.view.sendSubviewToBack(presentImgView)
        
        
    }
    @IBAction func fromDateComplete(_ sender: Any) {
        dateSummaryLabel.text = fromDateText.text
        fromDate = fromDateText.text
    }
    @IBAction func toDateComplete(_ sender: Any) {
        let currText = dateSummaryLabel.text!
        let newText = currText + " to " + toDateField.text!
        toDate = toDateField.text
        dateSummaryLabel.text = newText
        dateSummaryLabel.sizeToFit()
        dateSummaryLabel.textColor = UIColor.white
        
    }
    
    @IBAction func createPlanBtnPress(_ sender: Any) {
        
        // Get current logged in user
        let username = Auth.auth().currentUser?.uid
        
        // Set database reference
        let ref = Database.database().reference()
        
        
        // Load existing data into variables
        
        let thisPlanName = planName
        let thisCountryName = countryName
        let thisFromDate = fromDate
        let thisToDate = toDate
        
        // ref.child(username! + "/" + planName!).setValue(planName!)
        
        let plan = Plan(planName: thisPlanName!, country: thisCountryName!, user: username!, fromDate: thisFromDate!, toDate: thisToDate!)
        print("plan class = " ,plan)
        let planInfoDict = ["planName" : plan.planName,
            "country" : plan.country,
            "user" : plan.user,
            "fromDate": plan.fromDate,
            "toDate": plan.toDate]
        print(planInfoDict)
        ref.child("travelPlans").childByAutoId().setValue(planInfoDict)
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
