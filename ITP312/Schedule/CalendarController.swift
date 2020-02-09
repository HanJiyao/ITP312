//
//  CalendarController.swift
//  ITP312
//
//  Created by Jia Rong on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Foundation
import FSCalendar

class CalendarController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    var selectedDates: [String] = []
    var planName: String?
    var countryName: String?

    fileprivate let gregorian = Calendar(identifier: .gregorian)
        fileprivate let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            return formatter
        }()
        
        fileprivate weak var calendar: FSCalendar!
        fileprivate weak var eventLabel: UILabel!
        
        // MARK:- Life cycle
        
        override func loadView() {
            
            let view = UIView(frame: UIScreen.main.bounds)
            view.backgroundColor = UIColor.white
            self.view = view
            
            let height: CGFloat = UIDevice.current.model.hasPrefix("iPad") ? 400 : 300
            let calendar = FSCalendar(frame: CGRect(x: 0, y: self.navigationController!.navigationBar.frame.maxY, width: view.frame.size.width, height: height))
            calendar.dataSource = self
            calendar.delegate = self
            calendar.allowsMultipleSelection = true
            view.addSubview(calendar)
            self.calendar = calendar
            
            calendar.calendarHeaderView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
            calendar.calendarWeekdayView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
            calendar.appearance.eventSelectionColor = UIColor.white
            calendar.appearance.eventOffset = CGPoint(x: 0, y: -7)
            calendar.today = nil // Hide the today circle
            calendar.register(DIYCalendarCell.self, forCellReuseIdentifier: "cell")
    //        calendar.clipsToBounds = true // Remove top/bottom line
            
            calendar.swipeToChooseGesture.isEnabled = true // Swipe-To-Choose
            
            let scopeGesture = UIPanGestureRecognizer(target: calendar, action: #selector(calendar.handleScopeGesture(_:)));
            calendar.addGestureRecognizer(scopeGesture)
            
            
            let label = UILabel(frame: CGRect(x: 0, y: calendar.frame.maxY + 10, width: self.view.frame.size.width, height: 50))
            label.textAlignment = .center
            label.font = UIFont.preferredFont(forTextStyle: .subheadline)
            self.view.addSubview(label)
            self.eventLabel = label
            
            let button = UIButton(frame: CGRect(x: 30, y: 400, width: 320, height: 40))
            button.backgroundColor = .blue
            button.setTitle("Confirm Date", for: .normal)
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            self.view.addSubview(button)
            
        }
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button clicked")
        performSegue(withIdentifier: "CalendarReturnToComplete", sender: nil)
    }
    
    
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            self.title = "Calendar"
           
            // Uncomment this to perform an 'initial-week-scope'
            // self.calendar.scope = FSCalendarScopeWeek;
            
           
            
        }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if (segue.identifier == "CalendarReturnToComplete") {
                let displayPV = segue.destination as! SetDateForPlanViewController
                displayPV.countryName = countryName
                displayPV.selectedDates = selectedDates
            }
        }
        
        // MARK:- FSCalendarDataSource
        
        func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
            let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
            return cell
        }
        
        func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
            self.configure(cell: cell, for: date, at: position)
        }
        
        func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
            if self.gregorian.isDateInToday(date) {
                return "!"
            }
            return nil
        }
        
        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            return 2
        }
        
        // MARK:- FSCalendarDelegate
        
        func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
            self.calendar.frame.size.height = bounds.height
            self.eventLabel.frame.origin.y = calendar.frame.maxY + 10
        }
        
        func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition)   -> Bool {
            return monthPosition == .current
        }
        
        func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
            return monthPosition == .current
        }
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            let date = self.formatter.string(from: date)
            print("did select date \(date)")
            selectedDates.append(date)
            self.configureVisibleCells()
        }
        
        func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
            print("did deselect date \(self.formatter.string(from: date))")
            self.configureVisibleCells()
        }
        
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
            if self.gregorian.isDateInToday(date) {
                return [UIColor.orange]
            }
            return [appearance.eventDefaultColor]
        }
        
        // MARK: - Private functions
        
        private func configureVisibleCells() {
            calendar.visibleCells().forEach { (cell) in
                let date = calendar.date(for: cell)
                let position = calendar.monthPosition(for: cell)
                self.configure(cell: cell, for: date!, at: position)
            }
        }
        
        private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
            
            let diyCell = (cell as! DIYCalendarCell)
            // Custom today circle
            diyCell.circleImageView.isHidden = !self.gregorian.isDateInToday(date)
            // Configure selection layer
            if position == .current {
                
                var selectionType = SelectionType.none
                
                if calendar.selectedDates.contains(date) {
                    let previousDate = self.gregorian.date(byAdding: .day, value: -1, to: date)!
                    let nextDate = self.gregorian.date(byAdding: .day, value: 1, to: date)!
                    if calendar.selectedDates.contains(date) {
                        if calendar.selectedDates.contains(previousDate) && calendar.selectedDates.contains(nextDate) {
                            selectionType = .middle
                        }
                        else if calendar.selectedDates.contains(previousDate) && calendar.selectedDates.contains(date) {
                            selectionType = .rightBorder
                        }
                        else if calendar.selectedDates.contains(nextDate) {
                            selectionType = .leftBorder
                        }
                        else {
                            selectionType = .single
                        }
                    }
                }
                else {
                    selectionType = .none
                }
                if selectionType == .none {
                    diyCell.selectionLayer.isHidden = true
                    return
                }
                diyCell.selectionLayer.isHidden = false
                diyCell.selectionType = selectionType
                
            } else {
                diyCell.circleImageView.isHidden = true
                diyCell.selectionLayer.isHidden = true
            }
        }
        
    }
