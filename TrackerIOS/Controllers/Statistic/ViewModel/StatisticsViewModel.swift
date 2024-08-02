//
//  StatisticsViewModel.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/19/24.
//

import Foundation

final class StatisticViewModel: StatisticViewModelProtocol {

    // MARK: - Properties
    let coreDataManager = TrackerCoreManager.shared

    var bestPeriod = 0 {
        didSet {
            updateData?()
        }
    }

    var idealDays = 0 {
        didSet {
            updateData?()
        }
    }

    var completedTrackers = 0 {
        didSet {
            updateData?()
        }
    }

    var averageNumber = 0.0 {
        didSet {
            updateData?()
        }
    }

    var updateData: ( () -> Void )?

    var arrayOfDays = [Int?]()

    var daysBetweenFirstTrRecordAndCurrentDate = Int()

}

// MARK: - Point 1 - Best Period
extension StatisticViewModel {

    func calculateTheBestPeriod() {

        let currentDate = Date()
        arrayOfDays = []

        guard var startDate = findTheFirstDateOfTrackerRecords() else {
            print("We have some problems with finding the first date - maybe we don't have any trackerRecords"); return
        }

        daysBetweenFirstTrRecordAndCurrentDate = countOfDaysBetween(
            startDate: startDate, currentDate: currentDate)

        while startDate < currentDate {

            let completedTrackersOnThisDate = countOfCompletedTrackersOnThisDate(date: startDate)

            let trackersToDo = trackersToDoOnTheDate(date: startDate)

            let isThisIdealDate = calculateIsThisAnIdealDay(
                trackersToDo: trackersToDo, completedTracker: completedTrackersOnThisDate)
            arrayOfDays.append(isThisIdealDate)

            // Идем в следующий день
            guard let temporaryDate = Calendar.current.date(
                byAdding: .day, value: 1, to: startDate) else { print("Ooops, troubles"); return }
            startDate = temporaryDate
        }

        let result = findTheMaxLengthOfBestSeries(arrayOfResults: arrayOfDays)

        if result > bestPeriod {
            bestPeriod = result
        }
    }
}

// MARK: - Point 2 - Ideal Days
extension StatisticViewModel {
    func calculationOfIdealDays() {
        var countOfIdealDays = 0
        let noNilArray = arrayOfDays.compactMap { $0 }
        countOfIdealDays = noNilArray.reduce(0, +)
        idealDays = countOfIdealDays
    }
}

// MARK: - Point 3 - Completed Trackers
extension StatisticViewModel {
    func countOfCompletedTrackers() {
        let countOfCompletedTrackers = coreDataManager.countOfAllCompletedTrackers()
        completedTrackers = countOfCompletedTrackers
    }
}

// MARK: - Point 4 - Completed Trackers Per Day
extension StatisticViewModel {
    func trackerRecordsPerDay() {

        if daysBetweenFirstTrRecordAndCurrentDate != 0 {
            let recordsPerDay = Double(completedTrackers) / Double(daysBetweenFirstTrRecordAndCurrentDate)
            let recordsPerDayFormat = String(format: "%.2f", recordsPerDay)
            if let result = Double(recordsPerDayFormat) {
                averageNumber = result
            }
        } else {
            return
        }
    }
}

extension StatisticViewModel {
    // MARK: - Supporting Methods
    func isStatisticsEmpty() -> Bool {
        let isAllNumbersAreZero = bestPeriod == 0 &&
        idealDays == 0 &&
        completedTrackers == 0 &&
        averageNumber == 0.0
        return isAllNumbersAreZero
    }

    func dateStringToWeekDayString(dateString: String) -> String {
        guard let date = MainHelper.stringToDate(string: dateString) else { return "999"}
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        let weekDay: [Int: String] = [1: "Вс", 2: "Пн", 3: "Вт", 4: "Ср",
                                      5: "Чт", 6: "Пт", 7: "Сб"]
        guard let result = weekDay[dayOfWeek] else { return "888"}
        return result
    }

    func deleleAllRecords() {
        coreDataManager.deleteAllRecords()
        coreDataManager.printAllTrackerRecords()
    }

    func countOfDaysBetween(startDate: Date, currentDate: Date) -> Int {
        let timeInt = currentDate.timeIntervalSince(startDate)
        let days = timeInt / (60 * 60 * 24) + 1
        return Int(days)
    }

    func trackersToDoOnTheDate(date: Date) -> Int {
        let newDateString = MainHelper.dateToString(date: date)
        let dateAsWeekDay = dateStringToWeekDayString(dateString: newDateString)
        let allTrackersForWeekDay = coreDataManager.getAllTrackersForTheWeekDay(weekDay: dateAsWeekDay)
        let trackersToDo = (allTrackersForWeekDay.first?.value)!
        return trackersToDo
    }

    func countOfCompletedTrackersOnThisDate(date: Date) -> Int {
        let newDateString = MainHelper.dateToString(date: date)
        let trackerRecordsForDate = coreDataManager.getTrackerRecordsCountsForDate(date: newDateString)
        let completedTrackers = trackerRecordsForDate.first?.value ?? 0
        return completedTrackers
    }

    func findTheFirstDateOfTrackerRecords() -> Date? {
        let allTrackerRecords = coreDataManager.getAllTrackerRecordsDaysAndCounts()

        var test = [Date: Int]()

        for record in allTrackerRecords {
            if let date = MainHelper.stringToDate(string: record.key) {
                test[date] = record.value
            }
        }

        guard let startDateDict = test.keys.min() else {
            print("We have problems with finding the first date - maybe we don't have any trackerRecords"); return nil }
        let startDateString = MainHelper.dateToString(date: startDateDict)

        guard let startDate = MainHelper.stringToDate(string: startDateString) else {
            print("We have some problems here - we can't transform string to date"); return nil}
        return startDate
    }

    func calculateIsThisAnIdealDay(trackersToDo: Int, completedTracker: Int) -> Int? {
        if trackersToDo == 0 {
            return nil
        } else {
            let resultForTheDay = isAllTrackerCompleted(trackersToDo: trackersToDo, completedTracker: completedTracker)
            return resultForTheDay
        }
    }

    func isAllTrackerCompleted(trackersToDo: Int, completedTracker: Int) -> Int {
        if trackersToDo == completedTracker {
            return 1
        } else {
            return 0
        }
    }

    func findTheMaxLengthOfBestSeries(arrayOfResults: [Int?]) -> Int {
        let noNilArray = arrayOfResults.compactMap { $0 }

        var finalResult = [Int]()
        var count = 0
        for element in noNilArray {
            if element == 1 {
                count += 1
            } else {
                finalResult.append(count)
                count = 0
            }
        }
        finalResult.append(count)
        guard let answer = finalResult.max() else { return 0}
        return answer
    }
}
