////
////  Categories.swift
////  TrackerIOS
////
////  Created by Олег Серебрянский on 4/25/24.
////
//
//import Foundation
//
//final class CategoryDB {
//    
//    static let shared = CategoryDB()
//    
//    private init() { }
//    
//    var categoryNames: [String] = ["Важное", "Радостные мелочи", "Самочувствие", "Привычки", "Внимательность", "Спорт"]
//    
//    func addToCategoryNames(categoryNames: [String]) {
//        for categoryName in categoryNames {
//            self.categoryNames.append(categoryName)
//        }
//    }
//    
//    func updateCategoryNames(categoryNames: [String]) {
//            self.categoryNames = categoryNames
//    }
//    
//    func getCategoryNames() -> [String] {
//        self.categoryNames
//    }
//        
//    var data: [TrackerCategory] = []
//    
//    func addToDataBase(dataBase: TrackerCategory) {
//        if let categoryIndex = self.data.firstIndex(where: { $0.header == dataBase.header } ) {
//            let categoryHeader = dataBase.header
//            var trackerInCategory = self.data[categoryIndex].trackers
//            for tracker in dataBase.trackers {
//                trackerInCategory.append(tracker)
//            }
//            self.data[categoryIndex] = TrackerCategory(header: categoryHeader,
//                                                           trackers: trackerInCategory)
//        } else {
//            self.data.append(dataBase)
//        }
//    }
//    
//    func getDataBaseFromStorage() -> [TrackerCategory]? {
//        self.data
//    }
//    
//    
//}
