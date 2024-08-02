//
//  PassTrackerToEditDelegate.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/24/24.
//

import Foundation

protocol PassTrackerToEditDelegate: AnyObject {
    func passTrackerIndexPathToEdit(tracker: TrackerCoreData, indexPath: IndexPath)
}
