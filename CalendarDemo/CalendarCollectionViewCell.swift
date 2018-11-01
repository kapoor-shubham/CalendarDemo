//
//  CalendarCollectionViewCell.swift
//  CalendarDemo
//
//  Created by Shubham Kapoor on 30/10/18.
//  Copyright © 2018 Shubham Kapoor. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarCollectionViewCell: JTAppleCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var currentDateImageView: UIImageView!
    @IBOutlet weak var eventImageView: UIImageView!
}
