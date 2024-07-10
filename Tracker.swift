//
//  Tracker.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 3/29/24.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: String
}

extension Tracker {
    init(coreDataObject: TrackerCoreData) {
        self.id = coreDataObject.id  ?? UUID()
        self.name = coreDataObject.name ?? ""
        if let colorName = coreDataObject.colorName {
            self.color = UIColor(hex: colorName)
        } else {
            self.color = UIColor.black
        }
        self.emoji = coreDataObject.emoji ?? ""
        self.schedule = coreDataObject.schedule ?? ""
    }
}
