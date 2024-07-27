//
//  FilterTrackersViewController.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/25/24.
//

import UIKit

final class FilterTrackersViewController: UIViewController {

    // MARK: - UI Properties
    private let filterTrackersTableView = UITableView()

    // MARK: - Private Properties
    private let filters = [NSLocalizedString("All trackers", comment: ""), NSLocalizedString("Today trackers", comment: ""),
                           NSLocalizedString("Completed", comment: ""), NSLocalizedString("Not completed", comment: "")
    ]

    private let cellHeight = CGFloat(75)

    weak var filterDelegate: FilterCategoryDelegate?
    
    let trackerCoreManager = TrackerCoreManager.shared

    var selectedFilter = String()


    // MARK: - Live Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        uploadLastFilterFromCoreData()

        setupUI()
        setupTableView()
    }

    // MARK: - Private Methods
    private func setupUI() {

        self.title = NSLocalizedString("Filter", comment: "Filter")
        view.backgroundColor = .systemBackground

        let tableViewHeight = cellHeight * CGFloat(filters.count)

        view.addSubViews([filterTrackersTableView])

        NSLayoutConstraint.activate([
            filterTrackersTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            filterTrackersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterTrackersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filterTrackersTableView.heightAnchor.constraint(equalToConstant: tableViewHeight)
        ])
    }

    private func setupTableView() {

        filterTrackersTableView.dataSource = self
        filterTrackersTableView.delegate = self
        filterTrackersTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        filterTrackersTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        filterTrackersTableView.separatorColor = UIColor(named: "GrayIOS")
        filterTrackersTableView.layer.cornerRadius = 16
        filterTrackersTableView.tableHeaderView = UIView()
    }

    private  func designOfLastCell(indexPath: IndexPath, cell: UITableViewCell) {
        let indexPathOfLastCell = IndexPath(row: filters.count - 1, section: 0)

        if indexPath == indexPathOfLastCell {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }

    func uploadLastFilterFromCoreData() {
        getLastFilterFromCoreData()
    }
    
    func sendLastFilterToCoreData(filter: String) {
        trackerCoreManager.sendLastChosenFilterToStore(filterName: filter)
    }

    func getLastFilterFromCoreData() {
        selectedFilter = trackerCoreManager.getLastChosenFilterFromStore()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension FilterTrackersViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        cellHeight
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        configureCell(cell: cell, indexPath: indexPath)
        designOfLastCell(indexPath: indexPath, cell: cell)
        designLastChosenFilter(cell: cell)

        return cell
    }

    func configureCell(cell: UITableViewCell, indexPath: IndexPath) {
        cell.backgroundColor = UIColor(named: "textFieldBackgroundColor")
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.text = filters[indexPath.row]
    }

    func designLastChosenFilter(cell: UITableViewCell) {
        if cell.textLabel?.text == selectedFilter {
            let selectionImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
            selectionImage.image = UIImage(systemName: "checkmark")
            cell.accessoryView = selectionImage
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { print("We have some problems here"); return }
        cell.selectionStyle = .none
        designLastChosenFilter(cell: cell)

        if let filterText = cell.textLabel?.text {
            sendLastFilterToCoreData(filter: filterText)
            filterDelegate?.getFilterFromPreviousVC(filter: filterText)
        }

        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryView = UIView()
    }
}
