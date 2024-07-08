//
//  NewTaskDelegate.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/1/24.
//

import Foundation

protocol NewTaskDelegate: AnyObject {
    func getNewTaskFromAnotherVC(newTask: TrackerCategory)
}
