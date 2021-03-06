//
//  TableViewController.swift
//  SDDP_Project_JR
//
//  Created by Jia Rong on 21/1/20.
//  Copyright © 2020 Jia Rong. All rights reserved.
//

import UIKit
import Firebase

class PlanGlobalData: NSObject {
    static let shared: PlanGlobalData = PlanGlobalData()
    var planName = ""
    var countryName = ""
    var planId = ""
}

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    

    @IBOutlet weak var TableView: UITableView!
    var databaseHandle:DatabaseHandle?
    
    var storePlanName: String?
    var storeCountryName: String?
    var storePlanId: String?
    // Create array for plans
    var planList = [Plan]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TableView.delegate = self
        TableView.dataSource = self

        // readPlanData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        readPlanData()
        
        
    }
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button clicked")
        performSegue(withIdentifier: "toCreatePlanVC", sender: nil)
        
        
    }
    
    
    
    func readPlanData(){
        self.planList = []
        
        // Do any additional setup after loading the view.
        let username = Auth.auth().currentUser?.uid
        
        // Create database reference
        let ref = Database.database().reference()

        ref.child("travelPlans").observeSingleEvent(of: .value) {snapshot in
            // Get all children of travelPlans in database
            for case let rest as DataSnapshot in snapshot.children {
                // Put all values of children into dictionary
                let restDict = rest.value as? [String: Any]
                let thisUser = restDict!["user"] as? String
                // Store values into list if it belongs to current user
                if (thisUser == username) {
                    let thisPlanName = restDict!["planName"] as? String
                    let thisCountry = restDict!["country"] as? String
                    let fromDate = restDict!["fromDate"] as? String
                    let toDate = restDict!["toDate"] as? String
                    let planId = restDict!["planId"] as? String
                    let thisPlan = Plan(planName: thisPlanName, country: thisCountry!, user: thisUser!, fromDate: fromDate!, toDate: toDate!, planId: planId!)
                    print("each plan " ,thisPlan.planName!)
                    self.planList.append(thisPlan)
                    
                }
            }
            print("complete plan list of this user = " ,self.planList)
            
            for plan in self.planList {
                print("Planlistnew = " ,plan.planName!)
            }
            self.TableView.reloadData()
            
            let label = UILabel(frame: CGRect(x: 80, y: 250, width: 200, height: 20))
            label.textAlignment = .left
            label.text = "You have no current plans!"
            label.sizeToFit()
            label.tag = 200
            
            let button = UIButton(frame: CGRect(x: 80, y: 400, width: 220, height: 40))
            button.backgroundColor = .blue
            button.setTitle("Create Plan Now", for: .normal)
            button.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
            button.tag = 100
            
            
            print(self.planList.count)
            if (self.planList.count == 0) {
                self.view.addSubview(button)
                self.view.addSubview(label)
                button.isHidden = false
                label.isHidden = false
            } else {
                if let btn = self.view.viewWithTag(100) {
                    btn.removeFromSuperview()
                }
                if let lbl = self.view.viewWithTag(200) {
                    lbl.removeFromSuperview()
                }
         
            }
            

            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.planList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
//        let cell = TableView.dequeueReusableCell(withIdentifier: "planCell", for: indexPath)
//        let p = self.planList[indexPath.row]
//        print("p = " ,p.planName)
//        cell.textLabel?.text = p.planName
        let cell : PlanCell = tableView.dequeueReusableCell(withIdentifier: "planCell", for: indexPath) as! PlanCell
        let p = self.planList[indexPath.row]
        
        var image : UIImageView? = UIImageView(image: UIImage(named: p.country))
        if (image == nil) {
            image = UIImageView(image: UIImage(named: "United States"))
        }
        
        if cell.viewWithTag(99) == nil {
        
            let dynamicView : UIView? = UIView(frame: cell.bounds)
            dynamicView?.removeFromSuperview()
            dynamicView!.backgroundColor = UIColor.clear
            dynamicView!.addSubview(image!)
            
            let transpView = UIView(frame: cell.bounds)
            transpView.removeFromSuperview()
            transpView.backgroundColor = UIColor.white
            transpView.backgroundColor = transpView.backgroundColor!.withAlphaComponent(0.3)
            
//            let planNameLabel = UILabel(frame: CGRect(x: 20, y: 20, width: 50, height: 200))
//            planNameLabel.text = p.planName
//            planNameLabel.font = UIFont(name: "Helvetica-Bold", size: 18.0)
//            planNameLabel.textColor = UIColor.white
//            planNameLabel.sizeToFit()
//            let destinationNameLabel = UILabel(frame: CGRect(x: 20, y: cell.bounds.minY + 60, width: 50, height: 200))
//            destinationNameLabel.text = p.country
//            destinationNameLabel.font = UIFont(name: "Helvetica-Bold", size: 18.0)
//            destinationNameLabel.textColor = UIColor.white
//            destinationNameLabel.sizeToFit()
//            let dateLabel = UILabel(frame: CGRect(x: 20, y: cell.bounds.minY + 100, width: 50, height: 200))
//            dateLabel.text = "From " + p.fromDate + " to " + p.toDate
//            dateLabel.font = UIFont(name: "Helvetica-Bold", size: 18.0)
//            dateLabel.textColor = UIColor.white
//            dateLabel.sizeToFit()
            
            
//            transpView.addSubview(planNameLabel)
//            transpView.addSubview(destinationNameLabel)
//            transpView.addSubview(dateLabel)
//            cell.bringSubviewToFront(planNameLabel)
//            cell.bringSubviewToFront(destinationNameLabel)
//            cell.bringSubviewToFront(dateLabel)
            
            dynamicView?.tag = 99
            
            dynamicView!.addSubview(transpView)
            cell.addSubview(dynamicView!)
        }
//        cell.addSubview(planNameLabel)
        
        cell.backgroundView = image
        cell.planNameLabel.text = p.planName
//        cell.planNameLabel.isHidden = true
        cell.destinationNameLabel.text = p.country
//        cell.destinationNameLabel.isHidden = true
        cell.dateLabel.text = p.fromDate + " to " + p.toDate
//        cell.dateLabel.isHidden = true
        cell.planNameLabel.sizeToFit()
        cell.destinationNameLabel.sizeToFit()
        cell.dateLabel.sizeToFit()
        cell.planNameLabel.font = UIFont(name: "Helvetica-Bold", size: 18.0)
        cell.destinationNameLabel.font = UIFont(name: "Helvetica-Bold", size: 18.0)
        cell.dateLabel.font = UIFont(name: "Helvetica-Bold", size: 18.0)
        cell.planNameLabel.layer.zPosition = 2
        self.view.bringSubviewToFront(cell.planNameLabel)
        self.view.bringSubviewToFront(cell.destinationNameLabel)
        self.view.bringSubviewToFront(cell.dateLabel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let planID = planList[indexPath.row].planId
            
            Database.database().reference(withPath: "travelPlans").queryOrdered(byChild: "planId").queryEqual(toValue: planID).observe(.value, with: { (snapshot) in
                if let travelPlans = snapshot.value as? [String: [String: AnyObject]] {
                    for (key, _) in travelPlans {
                            FirebaseDatabase.Database.database().reference(withPath: "travelPlans").child(key).removeValue()
                    }
                }
            })
            planList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    
    // Handle click on row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        storePlanName = self.planList[indexPath.row].planName
        storeCountryName = self.planList[indexPath.row].country
        storePlanId = self.planList[indexPath.row].planId
        GlobalData.shared.planId = storePlanId!
        GlobalData.shared.countryName = storeCountryName!
        PlanGlobalData.shared.planId = storePlanId!
        PlanGlobalData.shared.countryName = storeCountryName!
        PlanGlobalData.shared.planName = storePlanName!
        self.performSegue(withIdentifier: "TableToCellData", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "TableToCellData") {
            let tableToCellVC = segue.destination as! PlanCellDataController
            tableToCellVC.selectedPlanName = storePlanName
            tableToCellVC.selectedCountry = storeCountryName
            tableToCellVC.planId = storePlanId
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


