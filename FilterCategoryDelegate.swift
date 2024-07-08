//
//  FilterCategoryDelegate.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/1/24.
//

import Foundation

protocol FilterCategoryDelegate: AnyObject {
    func getFilterFromPreviousVC(filter: String)
}
