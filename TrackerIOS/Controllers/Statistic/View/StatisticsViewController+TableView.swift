//
//  StatisticsViewController+TableView.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/19/24.
//

import UIKit

extension StatisticViewController: UITableViewDataSource, UITableViewDelegate {

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StatisticsCustomCell.self, forCellReuseIdentifier: StatisticsCustomCell.identifier)

        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false

        tableView.backgroundColor = .systemBackground
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titleData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StatisticsCustomCell.identifier, for: indexPath)
                as? StatisticsCustomCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        configureCell(cell: cell, indexPath: indexPath)
        return cell
    }

    func configureCell(cell: StatisticsCustomCell, indexPath: IndexPath) {
        cell.titleLabel.text = titleData[indexPath.row]

        switch indexPath.row {
        case 0: cell.numberLabel.text =  String(viewModel.bestPeriod)
        case 1: cell.numberLabel.text = String(viewModel.idealDays)
        case 2: cell.numberLabel.text = String(viewModel.completedTrackers)
        default: cell.numberLabel.text = String(viewModel.averageNumber)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowHeight
    }
}
