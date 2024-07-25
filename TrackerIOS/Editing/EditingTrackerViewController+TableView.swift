//
//  EditingTrackerViewController+TableView.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/24/24.
//

import UIKit

// MARK: - UITableViewDataSource, UITableViewDelegate
extension EditingTrackerViewController: UITableViewDataSource, UITableViewDelegate {

    func setupTableView() {
        tableViewForEditing.dataSource = self
        tableViewForEditing.delegate = self
        tableViewForEditing.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        tableViewForEditing.layer.cornerRadius = 10
        tableViewForEditing.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableViewForEditing.separatorColor = UIColor(named: "TableSeparatorColor")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = tableViewRows[indexPath.row]
        cell.backgroundColor = UIColor(named: "textFieldBackgroundColor")
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = .gray
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.selectionStyle = .none

        if indexPath.row == 0 {
            if category != nil {
                cell.detailTextLabel?.text = category
            }
        } else {
            if schedule != nil {
                cell.detailTextLabel?.text = schedule
            }
        }

        let disclosureImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 7, height: 12))
        disclosureImage.image = UIImage(named: "chevron")
        cell.accessoryView = disclosureImage

        if indexPath.row == tableViewRows.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = tableViewRows[indexPath.row]
        if data == "Категория" {
            let viewModel = CategoriesViewModel()
            let categoryVC = CategoriesViewController(viewModel: viewModel)
            let navVC = UINavigationController(rootViewController: categoryVC)
            categoryVC.viewModel.updateCategory = { [weak self] categoryName in
                guard let self = self,
                      let cell = tableView.cellForRow(at: indexPath) else { return }
                cell.detailTextLabel?.text = categoryName
                self.category = categoryName
            }
            present(navVC, animated: true)
        } else {
            let scheduleVC = ScheduleViewConroller()
            let navVC = UINavigationController(rootViewController: scheduleVC)
            scheduleVC.scheduleToPass = { [weak self] schedule in
                guard let self = self,
                      let cell = tableView.cellForRow(at: indexPath) else { return }
                cell.detailTextLabel?.text = schedule
                self.schedule = schedule
            }
            present(navVC, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
