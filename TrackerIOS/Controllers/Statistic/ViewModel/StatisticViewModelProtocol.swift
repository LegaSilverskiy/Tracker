//
//  StatisticViewModelProtocol.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/19/24.
//

import Foundation

protocol StatisticViewModelProtocol {

    var bestPeriod: Int { get set }
    var idealDays: Int { get set }
    var completedTrackers: Int { get set }
    var averageNumber: Double { get set }

    var updateData: ( () -> Void )? { get set}

    func isStatisticsEmpty() -> Bool
    func countOfCompletedTrackers()
    func trackerRecordsPerDay()

    func deleleAllRecords()
    func calculationOfIdealDays()
    func calculateTheBestPeriod()

}
