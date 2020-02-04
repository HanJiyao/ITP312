//
//  PlanInfoViewController.swift
//  SDDP_Project_JR
//
//  Created by Jia Rong on 21/1/20.
//  Copyright © 2020 Jia Rong. All rights reserved.
//

// Imports
import UIKit
import Firebase

class PlanInfoViewController: UIViewController {
    
    @IBOutlet weak var countryText: UITextField!
        
    @IBOutlet weak var altMapBtn: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationSubLabel: UILabel!
    @IBOutlet weak var locationImg: UIImageView!
    
    
   
    var countryList: [String] = []
    var planName: String?
    var countryName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        countryText.layer.backgroundColor = (UIColor.white as! CGColor)
//        countryText.layer.borderColor = (UIColor.gray as! CGColor)
//        countryText.layer.borderWidth = 0.0
        
        // Set style of textbox
        countryText.borderStyle = .none
        countryText.layer.backgroundColor = UIColor.white.cgColor

        countryText.layer.masksToBounds = false
        countryText.layer.shadowColor = UIColor.gray.cgColor
        countryText.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        countryText.layer.shadowOpacity = 1.0
        countryText.layer.shadowRadius = 0.0
        
        if planName != nil {
            print(planName!)
        } else {
            print("planName not found")
        }
        // Fill text fields with data
        if countryName != nil {
            print(countryName!)
            locationLabel.text = countryName
            locationLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
            countryText.text = countryName
            locationSubLabel.text = "selected"
            locationSubLabel.font = UIFont.italicSystemFont(ofSize: 12.0)
            locationSubLabel.textColor = UIColor.gray
            locationImg.image = UIImage(named: "newyork")
            
        } else {
            print("country not set yet")
            countryText.placeholder = "Please select a country!"
            locationLabel.text = "No location selected"
            locationSubLabel.text = ""
        }
        
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
    
    @IBAction func btnSaveData(_ sender: Any) {
        
        
    }
    
    // Pass data to next controller for further processing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "gotoMapView") {
            let displayMV = segue.destination as! MapViewController
            displayMV.planName = planName
        }
        if (segue.identifier == "toDateController") {
            let dateVC = segue.destination as! SetDateForPlanViewController
            if planName != nil {
                dateVC.planName = planName
            }
            if countryName != nil {
                dateVC.countryName = countryName
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
