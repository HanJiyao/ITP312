//
//  PlanCalendarViewController.swift
//  ITP312
//
//  Created by Jia Rong on 11/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import FSCalendar

class PlanCalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    var selectedDates: [String] = []
    var planName: String?
    var countryName: String?
    @IBOutlet weak var FSCalendar: FSCalendar!
    
    var selectedDateFirst: Date?
    var selectedDateSecond: Date?
    
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        FSCalendar.delegate = self
        FSCalendar.dataSource = self
        FSCalendar.allowsMultipleSelection = true

        // Do any additional setup after loading the view.
    }
    
    @IBAction func CalendarFinishClick(_ sender: Any) {
        print("country name right now: " ,GlobalData.shared.countryName)
        performSegue(withIdentifier: "CalendarReturnToComplete", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "CalendarReturnToComplete") {
            let displayPV = segue.destination as! SetDateForPlanViewController
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
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(self.formatter.string(from: date))
        if (self.selectedDateFirst == nil && self.selectedDateSecond == nil) {
            self.selectedDateFirst = date
            self.FSCalendar.select(date)
            self.selectedDates.append(self.formatter.string(from: selectedDateFirst!))
            print(selectedDates)
            return
        }
        if (self.selectedDateFirst != nil && self.selectedDateSecond == nil) {
            self.selectedDateSecond = date
            self.FSCalendar.select(date)
            
            self.selectedDates.append(self.formatter.string(from: selectedDateSecond!))
            print(selectedDates)
            return
        }
        if (self.selectedDateFirst != nil && self.selectedDateSecond != nil) {
            self.FSCalendar.deselect(selectedDateFirst!)
            self.FSCalendar.deselect(selectedDateSecond!)
            self.selectedDateFirst = nil
            self.selectedDateSecond = nil
            self.selectedDates = []
            print(selectedDates)
            return
        }
        
        
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
//        print(self.formatter.string(from: date))
//        self.FSCalendar.deselect(date)
//        if (date == selectedDateFirst!) {
//            selectedDates.removeFirst()
//        } else {
//            selectedDates.removeLast()
//        }
        
    }

}
