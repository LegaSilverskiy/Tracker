//
//  CategoriesViewModel.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/16/24.
//

import Foundation

final class CategoriesViewModel: ViewModelProtocol {
    
    let coreDataManager = TrackerCoreManager.shared
    
    var categories = [String]() {
        didSet {
            dataUpdated?()
        }
    }
    
    var dataUpdated: ( () -> Void )?
    
    var updateCategory: ( (String) -> Void)?
    
    // MARK: - Update data from Core Data
    
    func getDataFromCoreData() {
        categories = coreDataManager.getCategoryNamesFromStorage()
        
    }
    
    func createNewCategory(newCategoryName: String) {
        coreDataManager.createNewCategory(newCategoryName: newCategoryName)
        getDataFromCoreData()
    }
}
