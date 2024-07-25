//
//  TrackerCoreManager+Pin.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/24/24.
//

import CoreData

extension TrackerCoreManager {

    func setupPinnedFetchedResultsController() {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerCoreData.isPinned), NSNumber(value: true))
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = predicate

        pinnedTrackersFetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: "category.header",
            cacheName: nil)

        pinnedTrackersFetchedResultsController?.delegate = self

        do {
            try pinnedTrackersFetchedResultsController?.performFetch()
        } catch {
            print("\(error.localizedDescription) 🟥")
        }
    }

    func setupPinnedFRCWithRequest(request: NSFetchRequest<TrackerCoreData>) {
        pinnedTrackersFetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: "category.header",
            cacheName: nil)

        pinnedTrackersFetchedResultsController?.delegate = self

        do {
            try pinnedTrackersFetchedResultsController?.performFetch()
        } catch {
            print("\(error.localizedDescription) 🟥")
        }
    }

    func getCompletedPinnedTracker(trackerId: [String]) {
        let request = TrackerCoreData.fetchRequest()
        let predicate1 = NSPredicate(format: "%K == %@",
                                     #keyPath(TrackerCoreData.isPinned), NSNumber(value: true))
        let predicate2 = NSPredicate(format: "%K IN %@",
                                     #keyPath(TrackerCoreData.id), trackerId)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = compoundPredicate

        setupPinnedFRCWithRequest(request: request)
    }

    func getEmptyPinnedCollection() {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K = %@",
                                     #keyPath(TrackerCoreData.id.uuidString), "impossible trackerId")
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = predicate

        setupPinnedFRCWithRequest(request: request)
    }

    func getInCompletePinnedTracker(trackerNotToShow trackerId: [String]) {
        let request = TrackerCoreData.fetchRequest()
        let predicate1 = NSPredicate(format: "%K == %@",
                                     #keyPath(TrackerCoreData.isPinned), NSNumber(value: true))
        let predicate2 = NSPredicate(format: "NOT (%K IN %@)",
                                     #keyPath(TrackerCoreData.id), trackerId)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = compoundPredicate

        setupPinnedFRCWithRequest(request: request)
    }

    func pinTracker(indexPath: IndexPath) {
        guard let tracker = trackersFetchedResultsController?.object(
            at: indexPath) else {
            print("Smth is going wrong")
            return }
        tracker.isPinned = true
        print("Tracker is Pinned ✅")
        save()
    }

    func unpinTracker(indexPath: IndexPath) {
        guard let tracker = pinnedTrackersFetchedResultsController?.object(at: indexPath) else {
            print("Smth is going wrong"); return }
        //        print("indexPath \(indexPath)")
        //        print("tracker.name \(tracker.name)")
        tracker.isPinned = false
        print("Tracker is Unpinned")
        save()
    }

    func getAllPinnedTrackers() -> [TrackerCoreData]? {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerCoreData.isPinned), NSNumber(value: true))
        request.predicate = predicate

        do {
            return try context.fetch(request)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func getAllUnPinnedTrackers() -> [TrackerCategory] {
        let request = TrackerCategoryCoreData.fetchRequest()
        let predicate = NSPredicate(format: "ANY %K == %@",
                                    #keyPath(TrackerCategoryCoreData.trackers.isPinned), NSNumber(value: false))
        request.predicate = predicate

        let sort = NSSortDescriptor(key: "header", ascending: true)
        request.sortDescriptors = [sort]

        do {
            let allTrackers = try context.fetch(request)
            let result = transformCoreDataToModel(trackerCategoryCoreData: allTrackers)

            //            print("result \(result)")

            return result
        } catch {
            print(error.localizedDescription)
            return []
        }
    }

    func getPinnedTrackerWithIndexPath(indexPath: IndexPath) -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerCoreData.isPinned),
                                    NSNumber(value: true))
        request.predicate = predicate

        do {
            let result = try context.fetch(request)
            let tracker = result[indexPath.row]
            return tracker
            //            print("result \(result)")
            //            print("tracker \(tracker.name), \(tracker.id)")
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func deleteAllTrackerRecordsForTracker(trackerID: String) {
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

    func deleteTrackerWithID(trackerID: String) {

        deleteAllTrackerRecordsForTracker(trackerID: trackerID)

        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerCoreData.id),
                                    trackerID)
        request.predicate = predicate

        do {
            let result = try context.fetch(request)
            guard let trackerToDelete = result.first else {
                print("We have issues here")
                return
            }
            context.delete(trackerToDelete)
            print("Tracker deleted ✅")
            save()
        } catch {
            print("\(error.localizedDescription) 🟥")
        }
    }
}
