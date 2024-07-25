//
//  TrackerCoreData.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/1/24.
//

import Foundation
import CoreData

@objc(TrackerCoreData)
public class TrackerCoreData: NSManagedObject {
    
    @NSManaged public var colorName: String?
    @NSManaged public var emoji: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var schedule: String?
    @NSManaged public var isPinned: Bool
    @NSManaged public var category: TrackerCategoryCoreData?
    @NSManaged public var trackerRecord: TrackerRecordCoreData?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }
}
