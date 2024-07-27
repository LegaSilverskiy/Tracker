//
//  TrackerCoreManager.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/1/24.
//

import UIKit
import CoreData

struct TrackersStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackersStoreUpdate)
}

final class TrackerCoreManager: NSObject {
    
    static let shared = TrackerCoreManager()
    
    weak var delegate: DataProviderDelegate?
    
    var lastChosenFilter: String?
    
    var filterButtonForEmptyScreenIsEnable = false
    
    private override init() { }
    
    // MARK: - Container, context
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerCoreData")
        container.loadPersistentStores { (description, error) in
            if let error = error as NSError? {
                fatalError(error.localizedDescription)
            } else {
                print("DB loaded successfully ✅ url: ", description.url ?? "Oooops")
            }
        }
        return container
    } ()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    var pinnedSection: Int {
        pinnedTrackersFetchedResultsController?.sections?.count ?? 0
    }
    
    func numberOfPinnedTrackers(_ section: Int) -> Int {
        pinnedTrackersFetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    var insertedIndexes: IndexSet?
    var deletedIndexes: IndexSet?
    
    // MARK: - FetchResultsController
    
    var trackersFetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    var pinnedTrackersFetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    func setupFetchedResultsController(weekDay: String) {
        let request = TrackerCoreData.fetchRequest()
        let predicate1 = NSPredicate(format: "schedule CONTAINS %@", weekDay)
        let predicate2 = NSPredicate(format: "schedule CONTAINS %@", "Каждый день")
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1, predicate2])
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = compoundPredicate
        
        trackersFetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                                      managedObjectContext: context,
                                                                      sectionNameKeyPath: "category.header",
                                                                      cacheName: nil)
        
        trackersFetchedResultsController?.delegate = self
        
        do {
            try trackersFetchedResultsController?.performFetch()
            if let results = trackersFetchedResultsController?.fetchedObjects {
                for element in results {
                    print(element.name as Any)
                    print(element.schedule as Any)
                }
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - CRUD
    
    func getAllTrackersForWeekday(weekDay: String) {
        let request = TrackerCoreData.fetchRequest()
        let predicate1 = NSPredicate(format: "schedule CONTAINS %@", weekDay)
        let predicate2 = NSPredicate(format: "schedule CONTAINS %@", "Каждый день")
        let predicate3 = NSPredicate(format: "%K == %@",
                                     #keyPath(TrackerCoreData.isPinned), NSNumber(value: false))
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1, predicate2])
        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [compoundPredicate, predicate3])
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = finalCompoundPredicate
        
        setupTrackerFetchedResultsController(request: request)
    }
    
    func setupTrackerFetchedResultsController(request: NSFetchRequest<TrackerCoreData>) {
        trackersFetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: "category.header",
            cacheName: nil)
        
        trackersFetchedResultsController?.delegate = self
        
        do {
            try trackersFetchedResultsController?.performFetch()
        } catch {
            print("\(error.localizedDescription) 🟥")
        }
    }
    
    func printCoreData() {
        let request = TrackerCoreData.fetchRequest()
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            let result = try context.fetch(request)
            for element in result {
                print(element)
                print(element.name as Any)
                print(element.schedule as Any)
                print(element.category?.header as Any)
            }
        } catch  {
            print(error.localizedDescription)
        }
        
    }
    
    func fetchData() -> [TrackerCategory] {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        do {
            let allTrackers = try context.fetch(fetchRequest)
            let result = transformCoreDataToModel(trackerCategoryCoreData: allTrackers)
            print("fetchData: \n------------------------------")
            
            for trackerCategory in result {
                print("trackerCategory.header \(trackerCategory.header)")
                print("trackerCategory.trackers \(trackerCategory.trackers)")
                print("------------------------------")
            }
            return result
        } catch {
            print("\(error.localizedDescription) 🟥")
            return []
        }
    }
    
    func transformCoreDataToModel(trackerCategoryCoreData: [TrackerCategoryCoreData]) -> [TrackerCategory] {
        let trackersCategory = trackerCategoryCoreData.compactMap({
            TrackerCategory(coreDataObject: $0)
        })
        return trackersCategory
    }
    
    func createNewCategory(newCategoryName: String) {
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.header = newCategoryName
        save()
        print("New Category created ✅")
    }
    
    func createNewTracker(newTracker: TrackerCategory) {
        let header = newTracker.header
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "header = %@", header)
        
        do {
            let result = try context.fetch(fetchRequest)
            guard let category = result.first,
                  let tracker = newTracker.trackers.first else {
                print("May be here?"); return }
            
            let newTrackerToAdd = TrackerCoreData(context: context)
            newTrackerToAdd.id = tracker.id
            newTrackerToAdd.name = tracker.name
            newTrackerToAdd.colorName = tracker.color
            newTrackerToAdd.emoji = tracker.emoji
            newTrackerToAdd.schedule = tracker.schedule
            newTrackerToAdd.isPinned = false
            category.addToTrackers(newTrackerToAdd)
            save()
            print("New Tracker created and Added to category \(header) ✅")
        } catch {
            print("\(error.localizedDescription) 🟥")
        }
    }
    
    func deleteTrackerFromCategory(categoryName: String, trackerIDToDelete: UUID) {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerCoreData.id),
                                    trackerIDToDelete.uuidString)
        request.predicate = predicate
        
        do {
            let result = try context.fetch(request)
            for tracker in result where tracker.category?.header == categoryName {
                context.delete(tracker)
                print("Tracker removed from previous category (\(categoryName)) successfully ✅")
                save()
            }
        } catch {
            print("\(error.localizedDescription) 🟥")
        }
    }
    
    func numberOfPinnedItems() -> Int {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerCoreData.isPinned), NSNumber(value: true))
        request.predicate = predicate
        do {
            return try context.count(for: request)
        } catch {
            print("\(error.localizedDescription) 🟥")
            return 0
        }
    }
    
    
    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("\(error.localizedDescription) 🟥")
            }
        }
    }
    
    func getCategoryNamesFromStorage() -> [String] {
        let request = TrackerCategoryCoreData.fetchRequest()
        let predicate = NSPredicate(format: "NOT (%K == %@)",
                                    #keyPath(TrackerCategoryCoreData.header), "Закрепленные")
        request.predicate = predicate
        
        let result = try? context.fetch(request)
        
        guard let result = result else { return ["Ошибка"]}
        let headers = result.map { $0.header ?? "Ooops" }
        
        return headers
    }
    func numberOfRowsInStickySection() -> Int {
        guard let sections = trackersFetchedResultsController?.sections else { print("Hmmm"); return 0}
        
        for section in sections where section.name == "Закрепленные" {
            
            return section.numberOfObjects
            
        }
        print("We can't find any elements in sticky Cat")
        return 0
    }
    
    func printAllTrackersInCoreData() {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        do {
            let allTrackers = try context.fetch(fetchRequest)
            let result = transformCoreDataToModel(trackerCategoryCoreData: allTrackers)
            print("printAllTrackersInCoreData: \(result)")
        } catch {
            print("\(error.localizedDescription) 🟥")
        }
    }
    
    func printAllpinnedTrackers() {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerCoreData.isPinned), NSNumber(value: true))
        request.predicate = predicate
        do {
            let result = try context.fetch(request)
            print("result \(result)")
        } catch {
            print("\(error.localizedDescription) 🟥")
        }
    }
}

