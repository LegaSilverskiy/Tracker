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
        
        var chosenCollection: UICollectionView?
        let touchPoint = interaction.location(in: view)
        
        if stickyCollectionView.frame.contains(touchPoint) {
            chosenCollection = stickyCollectionView
        } else if trackersCollectionView.frame.contains(touchPoint) {
            chosenCollection = trackersCollectionView
        }
        
        
        guard let chosenCollection else { return nil}
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
        let title = collection == trackersCollectionView ? "Pin" : "Unpin"
        let pinAction = UIAction(title: title.localized()) { [weak self] _ in
            guard let self else { return }
            
            if collection == trackersCollectionView {
                coreDataManager.pinTracker(indexPath: indexPath)
            } else {
                coreDataManager.unpinTracker(indexPath: indexPath)
            }
            dataUpdated?()
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
        }
        return deleteAction
    }
    
    private func showAlert(collection: UICollectionView, indexPath: IndexPath) {
        let alert = UIAlertController(title: NSLocalizedString("Are you sure you want to delete the tracker?", comment: "Alert after tap on delete"),
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete tracker"), style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            if collection == trackersCollectionView {
                coreDataManager.deleteTracker(at: indexPath)
                trackersCollectionView.reloadData()
            } else {
                deletePinnedTracker(indexPath: indexPath)
                stickyCollectionView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel)
        [deleteAction, cancelAction].forEach { alert.addAction($0)}
        self.present(alert, animated: true)
    }
    
    private func deletePinnedTracker(indexPath: IndexPath) {
        guard
            let tracker = coreDataManager.getPinnedTrackerWithIndexPath(indexPath: indexPath),
            let trackerID = tracker.id?.uuidString else {
            print("Some problems")
            return
        }
        //        print("tracker \(trackerID)")
        coreDataManager.deleteTrackerWithID(trackerID: trackerID)
    }
    
}
