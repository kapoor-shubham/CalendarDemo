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
    import UserNotifications
    
    class ViewController: UIViewController, EventDataSource, DayViewDelegate {
        func dayViewDidLongPressTimelineAtHour(_ hour: Int) {
            print(hour)
        }
        
        
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
        @IBOutlet weak var allDayEventSwitch: UISwitch!
        @IBOutlet weak var eventNotesTextView: UITextView!
        @IBOutlet weak var endTextField: UITextField!
        @IBOutlet weak var startTextField: UITextField!
        @IBOutlet weak var addEventAlertSwitch: UISwitch!
        
        
        // Event List View Properties.
        @IBOutlet weak var eventListContainerView: UIView!
        @IBOutlet weak var eventListHeaderView: UIView!
        @IBOutlet weak var eventListHeaderDateLabel: UILabel!
        @IBOutlet weak var eventListView: UIView!
        @IBOutlet weak var eventListFooterLabel: UILabel!
        
        // DatePicker View Properties.
        @IBOutlet weak var pickerHeaderView: UIView!
        @IBOutlet weak var datePicker: UIDatePicker!
        
        var events = [Event]()
        var formatter = DateFormatter()
        var customTimeLineView = TimelineView()
        var eventCalender = "Calendar"
        var userSelectedDate = Date()
        var visibleMonthEventDates = [String]()

        var colors = [UIColor.blue, UIColor.yellow, UIColor.green, UIColor.red]
        
        var currentStyle = SelectedStyle.Dark
        let dayVC = DayViewController()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Request for Local Notificaton Authorisation
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
                
            })
            
            UIApplication.shared.applicationIconBadgeNumber = 0

            setAllViewBorders()
            pickerHeaderView.isHidden = true
            datePicker.isHidden = true
            datePicker.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
            collectionView.scrollToDate(Date())
            formatter.dateFormat = "MMM"
            currentMonthLabel.text = formatter.string(from: Date())
            setUpCalenderView()
            navigationController?.navigationBar.isTranslucent = true
            dayVC.dayView.delegate = self
            dayVC.dayView.dataSource = self
            dayVC.dayView.autoScrollToFirstEvent = true
            dayVC.dayView.isHeaderViewVisible = false
            dayVC.updateStyle(StyleGenerator.darkStyle())
            dayVC.reloadData()
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
            
