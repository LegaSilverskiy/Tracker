//
//  StatisticsViewController.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 3/11/24.
//

import UIKit

class StatisticViewController: UIViewController {

    // MARK: - UI Properties
    private lazy var swooshImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "placeholder")
        return image
    }()
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.text = "Анализировать пока нечего"
        return label
    }()

    let tableView = UITableView()

    // MARK: - Other Properties
    let titleData = ["Лучший период", "Идеальные дни", "Трекеров завершено", "Среднее значение"
    ]

    let rowHeight = CGFloat(102)

    var tableViewHeight: CGFloat {
        rowHeight * CGFloat(titleData.count)
    }

    var viewModel: StatisticViewModelProtocol

    // MARK: - Initializers
    init(viewModel: StatisticViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        dataBinding()

    }

    // Мы сюда поставили метод забора данных так как экран у нас загружается вместе с таббаром
    // и данные не обновляются сразу при регистрации новой привычки
    override func viewWillAppear(_ animated: Bool) {
        uploadDataFromCoreData()
    }

    // MARK: - Private Methods
    func uploadDataFromCoreData() {
        viewModel.calculateTheBestPeriod()
        viewModel.calculationOfIdealDays()
        viewModel.countOfCompletedTrackers()
        viewModel.trackerRecordsPerDay()
        showOrHidePlaceholder()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        setupTableView()

        view.addSubViews([tableView])

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: tableViewHeight)
        ])
    }

    private func dataBinding() {
        viewModel.updateData = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.showOrHidePlaceholder()
            }
        }
    }

    private func showOrHidePlaceholder() {
        if viewModel.isStatisticsEmpty() {
            showPlaceholderForEmptyScreen()
        } else {
            hidePlaceholderForEmptyScreen()
        }
    }

    private func showPlaceholderForEmptyScreen() {

        swooshImage.isHidden = false
        textLabel.isHidden = false
        tableView.isHidden = true

        view.addSubViews([swooshImage, textLabel])

        NSLayoutConstraint.activate([
            swooshImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            swooshImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            textLabel.topAnchor.constraint(equalTo: swooshImage.bottomAnchor, constant: 8),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func hidePlaceholderForEmptyScreen() {
        swooshImage.isHidden = true
        textLabel.isHidden = true

        tableView.isHidden = false
    }
}
