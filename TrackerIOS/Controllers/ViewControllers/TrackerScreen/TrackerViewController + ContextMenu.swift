//
//  TrackerViewController + Context.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/24/24.
//

import UIKit

// MARK: - Context Menu
extension TrackerViewController: UIContextMenuInteractionDelegate {
    
    // MARK: - Setup ContextMenu
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        var chosenCollection = trackersCollectionView
        let touchPoint = interaction.location(in: trackersCollectionView)
        
        let convertedLocation = chosenCollection.convert(location, from: interaction.view)
        guard let indexPath = chosenCollection.indexPathForItem(at: convertedLocation) else {
            print("We have a problem with editing a tracker")
            return nil
        }
        
        return UIContextMenuConfiguration(actionProvider: { (_) -> UIMenu? in
            
            let menu = self.setupContextMenu(collection: chosenCollection,
                                             indexPath: indexPath)
            
            return menu
        }
        )
    }
    
    func setupContextMenu(collection: UICollectionView,
                          indexPath: IndexPath) -> UIMenu? {
        
        let pinAction = setupPinAction(collection: collection, indexPath: indexPath)
        let editAction = setupEditAction(collection: collection, indexPath: indexPath)
        let deleteAction = setupDeleteAction(collection: collection, indexPath: indexPath)
        
        let menu = UIMenu(children: [pinAction, editAction, deleteAction])
        
        return menu
    }
    
    // MARK: - Pin
    func setupPinAction(collection: UICollectionView, indexPath: IndexPath) -> UIAction {
        
        let trackersCategories = getTrackerCategories()
        let trackerID = trackersCategories[indexPath.section].trackers[indexPath.item].id
        
        let title = trackersCategories[indexPath.section].header == "Pinned" ? "Unpin": "Pin"

        
        let pinAction = UIAction(title: title.localized()) { [weak self] _ in
            guard let self else { return }
            
            if indexPath.section == 0 && trackersCategories.first?.header == "Pinned" {
                coreDataManager.unpinTracker(trackerID: trackerID)
            } else {
                coreDataManager.pinTracker(trackerID: trackerID)
            }
            
            switch filterStr {
            case "Completed":
                showCompletedTrackers()
            case "Today trackers":
            // TODO: DODELAT
                print("DODELAT")
            case "Not completed":
                // TODO: DODELAT
                print("DODELAT")
            default:
                dataUpd()
            }
        }
        return pinAction
    }
    
    // MARK: - Edit
    func setupEditAction(collection: UICollectionView, indexPath: IndexPath) -> UIAction {
        var tracker: TrackerCoreData?
        
        let editAction = UIAction(title: NSLocalizedString("Edit", comment: "Edit tracker")) { [weak self] _ in
            guard let self else { return }
            
            if collection == trackersCollectionView {
                tracker = coreDataManager.object(at: indexPath)
            } else {
                tracker = coreDataManager.getPinnedTrackerWithIndexPath(indexPath: indexPath)
            }
            
            guard let tracker else { return }
            
            goToEditingVC()
            
            self.passTrackerToEditDelegate?.passTrackerIndexPathToEdit(tracker: tracker, indexPath: indexPath)
            
            AnalyticsService.editButtonTapped()
            
        }
        return editAction
    }
    
    private func goToEditingVC() {
        let editingVC = EditingTrackerViewController()
        self.passTrackerToEditDelegate = editingVC
        let navVC = UINavigationController(rootViewController: editingVC)
        self.present(navVC, animated: true)
    }
    
    // MARK: - Delete
    func setupDeleteAction(collection: UICollectionView, indexPath: IndexPath) -> UIAction {
        let deleteAction = UIAction(title: NSLocalizedString("Delete", comment: "Delete tracker"), attributes: .destructive) { [weak self] _ in
            guard let self else { return }
            self.showAlert(collection: collection, indexPath: indexPath)
            AnalyticsService.deleteButtonTapped()
        }
        return deleteAction
    }
    
    private func showAlert(collection: UICollectionView, indexPath: IndexPath) {
        let alert = UIAlertController(title: NSLocalizedString("Are you sure you want to delete the tracker?", comment: "Alert after tap on delete"),
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete tracker"), style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            let trackerID = getTrackerCategories()[indexPath.section].trackers[indexPath.item].id
            coreDataManager.deleteTrackerWithID(trackerID: trackerID)
            
            switch filterStr {
            case "Completed":
                showCompletedTrackers()
            case "Today trackers":
            // TODO: DODELAT
                print("DODELAT")
            case "Not completed":
                // TODO: DODELAT
                print("DODELAT")
            default:
                dataUpd()
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel)
        [deleteAction, cancelAction].forEach { alert.addAction($0)}
        self.present(alert, animated: true)
    }
    
    private func deletePinnedTracker(indexPath: IndexPath) {
        guard
            let tracker = coreDataManager.getPinnedTrackerWithIndexPath(indexPath: indexPath),
            let trackerID = tracker.id else {
            print("Some problems")
            return
        }
        //        print("tracker \(trackerID)")
        coreDataManager.deleteTrackerWithID(trackerID: trackerID)
    }
    
}
