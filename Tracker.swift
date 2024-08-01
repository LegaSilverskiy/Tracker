//
//  Tracker.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 3/29/24.
//

import UIKit

struct Tracker: Hashable {
    let id: String
    let name: String
    let color: String
    let emoji: String
    let schedule: String
    var isPinned: Bool? = false
    var trackerCategoryName: String?
}

extension Tracker {
    init(coreDataObject: TrackerCoreData) {
        self.id = coreDataObject.id  ?? UUID().uuidString
        self.name = coreDataObject.name ?? ""
        self.color = coreDataObject.colorName ?? "#000000"
        self.emoji = coreDataObject.emoji ?? ""
        self.schedule = coreDataObject.schedule ?? ""
        self.isPinned = coreDataObject.isPinned
        self.trackerCategoryName = coreDataObject.category?.header
    }
}
