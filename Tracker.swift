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
    let color: String
    let emoji: String
    let schedule: String
    var isPinned: Bool? = false
}

extension Tracker {
    init(coreDataObject: TrackerCoreData) {
        self.id = coreDataObject.id  ?? UUID()
        self.name = coreDataObject.name ?? ""
        self.color = coreDataObject.colorName ?? "#000000"
        self.emoji = coreDataObject.emoji ?? ""
        self.schedule = coreDataObject.schedule ?? ""
        self.isPinned = coreDataObject.isPinned
    }
}
