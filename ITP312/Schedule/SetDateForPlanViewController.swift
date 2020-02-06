//
//  SetDateForPlanViewController.swift
//  ITP312
//
//  Created by Jia Rong on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase
import FSCalendar

class SetDateForPlanViewController: UIViewController {
    
    @IBOutlet weak var presentImgView: UIImageView!
    @IBOutlet weak var fromPlaceLabel: UILabel!
    @IBOutlet weak var toPlaceLabel: UILabel!
    @IBOutlet weak var dateSummaryLabel: UILabel!
    @IBOutlet weak var datePlaceholder: UITextField!
    
    var planName: String?
    var countryName: String?
    var fromDate: String?
    var toDate: String?
    var selectedDates: [String] = []
   

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        // Set styles of relevant textfields
       
        datePlaceholder.borderStyle = .none
        datePlaceholder.layer.backgroundColor = UIColor.white.cgColor

        datePlaceholder.layer.masksToBounds = false
        datePlaceholder.layer.shadowColor = UIColor.gray.cgColor
        datePlaceholder.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        datePlaceholder.layer.shadowOpacity = 1.0
        datePlaceholder.layer.shadowRadius = 0.0
            
        presentImgView.image = UIImage(named: "United States")
            
        fromPlaceLabel.text = "Singapore"
        toPlaceLabel.text = countryName
        fromPlaceLabel.font = UIFont.boldSystemFont(ofSize: 22.0)
        toPlaceLabel.font = UIFont.boldSystemFont(ofSize: 22.0)
        fromPlaceLabel.textColor = UIColor.white
        toPlaceLabel.textColor = UIColor.white
        fromPlaceLabel.sizeToFit()
        toPlaceLabel.sizeToFit()
        self.view.sendSubviewToBack(presentImgView)
        
        
        if planName != nil {
            print("Plan name" ,planName!)
        } else {
            print("plan name is nil")
        }
        if !selectedDates.isEmpty {
            print(selectedDates)
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !selectedDates.isEmpty {
            let travelDate = selectedDates[0] + " to " + selectedDates[1]
            dateSummaryLabel.text = travelDate
            dateSummaryLabel.sizeToFit()
            dateSummaryLabel.numberOfLines = 2
            dateSummaryLabel.layoutIfNeeded()
            dateSummaryLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
            dateSummaryLabel.textColor = .white
        }
    }
   
    
    @IBAction func fromDateCalBtn(_ sender: Any) {
        
    }
    
    
    @IBAction func createPlanBtnPress(_ sender: Any) {
        
        // Get current logged in user
        let username = Auth.auth().currentUser?.uid
        
        // Set database reference
        let ref = Database.database().reference()
        
        
        // Load existing data into variables
        
        let thisPlanName = planName
        let thisCountryName = countryName
        var thisFromDate: String?
        var thisToDate: String?
        if !selectedDates.isEmpty {
            thisFromDate = selectedDates[0]
            thisToDate = selectedDates[1]
        }
    
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showCalendar") {
            let displayPV = segue.destination as! CalendarController
            displayPV.planName = planName
            displayPV.countryName = countryName
            displayPV.selectedDates = selectedDates
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
