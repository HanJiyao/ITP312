//
//  PlanInfoViewController.swift
//  SDDP_Project_JR
//
//  Created by Jia Rong on 21/1/20.
//  Copyright © 2020 Jia Rong. All rights reserved.
//

import UIKit
// import Firebase

class PlanInfoViewController: UIViewController {
    
    @IBOutlet weak var countryText: UITextField!
    
//    @IBOutlet weak var countryPickerView: UIPickerView!
    
    @IBOutlet weak var toDate: UITextField!
    
    @IBOutlet weak var fromDate: UITextField!
    
   
    var countryList: [String] = []
    var planName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(planName!)
        
        // get countries
        for code in NSLocale.isoCountryCodes {
            let cID = NSLocale.localeIdentifier(fromComponents: [ NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: cID)
            countryList.append(name!)
        }
        print(countryList)
//        self.countryPickerView.delegate = self
//        self.countryPickerView.dataSource = self
        
        
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
