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
        case NSLocalizedString("All trackers", comment: ""): showAllTrackersForThisDay()
        case NSLocalizedString("Today trackers", comment: ""): showAllTrackersForToday()
        case NSLocalizedString("Completed", comment: ""): showCompletedTrackersForDay()
        case NSLocalizedString("Not completed", comment: ""): showIncompleteTrackersForDay()
        default: dismiss(animated: true)
        }
    }

    // MARK: - Фильтр "Все трекеры"
    func showAllTrackersForThisDay() {
        getPinnedTrackersForToday()
        getTrackersForWeekDay(weekDay: weekDay)
        dataUpdated?()
        blueFilterButtonBackgroundColor()
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
        dataUpdated?()
    }

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

        if completedTrackersID.isEmpty {
            showEmptyCollections()
        } else {
            getCompletedPinnedTrackers(completedTrackers: completedTrackersID)
            getCompletedTrackers(completedTrackers: completedTrackersID)
        }
        dataUpdated?()
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
            getIncompletePinnedTrackers(trackerNotToShow: completedTrackersID)
            getIncompleteTrackers(trackerNotToShow: completedTrackersID)
        }
        dataUpdated?()
        changeFilterButtonBackgroundColor()
    }

    func getIncompletePinnedTrackers(trackerNotToShow: [String]) {
        coreDataManager.getInCompletePinnedTracker(trackerNotToShow: trackerNotToShow)
    }

    func getIncompleteTrackers(trackerNotToShow: [String]) {
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
