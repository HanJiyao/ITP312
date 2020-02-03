//
//  TableViewController.swift
//  SDDP_Project_JR
//
//  Created by Jia Rong on 21/1/20.
//  Copyright © 2020 Jia Rong. All rights reserved.
//

import UIKit
import Firebase

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    

    @IBOutlet weak var TableView: UITableView!
    var databaseHandle:DatabaseHandle?
    
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
    
    func readPlanData(){
        // Do any additional setup after loading the view.
        var username = Auth.auth().currentUser?.uid
        
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
                    var thisPlanName = restDict!["planName"] as? String
                    var thisCountry = restDict!["country"] as? String
                    var fromDate = restDict!["fromDate"] as? String
                    var toDate = restDict!["toDate"] as? String
                    var thisPlan = Plan(planName: thisPlanName, country: thisCountry!, user: thisUser!, fromDate: fromDate!, toDate: toDate!)
                    print("each plan " ,thisPlan.planName)
                    self.planList.append(thisPlan)
                    
                }
            }
            print("complete plan list of this user = " ,self.planList)
            for plan in self.planList {
                print("Planlistnew = " ,plan.planName)
            }
            self.TableView.reloadData()
            
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
        cell.planNameLabel.text = p.planName
        cell.destinationNameLabel.text = p.country
        cell.dateLabel.text = p.fromDate + " to " + p.toDate
        cell.planNameLabel.sizeToFit()
        cell.destinationNameLabel.sizeToFit()
        cell.dateLabel.sizeToFit()
        cell.backgroundView = UIImageView(image: UIImage(named: "newyork"))
        
        return cell
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
