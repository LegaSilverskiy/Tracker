//
//  TrackerViweController + Filter.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/26/24.
//

import UIKit

extension TrackerViewController: FilterCategoryDelegate {

    var completedTrackersID: [String] {
        getCompletedTrackers()
    }
    
    func getFilterFromPreviousVC(filter: String) {
        isFilter = true
        filterStr = filter
        switch filter {
        case NSLocalizedString("All trackers", comment: ""):
            showAllTrackersForThisDay()
        case NSLocalizedString("Today trackers", comment: ""):
            showAllTrackersForToday()
        case NSLocalizedString("Completed", comment: ""):
            showCompletedTrackersForDay()
        case NSLocalizedString("Not completed", comment: ""):
            showUncompletedTrackers()
        default: dismiss(animated: true)
        }
    }

    // MARK: - Фильтр "Все трекеры"
    func showAllTrackersForThisDay() {
        getPinnedTrackersForToday()
        getTrackersForWeekDay(weekDay: weekDay)
        dataUpd()
        blueFilterButtonBackgroundColor()
        configureEmptyDataPlaceholderVisability()
    }

    func getPinnedTrackersForToday() {
        coreDataManager.setupPinnedFetchedResultsController()
    }

    func getTrackersForWeekDay(weekDay: String) {
        coreDataManager.getAllTrackersForWeekday(weekDay: weekDay)
    }

    // MARK: - Фильтр "Трекеры на сегодня"
    func showAllTrackersForToday() {
        getPinnedTrackersForToday()
        getTrackersForToday()
        setDateForDatePicker()
        changeFilterButtonBackgroundColor()
        dataUpd()
        configureEmptyDataPlaceholderVisability()
    }
//TODO: - Получаю все трекеры по конкретному дню
    func getTrackersForToday() {
        let todayWeekDayString = getTodayWeekday()
        getTrackersForWeekDay(weekDay: todayWeekDayString)
    }

    func getTodayWeekday() -> String {
        let calendar = Calendar.current
        let date = Date()
        let dateComponents = calendar.dateComponents([.weekday], from: date)
        let weekDay = dateComponents.weekday
        let weekDayString = dayNumberToDayString(weekDayNumber: weekDay)
        print(weekDayString)
        return weekDayString
    }

    func setDateForDatePicker() {
        let date = Date()
        let dateToString = MainHelper.dateToString(date: date)
        datePicker.date = date
    }
    
    // MARK: - Фильтр "Завершенные"
    func showCompletedTrackersForDay() {
        showCompletedTrackers()
        changeFilterButtonBackgroundColor()
    }

    func showEmptyCollections() {
        coreDataManager.getEmptyPinnedCollection()
        coreDataManager.getEmptyTrackerCollection()
    }

    func getCompletedPinnedTrackers(completedTrackers: [String]) {
        coreDataManager.getCompletedPinnedTracker(trackerId: completedTrackers)
    }

    func getCompletedTrackers(completedTrackers: [String]) {
        coreDataManager.getCompletedTrackersWithID(completedTrackerId: completedTrackers)
    }

    // MARK: - Фильтр "Незавершенные"
    func showIncompleteTrackersForDay() {

        if completedTrackersID.isEmpty {
            getPinnedTrackersForToday()
            getTrackersForWeekDay(weekDay: weekDay)
        } else {
            getUncompletePinnedTrackers(trackerNotToShow: completedTrackersID)
            getUncompleteTrackers(trackerNotToShow: completedTrackersID)
        }
//        dataUpdated?()
        dataUpd()
        changeFilterButtonBackgroundColor()
    }

    func getUncompletePinnedTrackers(trackerNotToShow: [String]) {
        coreDataManager.getInCompletePinnedTracker(trackerNotToShow: trackerNotToShow)
    }

    func getUncompleteTrackers(trackerNotToShow: [String]) {
        coreDataManager.getTrackersExceptWithID(trackerNotToShow: completedTrackersID, weekDay: weekDay)
    }

    // MARK: - Supporting Methods
    func getCompletedTrackers() -> [String] {
        let date = datePicker.date
        let dateString = MainHelper.dateToString(date: date)
        let completedTrackers =
        coreDataManager.getAllTrackerRecordForDate(date: dateString)
        let completedTrackersID = completedTrackers.compactMap { $0 }
        print("completedTrackersID \(completedTrackersID)")
        return completedTrackersID
    }

    func changeFilterButtonBackgroundColor() {
        filtersButton.backgroundColor = UIColor(named: "IosRed")
    }

    func blueFilterButtonBackgroundColor() {
        filtersButton.backgroundColor = UIColor(named: "IosBlue")
    }
}
