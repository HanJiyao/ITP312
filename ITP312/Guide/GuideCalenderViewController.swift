//
//  GuideCalenderViewController.swift
//  ITP312
//
//  Created by ITP312 on 7/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import FSCalendar

class GuideCalenderViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    @IBOutlet weak var guideCalender: FSCalendar!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMM d"
        return formatter
    }()
    
    var firstDate:Date?
    var lastDate:Date?
    var datesRange: [Date] = []
    var availableDatesRange: [Date] = []
    var guideRole = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guideCalender.dataSource = self
        guideCalender.delegate = self
        guideCalender.allowsMultipleSelection = true
        guideCalender.swipeToChooseGesture.isEnabled = true // Swipe-To-Choose
        if firstDate != nil || lastDate != nil {
            startDateLabel.text = self.formatter.string(from: firstDate!)
            endDateLabel.text = self.formatter.string(from: lastDate!)
        }
        self.availableDatesRange = self.datesRange
        if guideRole {
            for d in datesRange {
                guideCalender.select(d)
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let currentDate = Date().addingTimeInterval(-24*60*60)
        if date < currentDate {
            return false
        } else {
            if guideRole {
                return true
            }
            else
            {
                if self.availableDatesRange.contains(date) {
                    return true
                } else {
                    return false
                }
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if guideRole{
            datesRange.append(date)
            sortAndDisplayDates()
        } else {
            availableDatesRange.removeAll(date)
        }
       
    }

    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if guideRole{
            datesRange.removeAll(date)
            sortAndDisplayDates()
        } else {
            availableDatesRange.append(date)
        }
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {

        if self.datesRange.contains(date) {
            return 1
        }
        return 0
    }
    
    func sortAndDisplayDates() {
        if datesRange.count != 0 {
            datesRange = datesRange.sorted(by: { $0.compare($1) == .orderedAscending })
            availableDatesRange = availableDatesRange.sorted(by: { $0.compare($1) == .orderedAscending })
            startDateLabel.text = self.formatter.string(from:  datesRange.first!)
            endDateLabel.text = self.formatter.string(from: datesRange.last!)
        }
    }
    
    @IBAction func handleBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleSave(_ sender: Any) {
        if datesRange.count == 0 {
            startDateLabel.text = ""
            endDateLabel.text = ""
            let alert = UIAlertController(title: "Sorry", message: "Please choose dates", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                  switch action.style{
                  case .default:
                        print("default")

                  case .cancel:
                        print("cancel")

                  case .destructive:
                        print("destructive")
                  @unknown default:
                    fatalError()
                }}))
            self.present(alert, animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    var callbackClosure: (() -> Void)?
    override func viewWillDisappear(_ animated: Bool) {
        callbackClosure?()
    }
    
}
