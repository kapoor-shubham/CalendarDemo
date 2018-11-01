//
//  ViewController.swift
//  CalendarDemo
//
//  Created by Shubham Kapoor on 30/10/18.
//  Copyright © 2018 Shubham Kapoor. All rights reserved.
//

import UIKit
import JTAppleCalendar
import EventKit
import CalendarKit
import DateToolsSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var fighterImageView: UIImageView!
    @IBOutlet weak var collectionView: JTAppleCalendarView!
    @IBOutlet weak var currentMonthLabel: UILabel!
    
    // Add Event View Properties.
    @IBOutlet weak var addEventView: UIView!
    @IBOutlet weak var addEventHeaderView: UIView!
    @IBOutlet weak var addEventTitleVIew: UIView!
    @IBOutlet weak var addEventTimeView: UIView!
    @IBOutlet weak var addEventAlertView: UIView!
    @IBOutlet weak var addEventNotesView: UIView!
    @IBOutlet weak var addEventSubNotesView: UIView!
    @IBOutlet weak var addEventAddButton: UIButton!
    @IBOutlet weak var addEventCancleButton: UIButton!
    @IBOutlet weak var addEventTitleTextField: UITextField!
    @IBOutlet weak var addEventLocationTextField: UITextField!
    
    var formatter = DateFormatter()
    var calendarDates = ["2018 11 01", "2018 11 05", "2018 11 10", "2018 11 12"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAllViewBorders()
        setEventInCalendar()
        collectionView.scrollToDate(Date())
        formatter.dateFormat = "MMM"
        currentMonthLabel.text = formatter.string(from: Date())
        setUpCalenderView()
    }
    
    func setUpViewsFromCalender(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first?.date
        self.formatter.dateFormat = "MMM"
        currentMonthLabel.text = formatter.string(from: date!)
        fighterImageView.image = UIImage(named: currentMonthLabel.text!)
    }
    
    func setUpCalenderView() {
        collectionView.minimumLineSpacing = 0
        collectionView.minimumInteritemSpacing = 0
    }
    
    func handleCalendarCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CalendarCollectionViewCell else { return }
        
        if cellState.dateBelongsTo == .thisMonth {
            validCell.dateLabel.textColor = UIColor.white
        } else {
            validCell.dateLabel.textColor = UIColor.gray
        }
        
        formatter.timeZone = NSTimeZone.default
        formatter.dateFormat = "yyyy MM dd"
        
        if calendarDates.count != 0 {
            for i in 0...calendarDates.count - 1 {
                if formatter.string(from: cellState.date) == calendarDates[i] {
                    validCell.eventImageView.image = UIImage(named: "currentDateEllipse")
                    validCell.eventImageView.isHidden = false
                }
            }
        }
    }
    
    func setEventInCalendar() {
        
        for i in 0..<calendarDates.count {
            
            formatter.dateFormat = "yyyy MM dd"
            let convertedDate = formatter.date(from: calendarDates[i])
            
            let eventStore = EKEventStore()
            eventStore.requestAccess( to: EKEntityType.event, completion:{(granted, error) in
                if (granted) && (error == nil) {
                    let event = EKEvent(eventStore: eventStore)
                    event.title = "My Event for Date \(self.calendarDates[i])"
                    event.isAllDay = true
                    event.startDate = convertedDate
                    event.endDate = convertedDate
                    event.notes = "Yeah I made it again on \(self.calendarDates[i])!!!"
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    var event_id = ""
                    do{
                        try eventStore.save(event, span: .thisEvent)
                        event_id = event.eventIdentifier
                    }
                    catch let error as NSError {
                        print("json error: \(error.localizedDescription)")
                    }
                    if(event_id != ""){
                        print("event added !")
                    }
                }
            })
        }
    }
    
    @IBAction func addEventAddButtonAction(_ sender: UIButton) {
    }
    
    @IBAction func addEventCancleButtonAction(_ sender: UIButton) {
    }
    
    
    
    func convertDateToString(date: Int64, format: String) -> String {
        return Date().toString(format: format, date: Date(milliseconds: Int64(date)))
    }
}

// MARK: SetUp Add Event View
extension ViewController {
    
    func setAllViewBorders() {
        setBorder(view: addEventView)
        setBorder(view: addEventHeaderView)
        setBorder(view: addEventTitleVIew)
        setBorder(view: addEventTimeView)
        setBorder(view: addEventAlertView)
        setBorder(view: addEventNotesView)
        setBorder(view: addEventSubNotesView)
    }
    
    func setBorder(view: UIView) {
        view.layer.borderColor = UIColor(red: 0/255, green: 92/255, blue: 150/255, alpha: 1).cgColor
        view.layer.borderWidth = 1.0
    }
}

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == addEventTitleTextField && string.count > 0 {
            addEventAddButton.isEnabled = true
        } else {
            addEventAddButton.isEnabled = false
        }
        return true
    }
}

// MARK: - Extention CalendarView DataSource
extension ViewController: JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = NSTimeZone.local
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2017 01 01")
        let endDate = formatter.date(from: "2050 01 01")
        
        let parameters = ConfigurationParameters(startDate: startDate!, endDate: endDate!)
        
        return parameters
    }
}

// MARK: - Extention CalendarView Delegates
extension ViewController: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        guard let _ = view as? CalendarCollectionViewCell else { return }
        handleCalendarCellTextColor(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCollectionViewCell", for: indexPath) as! CalendarCollectionViewCell
        cell.dateLabel.text = cellState.text
        
        cell.currentDateImageView.isHidden = true
        formatter.dateFormat = "yyyy MM dd"
        if formatter.string(from: cellState.date) == formatter.string(from: Date()) {
            cell.currentDateImageView.isHidden = false
            cell.currentDateImageView.image = UIImage(named: "visitEllipse")
        } else {
            cell.currentDateImageView.isHidden = true
        }
        handleCalendarCellTextColor(view: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        if collectionView.cellStatus(for: Date()) != nil {
            print(Date())
        }
        setUpViewsFromCalender(from: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        print("Current Selected Date is \(date)")
        
        addEventView.isHidden = false
        
//        let calendarListViewController = CalendarListViewController()
//        self.present(calendarListViewController, animated: true, completion: nil)
        
//        if let url = URL(string: "calshow:\(date.timeIntervalSinceReferenceDate)") {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
    }
}

extension Date {
    /* Converts a date into String with given date format */
    func toString(format: String, date: Date ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone.default
        return dateFormatter.string(from: date)
    }
    
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    /* Converts EPOCH Time to Date */
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}
