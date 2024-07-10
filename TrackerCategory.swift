//
//  TrackerCategory.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 3/29/24.
//

import Foundation

struct TrackerCategory {
    let header: String
    let trackers: [Tracker]
}

extension TrackerCategory {
    init(coreDataObject: TrackerCategoryCoreData) {
        self.header = coreDataObject.header ?? ""
        
        if let trackersSet = coreDataObject.trackers as? Set<TrackerCoreData> {
            self.trackers = trackersSet.map { Tracker(coreDataObject: $0) }
        } else {
            self.trackers = []
        }
    }
}