extension TrackerCoreManager: NSFetchedResultsControllerDelegate {
    
    var isCoreDataEmpty: Bool {
        let pinnedEmpty = pinnedTrackersFetchedResultsController?.sections?.isEmpty ?? true
        let trackersEmpty = trackersFetchedResultsController?.sections?.isEmpty ?? true
        return pinnedEmpty && trackersEmpty
    }
    
    var numberOfSections: Int {
        trackersFetchedResultsController?.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        trackersFetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCoreData? {
        trackersFetchedResultsController?.object(at: indexPath)
    }
    
    func printAllTrackersInCategory(header: String) {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "category.header == %@", header)
        do {
            let results = try context.fetch(request)
            for trackers in results {
                print("trackers: \(trackers)")
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func isCategoryEmpty(header: String) -> Bool? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "category.header == %@", header)
        do {
            let count = try context.count(for: request)
            return count <= 1 ? true : false
        } catch  {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func getTrackersForWeekDay(weekDay: String) {
        let request = trackersFetchedResultsController?.fetchRequest
        let predicate = NSPredicate(format: "%K CONTAINS %@",
                                    #keyPath(TrackerCoreData.schedule), weekDay)
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request?.sortDescriptors = [sort]
        request?.predicate = predicate
        do {
            try? trackersFetchedResultsController?.performFetch()
            print("Tracker updated to weekday ✅")
        }
    }
}

extension TrackerCoreManager {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.didUpdate(TrackersStoreUpdate(
            insertedIndexes: insertedIndexes!,
            deletedIndexes: deletedIndexes!
        )
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}

// MARK: - TrackerRecord
extension TrackerCoreManager {
    
    func printTrackerRecord() {
        let request = TrackerRecordCoreData.fetchRequest()
        
        do {
            let result = try context.fetch(request)
            print(result)
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func addTrackerRecord(trackerToAdd: TrackerRecord) {
        let newTrackerRecord = TrackerRecordCoreData(context: context)
        newTrackerRecord.id = trackerToAdd.id
        newTrackerRecord.date = trackerToAdd.date
        save()
        print("New TrackerRecord created ✅")
    }
    
    func countOfTrackerInRecords(trackerIDToCount: String) -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerRecordCoreData.id),
                                    trackerIDToCount)
        request.predicate = predicate
        
        do {
            return try context.count(for: request)
        } catch {
            print("\(error.localizedDescription) 🟥")
            return 0
        }
    }
    
    func deleteAllRecords() {
        let request: NSFetchRequest<NSFetchRequestResult> = TrackerRecordCoreData.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            print("All TrackerRecords deleted successfully ✅")
            save()
        } catch {
            print("\(error.localizedDescription) 🟥")
        }
    }
    
    
    
    func deleteAllTrackerRecordsForTracker(at indexPath: IndexPath) {
        guard let tracker = trackersFetchedResultsController?.object(at: indexPath),
              let trackerID = tracker.id?.uuidString else { print("Smth is going wrong"); return }
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerRecordCoreData.id), trackerID)
        request.predicate = predicate
        
        do {
            let result = try context.fetch(request)
            for records in result {
                context.delete(records)
                save()
            }
            print("TrackerRecords for this tracker deleted ✅")
        } catch {
            print("\(error.localizedDescription) 🟥")
        }
    }
    
    func removeTrackerRecordForThisDay(trackerToRemove: TrackerRecord) {
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate1 = NSPredicate(format: "%K == %@",
                                     #keyPath(TrackerRecordCoreData.id), trackerToRemove.id.uuidString )
        let predicate2 = NSPredicate(format: "%K == %@",
                                     #keyPath(TrackerRecordCoreData.date), trackerToRemove.date)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        request.predicate = compoundPredicate
        
        do {
            let result = try context.fetch(request)
            if let trackerToDelete = result.first {
                context.delete(trackerToDelete)
                print("Tracker Record deleted ✅")
                save()
            } else {
                print("We can't find the tracker")
            }
        } catch {
            print("\(error.localizedDescription) 🟥")
        }
    }
    
    func printAllTrackerRecords() {
        let request = TrackerRecordCoreData.fetchRequest()
        
        do {
            let result = try context.fetch(request)
            for element in result {
                print("element.date \(String(describing: element.date)), element.id \(String(describing: element.id))")
            }
        } catch {
            print("\(error.localizedDescription) 🟥")
        }
    }
    
    func countOfAllCompletedTrackers() -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        do {
            return try context.count(for: request)
        } catch {
            print("\(error.localizedDescription) 🟥")
            return 0
        }
    }
    
    func getAllTrackersForTheWeekDay(weekDay: String) -> [String: Int] {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K CONTAINS %@",
                                    #keyPath(TrackerCoreData.schedule), weekDay)
        request.predicate = predicate
        
        var result = [String: Int]()
        
        do {
            let data = try context.count(for: request)
            result[weekDay] = data
            return result
        } catch {
            print("\(error.localizedDescription) 🟥")
            return [:]
        }
    }
    
    func getTrackerRecordsCountsForDate(date: String) -> [String: Int] {
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K CONTAINS %@",
                                    #keyPath(TrackerRecordCoreData.date), date)
        request.predicate = predicate
        
        var trackerRecordsForDate: [String: Int] = [:]
        
        do {
            let data = try context.fetch(request)
            
            for tracker in data {
                trackerRecordsForDate[tracker.date!] = (trackerRecordsForDate[tracker.date!] ?? 0) + 1
            }
            let sortedArray = trackerRecordsForDate.sorted(by: {$0.key < $1.key})
            return Dictionary(uniqueKeysWithValues: sortedArray)
        } catch {
            print("\(error.localizedDescription) 🟥")
            return [:]
        }
    }
    
    func getAllTrackerRecordsDaysAndCounts() -> [String: Int] {
        let request = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        var countsByDate: [String: Int] = [:]
        
        do {
            let data = try context.fetch(request)
            
            for tracker in data {
                countsByDate[tracker.date!] = (countsByDate[tracker.date!] ?? 0) + 1
            }
            let sortedArray = countsByDate.sorted(by: {$0.key < $1.key})
            return Dictionary(uniqueKeysWithValues: sortedArray)
        } catch {
            print("\(error.localizedDescription) 🟥")
            return [:]
        }
    }
    
    func removeTrackerRecord(trackerToRemove: TrackerRecord) {
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate1 = NSPredicate(format: "%K == %@",
                                     #keyPath(TrackerRecordCoreData.id), trackerToRemove.id.uuidString )
        let predicate2 = NSPredicate(format: "%K == %@",
                                     #keyPath(TrackerRecordCoreData.date), trackerToRemove.date)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        request.predicate = compoundPredicate
        
        do {
            let result = try context.fetch(request)
            if let trackerToDelete = result.first {
                context.delete(trackerToDelete)
                print("Tracker deleted ✅")
                save()
            } else {
                print("We can't find the tracker")
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        
        deleteAllTrackerRecordsForTracker(at: indexPath)
        
        guard let tracker = trackersFetchedResultsController?.object(at: indexPath) else {
            print("Smth is going wrong"); return }
        context.delete(tracker)
        print("Tracker deleted ✅")
        save()
    }
    
    func isTrackerExistInTrackerRecord(trackerToCheck: TrackerRecord) -> Bool {
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate1 = NSPredicate(format: "%K == %@",
                                     #keyPath(TrackerRecordCoreData.id),
                                     trackerToCheck.id.uuidString)
        let predicate2 = NSPredicate(format: "%K == %@",
                                     #keyPath(TrackerRecordCoreData.date),
                                     trackerToCheck.date)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        request.predicate = compoundPredicate
        
        do {
            let result = try context.count(for: request)
            return result > 0
        } catch  {
            print(error.localizedDescription)
            return false
        }
    }
}

extension TrackerCoreManager {
    func sendLastChosenFilterToStore(filterName: String) {
        self.lastChosenFilter = filterName
    }
    
    func getLastChosenFilterFromStore() -> String {
        if let lastChosenFilter =  self.lastChosenFilter {
            return lastChosenFilter
        } else {
            return "Smth is going wrong"
        }
    }
    
    func getEmptyPinnedCollection() {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K = %@",
                                    #keyPath(TrackerCoreData.id.uuidString), "impossible trackerId")
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = predicate
        
        setupPinnedFetchResultControllerWithRequest(request: request)
    }
    func getEmptyTrackerCollection() {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K = %@",
                                    #keyPath(TrackerCoreData.id.uuidString), "impossible trackerId")
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.predicate = predicate
        request.sortDescriptors = [sort]
        
        filterButtonForEmptyScreenIsEnable = true
        
        setupTrackerFetchedResultsController(request: request)
    }
}

