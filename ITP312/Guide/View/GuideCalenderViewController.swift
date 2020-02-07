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

    
    @IBOutlet weak var calender: FSCalendar!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private var firstDate:Date?
    private var lastDate:Date?
    private var datesRange: [Date]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calender.dataSource = self
        calender.delegate = self
        calender.allowsMultipleSelection = true
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // nothing selected:
        if firstDate == nil {
            firstDate = date
            datesRange = [firstDate!]
            startDateLabel.text = self.formatter.string(from:  date)
            return
        }

        // only first date is selected:
        if firstDate != nil && lastDate == nil {
            // handle the case of if the last date is less than the first date:
            if date <= firstDate! {
                calendar.deselect(firstDate!)
                firstDate = date
                datesRange = [firstDate!]
                return
            }

            let range = datesRange(from: firstDate!, to: date)

            lastDate = range.last
            endDateLabel.text = self.formatter.string(from: range.last!)

            for d in range {
                calendar.select(d)
            }

            datesRange = range

            return
        }

        // both are selected:
        if firstDate != nil && lastDate != nil {
            for d in calendar.selectedDates {
                calendar.deselect(d)
            }

            lastDate = nil
            firstDate = nil
            datesRange = []
        }
    }

    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if firstDate != nil && lastDate != nil {
            for d in calendar.selectedDates {
                calendar.deselect(d)
            }
            lastDate = nil
            firstDate = nil
            datesRange = []
        }
    }
    
    func datesRange(from: Date, to: Date) -> [Date] {
        // in case of the "from" date is more than "to" date,
        // it should returns an empty array:
        if from > to { return [Date]() }

        var tempDate = from
        var array = [tempDate]

        while tempDate < to {
            tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
            array.append(tempDate)
        }
        return array
    }
    
    @IBAction func handleBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
