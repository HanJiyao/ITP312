//
//  CreatePlanViewController.swift
//  SDDP_Project_JR
//
//  Created by Jia Rong on 20/1/20.
//  Copyright © 2020 Jia Rong. All rights reserved.
//

import UIKit
import Firebase

class CreatePlanViewController: UIViewController {

    @IBOutlet weak var planNameText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
    }
    
    @IBAction func btnPress(_ sender: Any) {
        
        // Create class object for plan
       
        
        // set username (to be dynamically retrieved)
        let username = Auth.auth().currentUser?.uid
        
        // set database reference
        let ref = Database.database().reference()
        
        
        // get text
        var planName: String?
        if let text = planNameText.text {
            planName = text
        } else {
            planName = "none"
        }
        
        // ref.child(username! + "/" + planName!).setValue(planName!)
        
        let plan = Plan(planName: planName, country: "USA", user: username!, fromDate: "1/1/2020", toDate: "1/3/2020")
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
        if segue.destination is PlanInfoViewController {
            let vc = segue.destination as? PlanInfoViewController
            vc?.planName = planNameText.text
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
