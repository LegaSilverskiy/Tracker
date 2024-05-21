//
//  ScheduleViewConroller.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 4/18/24.
//

import UIKit

final class ScheduleViewConroller: UIViewController {
    
    //MARK: UI properties
    private lazy var tableForSchedule: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellSchedule")
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableHeaderView = UIView()
        return tableView
    }()
    
    private lazy var readyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(readyButtonTap), for: .touchUpInside)
        return button
    }()
    
    //MARK: Private properties
    private let arrWeek = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    private var indexes = [Int]()
    var scheduleToPass: ( (String) -> Void )?
    private let rowHeight = CGFloat(75)
    
    
    //MARK: Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func getString(array: [Int]) -> String {
        if array.count == 7 { return "Каждый день"} else {
            let daysOfWeek = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
            let arrayOfStrings = array.map { daysOfWeek[$0] }
            let resultString = arrayOfStrings.joined(separator: ", ")
            return resultString
        }
    }
    //MARK: Actions
    @objc private func readyButtonTap() {
        let scheduleString = getString(array: indexes)
        scheduleToPass?(scheduleString)
        dismiss(animated: true)
    }
    
    @objc private func toggleAction(_ sender: UISwitch) {
        guard let cell = sender.superview as? UITableViewCell,
              let indexPath = tableForSchedule.indexPath(for: cell) else { return }
        if sender.isOn {
            indexes.append(indexPath.row)
        } else {
            indexes.removeAll(where: { $0 == indexPath.row })
        }
    }
    
    private func setupUI() {
        self.title = "Расписание"
        
        let tableViewHeight = CGFloat(arrWeek.count) * rowHeight
        
        view.backgroundColor = .systemBackground
        view.addSubview(tableForSchedule)
        view.addSubview(readyButton)
        
        tableForSchedule.translatesAutoresizingMaskIntoConstraints = false
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableForSchedule.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableForSchedule.heightAnchor.constraint(equalToConstant: tableViewHeight),
            tableForSchedule.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableForSchedule.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

//MARK: Extensions

extension ScheduleViewConroller: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrWeek.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellSchedule")
        cell.textLabel?.text = arrWeek[indexPath.row]
        cell.backgroundColor = .backgroundDayIOS
        
        let toggle = UISwitch()
        toggle.onTintColor = .systemBlue
        toggle.addTarget(self, action: #selector(toggleAction), for: .valueChanged)
        cell.accessoryView = toggle
        
        if indexPath.row == arrWeek.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        
        
        return cell
    }
    
}

extension ScheduleViewConroller: UITableViewDelegate {
    
}
