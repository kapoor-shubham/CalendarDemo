//
//  NewViewController.swift
//  CalendarDemo
//
//  Created by Shubham Kapoor on 02/11/18.
//  Copyright © 2018 Shubham Kapoor. All rights reserved.
//

import UIKit

class NewViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let calendarView = CalendarListViewController()
        self.view.addSubview(calendarView.dayView)
    }
}
