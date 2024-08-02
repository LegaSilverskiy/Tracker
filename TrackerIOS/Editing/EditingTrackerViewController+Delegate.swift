//
//  EditingTrackerViewController+Delegate.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/24/24.
//

import Foundation

extension EditingTrackerViewController: PassTrackerToEditDelegate {
    func passTrackerIndexPathToEdit(tracker: TrackerCoreData, indexPath: IndexPath) {
        getTrackerDataForEditing(tracker: tracker)
        self.indexPath = indexPath
    }
}
