//
//  passNewTaskToMainVC.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 5/8/24.
//

import Foundation

protocol NewTaskDelegate: AnyObject {
    func getNewTaskFromAnotherVC(newTask: TrackerCategory)
}
