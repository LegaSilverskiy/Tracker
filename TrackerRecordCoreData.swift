//
//  TrackerRecordCoreData.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/1/24.
//

import Foundation
import CoreData

@objc(TrackerRecordCoreData)
public class TrackerRecordCoreData: NSManagedObject {
    
    @NSManaged public var date: String?
    @NSManaged public var id: String?
    @NSManaged public var tracker: TrackerCoreData?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
        return NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
    }
    
}