//                for _ in 0..<visibleMonthEventDates.count {
//                    if visibleMonthEventDates.contains(cellState.date) {
////                    if formatter.string(from: cellState.date) == calendarDates[i] {
//                        validCell.eventImageView.image = UIImage(named: "currentDateEllipse")
//                        validCell.eventImageView.isHidden = false
//                    } else {
//                        validCell.eventImageView.isHidden = true
//                }
//            }
        }
        
        func addCalendarEvent(title: String, allDay: Bool, startDate: Date, endDate: Date, notes: String?) {
            
            let eventStore = EKEventStore()
            eventStore.requestAccess( to: EKEntityType.event, completion:{(granted, error) in
                if (granted) && (error == nil) {
                    
                    let event = EKEvent(eventStore: eventStore)
                    
                    event.title = title
                    event.isAllDay = allDay
                    event.startDate = startDate
                    event.endDate = endDate
                    
                    if let eventNotes = notes {
                        event.notes = eventNotes
                    }
                    
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    self.eventCalender = eventStore.defaultCalendarForNewEvents!.title
                    
                    var event_id = ""
                    
                    do {
                        try eventStore.save(event, span: .thisEvent)
                        event_id = event.eventIdentifier
                    }
                        
                    catch let error as NSError {
                        print("json error: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.addEventCancleButtonAction(UIButton())
                        }
                    }
                    
                    if(event_id != "") {
                        print("event added !")
                        DispatchQueue.main.async {
                            self.addEventCancleButtonAction(UIButton())
                            
                            // If User Selected for sending Alerts
                            if self.addEventAlertSwitch.isOn {
                                
                                // Creating the notification content
                                let content = UNMutableNotificationContent()
                                
                                //adding title, subtitle, body and badge
                                content.title = "Fire Fighter"
                                if notes != nil {
                                    content.subtitle = title
                                    content.body = notes!
                                } else {
                                    content.body = title
                                }
                                content.badge = 1
                                
                                let dateString = self.formatter.string(from: startDate)
                                self.formatter.timeZone = TimeZone.current
                                let dateFromString = self.formatter.date(from: dateString)
                                print(dateFromString!)
                                
                                let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dateFromString!)
                                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)

                                //getting the notification request
                                let request = UNNotificationRequest(identifier: "\(title) \(Float.random(in: 0 ..< 1))", content: content, trigger: trigger)
                                
                                UNUserNotificationCenter.current().delegate = self
                                
                                //adding the notification to notification center
                                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                            }
                        }
                    }
                }
            })
        }
        
        @IBAction func addEventAddButtonAction(_ sender: UIButton) {
            
            let title = addEventTitleTextField.text
            let allDay = allDayEventSwitch.isOn
            var startDate = Date()
            var endDate = Date()
            var notes: String?
            
            formatter.dateFormat = "dd MMM yyyy, h:mm a"
            formatter.timeZone = TimeZone.current
            
            if allDay == true {
                formatter.dateFormat = "EEEE dd MM yyyy"
            } else {
                formatter.dateFormat = "dd MMM yyyy, h:mm a"
            }
            
            if self.startTextField.text != "" {
//                formatter.dateFormat = "EEEE dd MM yyyy"
                startDate = formatter.date(from: self.startTextField.text!)!
            } else {
                startDate = Date()
            }
            
            if endTextField.text != "" {
//                formatter.dateFormat = "EEEE dd MM yyyy"
                endDate = formatter.date(from: self.endTextField.text!)!
            } else {
                startDate = Date()
            }
            
            if let eventNotes = self.eventNotesTextView.text {
                notes = eventNotes
            }
            
            addCalendarEvent(title: title!, allDay: allDay, startDate: startDate, endDate: endDate, notes: notes)
        }
        
        @IBAction func addEventCancleButtonAction(_ sender: UIButton) {
            addEventView.isHidden = true
            nullifyAddEventEntries()
        }
        
        func convertDateToString(date: Int64, format: String) -> String {
            return Date().toString(format: format, date: Date(milliseconds: Int64(date)))
        }
        
        func eventsForDate(_ date: Date) -> [EventDescriptor] {
            var date = date.add(TimeChunk.dateComponents(hours: Int(arc4random_uniform(10) + 5)))
            var events = [Event]()
            let eventStrore = EKEventStore()
            let calendars = eventStrore.calendars(for: .event)
            for calendar in calendars {
                
                if calendar.title == eventCalender {
                    let predicate = eventStrore.predicateForEvents(withStart: userSelectedDate, end: Calendar.current.date(byAdding: .day, value: 1, to: userSelectedDate)!, calendars: [calendar])
                    
                    var eventsOnSelectedDate = eventStrore.events(matching: predicate)
                    
                    for i in 0..<eventsOnSelectedDate.count {
                        let event = Event()
                        
                        let duration = Int(arc4random_uniform(160) + 60)
                        let datePeriod = TimePeriod(beginning: date, chunk: TimeChunk.dateComponents(minutes: duration))
                        
                        event.startDate = datePeriod.beginning!
                        event.endDate = datePeriod.end!

//                        event.startDate = eventsOnSelectedDate[i].startDate
//                        event.endDate = eventsOnSelectedDate[i].endDate
                        let info = eventsOnSelectedDate[i].title
                        event.text = info!
                        event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
                        event.isAllDay = eventsOnSelectedDate[i].isAllDay
                        
                        // Event styles are updated independently from CalendarStyle
                        // hence the need to specify exact colors in case of Dark style
                        if currentStyle == .Dark {
                            event.textColor = textColorForEventInDarkTheme(baseColor: event.color)
                            event.backgroundColor = event.color.withAlphaComponent(0.6)
                        }
                        
                        events.append(event)
                        
                        let nextOffset = Int(arc4random_uniform(250) + 40)
                        date = date.add(TimeChunk.dateComponents(minutes: nextOffset))
                        event.userInfo = String(i)
                    }
                }
            }
            return events
        }
        
        private func textColorForEventInDarkTheme(baseColor: UIColor) -> UIColor {
            var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            baseColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            return UIColor(hue: h, saturation: s * 0.3, brightness: b, alpha: a)
        }
        
        /* All Day Switch Action */
        @IBAction func addEventAllDayAction(_ sender: Any) {
            if allDayEventSwitch.isOn {
                formatter.dateFormat = "EEEE dd MMM yyyy"
                startTextField.text = formatter.string(from: userSelectedDate)
                endTextField.text = formatter.string(from: userSelectedDate)
                datePicker.datePickerMode = .date
            } else {
                datePicker.datePickerMode = .dateAndTime
//                formatter.dateFormat = "dd MMM yyyy, h:mm a"
                
                if (startTextField.text?.count)! > 0 {
                    formatter.dateFormat = "EEEE dd MM yyyy"
                    let currentSelectedDate = formatter.date(from: startTextField.text!)
                    formatter.dateFormat = "dd MMM yyyy, h:mm a"
                    startTextField.text = formatter.string(from: currentSelectedDate!)
                }
                if (endTextField.text?.count)! > 0 {
                    formatter.dateFormat = "EEEE dd MM yyyy"
                    let currentSelectedDate = formatter.date(from: endTextField.text!)
                    formatter.dateFormat = "dd MMM yyyy, h:mm a"
                    endTextField.text = formatter.string(from: currentSelectedDate!)
                }
            }
        }
        
        
        // MARK: DayViewDelegate
        
        func dayViewDidSelectEventView(_ eventView: EventView) {
            guard let descriptor = eventView.descriptor as? Event else {
                return
            }
            print("Event has been selected: \(descriptor) \(String(describing: descriptor.userInfo))")
        }
        
        func dayViewDidLongPressEventView(_ eventView: EventView) {
            guard let descriptor = eventView.descriptor as? Event else {
                return
            }
            print("Event has been longPressed: \(descriptor) \(String(describing: descriptor.userInfo))")
        }
        
        func dayView(dayView: DayView, willMoveTo date: Date) {
            print("DayView = \(dayView) will move to: \(date)")
        }
        
        func dayView(dayView: DayView, didMoveTo date: Date) {
            print("DayView = \(dayView) did move to: \(date)")
        }
        
        @IBAction func addEventButtonAction(_ sender: UIButton) {
            eventListContainerView.isHidden = true
            addEventView.isHidden = false
            nullifyAddEventEntries()
        }
        
        @IBAction func closeEventListButtonAction(_ sender: UIButton) {
            eventListContainerView.isHidden = true
        }
        
        @IBAction func nextDayEvents(_ sender: Any) {
            userSelectedDate = Calendar.current.date(byAdding: .day, value: 1, to: userSelectedDate)!
            formatter.dateFormat = "EEEE dd MMM yyyy"
            eventListHeaderDateLabel.text = formatter.string(from: userSelectedDate)
            dayVC.reloadData()
            if formatter.string(from: Date()) == formatter.string(from: userSelectedDate) {
                eventListFooterLabel.text = "Today"
                eventListFooterLabel.isHidden = false
            } else {
                eventListFooterLabel.isHidden = true
            }
        }
        
        @IBAction func previousDayEvents(_ sender: Any) {
            userSelectedDate = Calendar.current.date(byAdding: .day, value: -1, to: userSelectedDate)!
            formatter.dateFormat = "EEEE dd MMM yyyy"
            eventListHeaderDateLabel.text = formatter.string(from: userSelectedDate)
            dayVC.reloadData()
            if formatter.string(from: Date()) == formatter.string(from: userSelectedDate) {
                eventListFooterLabel.text = "Today"
                eventListFooterLabel.isHidden = false
            } else {
                eventListFooterLabel.isHidden = true
            }
        }
        
        //    MARK: DatePicker Methods
        @IBAction func startEvenrtDateAction(_ sender: Any) {
            pickerHeaderView.isHidden = false
            datePicker.isHidden = false
            datePicker.tag = 200
            addEventTitleTextField.resignFirstResponder()
            addEventLocationTextField.resignFirstResponder()
        }
        
        @IBAction func endEvenrtDateAction(_ sender: Any) {
            pickerHeaderView.isHidden = false
            datePicker.isHidden = false
            datePicker.tag = 300
            addEventTitleTextField.resignFirstResponder()
            addEventLocationTextField.resignFirstResponder()
        }
        
        @IBAction func datePickerCancelAction(_ sender: UIButton) {
            pickerHeaderView.isHidden = true
            datePicker.isHidden = true
        }
        
        @IBAction func datePickerDoneAction(_ sender: UIButton) {
            pickerHeaderView.isHidden = true
            datePicker.isHidden = true
            if datePicker.tag == 200 {
                let pickerDate = datePicker.date
                formatter.dateFormat = "dd MMM yyyy, h:mm a"
                startTextField.text = formatter.string(from: pickerDate)
            } else {
                let pickerDate = datePicker.date
                formatter.dateFormat = "dd MMM yyyy, h:mm a"
                endTextField.text = formatter.string(from: pickerDate)
            }
        }
        
        func getMonthEventsOnCalendar(eventsOnSelectedMonth: [Date]) -> [String] {
            
            let eventStrore = EKEventStore()
            let calendars = eventStrore.calendars(for: .event)
            visibleMonthEventDates = []
            for calendar in calendars {
                if calendar.title == eventCalender {
                    for eventDate in eventsOnSelectedMonth {
                        let predicate = eventStrore.predicateForEvents(withStart: eventDate, end: Calendar.current.date(byAdding: .hour, value: 24, to: eventDate)!, calendars: [calendar])
                        
                        if eventStrore.events(matching: predicate).count > 0 {
                            formatter.dateFormat = "dd MM yyyy"
                            let dateString = formatter.string(from: eventDate)
                            visibleMonthEventDates.append(dateString)
                        }
                    }
                }
            }
            return visibleMonthEventDates
        }
        
        func nullifyAddEventEntries() {
            addEventTitleTextField.text = nil
            addEventLocationTextField.text = nil
            allDayEventSwitch.isOn = false
            startTextField.text = nil
            endTextField.text = nil
            addEventAlertSwitch.isOn = false
            eventNotesTextView.text = nil
            addEventTitleTextField.resignFirstResponder()
            addEventLocationTextField.resignFirstResponder()
            startTextField.resignFirstResponder()
            endTextField.resignFirstResponder()
            eventNotesTextView.resignFirstResponder()
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
    
    //    MARK:- User Notifications Delegates
    extension ViewController: UNUserNotificationCenterDelegate {
        func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            
            //displaying the ios local notification when app is in foreground
            completionHandler([.alert, .badge, .sound])
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
            
            formatter.dateFormat = "dd MM yyyy"
            let cellDate = formatter.string(from: cellState.date)
            
            if visibleMonthEventDates.contains(cellDate) {
                cell.eventImageView.image = UIImage(named: "currentDateEllipse")
                cell.eventImageView.isHidden = false
            } else {
                cell.eventImageView.isHidden = true
            }
            
            handleCalendarCellTextColor(view: cell, cellState: cellState)
            return cell
        }
        
        func calendar(_ calendar: JTAppleCalendarView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
            var dateArray = [Date]()
            for dates in visibleDates.monthDates {
                dateArray.append(dates.date)
            }
            print(getMonthEventsOnCalendar(eventsOnSelectedMonth: dateArray))
        }
        
        func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
            if collectionView.cellStatus(for: Date()) != nil {
                print(Date())
            }
            
            setUpViewsFromCalender(from: visibleDates)
        }
        
        func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
            print("Current Selected Date is \(date)")
            //
            formatter.dateFormat = "yyyy MM dd"
            let selectedDateString = formatter.string(from: date)
            userSelectedDate = formatter.date(from: selectedDateString)!
            
            eventListContainerView.isHidden = false
            let calendarListView = dayVC.dayView
            calendarListView.reloadData()
            
            calendarListView.frame = CGRect(x: 0, y: 0, width: eventListView.frame.width, height: eventListView.frame.height)
            
            formatter.dateFormat = "EEEE dd MMM yyyy"
            eventListHeaderDateLabel.text = formatter.string(from: date)
            eventListView.addSubview(calendarListView)
            
            if formatter.string(from: Date()) == formatter.string(from: date) {
                eventListFooterLabel.text = "Today"
                eventListFooterLabel.isHidden = false
            } else {
                eventListFooterLabel.isHidden = true
            }
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
    
    extension ViewController {
        func addCalendarEvent(title: String, location: String?, description: String?, startDate: Date, endDate: Date, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
            let eventStore = EKEventStore()
            
            eventStore.requestAccess(to: .event, completion: { (granted, error) in
                if (granted) && (error == nil) {
                    let event = EKEvent(eventStore: eventStore)
                    event.title = title
                    if location != nil {
                        event.location = location
                    }
                    //            event.isAllDay = self.allDayEventSwitch.isOn
                    event.startDate = startDate
                    event.endDate = endDate
                    event.notes = description
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    do {
                        try eventStore.save(event, span: .thisEvent)
                    } catch let e as NSError {
                        completion?(false, e)
                        return
                    }
                    completion?(true, nil)
                } else {
                    completion?(false, error as NSError?)
                }
            })
        }
    }
