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
     
    }

    // Pass planName data to next controller for further processing
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
