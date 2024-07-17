//
//  ViewModelProtocol.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/16/24.
//

import Foundation

protocol ViewModelProtocol {
    var updateCategory: ( (String) -> Void)? { get set }
    var dataUpdated: ( () -> Void )? { get set }
    var categories: [String] { get set }
    
    func getDataFromCoreData()
    func createNewCategory(newCategoryName: String)
}
