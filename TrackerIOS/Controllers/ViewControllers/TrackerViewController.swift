//
//  TrackerViewController.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 3/11/24.
//

import Foundation
import UIKit

final class TrackerViewController: UIViewController {
    
    //MARK: Private properties
    
    private let searchField = UISearchController(searchResultsController: nil)
    private var trackers: [String] {
        newData.map { $0.header }
    }
    private lazy var currentDate = datePicker.date
    var categories: [TrackerCategory] {
    let categoryStorage = CategoryDB.shared
        if let dataBase = categoryStorage.getDataBaseFromStorage() {
            return  dataBase
        } else {
            return []
        }
    }
    private var newDateCategories: [TrackerCategory]?
    private var isSearchMode = false
    private var filteredData: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord]?
    private var newData: [TrackerCategory] {
        if let categories = newDateCategories {
            categories
        } else {
            isSearchMode ? filteredData : categories
        }
    }
    
    //MARK: Private UI properties
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        return collectionView
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let date = UIDatePicker()
        date.addTarget(self, action: #selector(datePickerTapped), for: .valueChanged)
        date.calendar = Calendar(identifier: .gregorian)
        date.locale = Locale(identifier: "ru_RU")
        date.datePickerMode = .date
        date.preferredDatePickerStyle = .compact
        date.widthAnchor.constraint(equalToConstant: 120).isActive = true
        return date
    }()
    private lazy var textLabel = UILabel()
    private lazy var emptyTrackerImage = UIImageView()
    
    private lazy var labelWithTextForEmpty: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = .blackDayIOS
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    //MARK: View Life Cycles
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        setupCollectionView()
        showPlaceholderForEmptyScreen()
        setupSearchController()
        completedTrackers = []
        showOrHidePlaceholder()
        navBarItem()
 
    }
    
    //MARK: Actions
    @objc private func addNewTracker(_ sender: UIButton) {
        let createNewHabit = ChooseTypeTrackerViewController()
        let navigation = UINavigationController(rootViewController: createNewHabit)
        present(navigation, animated: true)
    }
    
    @objc private func cellButtonTapped(_ sender: UIButton) {
        let buttonIndexPath = sender.convert(CGPoint.zero, to: self.collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: buttonIndexPath),
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else { return }
        
        let category = newData[indexPath.section]
        let tracker = category.trackers[indexPath.row]
        let currentDateString = dateToString(date: self.currentDate)
        guard let cellColor = cell.frameView.backgroundColor else { print("Color problem"); return }
        
        let trackForAdd = TrackerRecord(id: tracker.id, date: currentDateString)

        guard let check = completedTrackers?.contains(where: { $0.id == trackForAdd.id && $0.date == trackForAdd.date})  else { return }
        
        if !check {
            makeTaskDone(trackForAdd: trackForAdd, cellColor: cellColor, cell: cell)
        } else {
            makeTaskUndone(trackForAdd: trackForAdd, cellColor: cellColor, cell: cell)
        }

    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
    }
    
    @objc private func datePickerTapped(_ sender: UIDatePicker) {
        newDateCategories = nil
        
        let selectedDate = sender.date
        currentDate = selectedDate
        sender.removeFromSuperview()
        
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.weekday], from: currentDate)
        let weekDay = dateComponents.weekday
        let weekDayString = dayNumberToDayString(weekDayNumber: weekDay)
        
        newDateCategories = filterNewDataFromData(weekDay: weekDayString)
        collectionView.reloadData()
        showOrHidePlaceholder()
        navigationItem.searchController = searchField
        
    }
    
    //MARK: Private Methods
    
    private func dayNumberToDayString(weekDayNumber: Int?) -> String {
        let weekDay: [Int:String] = [1: "Вс", 2: "Пн", 3: "Вт", 4: "Ср",
                                     5: "Чт", 6: "Пт", 7: "Сб"]
        guard let weekDayNumber = weekDayNumber,
              let result = weekDay[weekDayNumber] else { return ""}
        return result
    }
    
    
    private func setupSearchController() {
        searchField.searchResultsUpdater = self
        searchField.obscuresBackgroundDuringPresentation = false
        searchField.hidesNavigationBarDuringPresentation = false
        searchField.searchBar.placeholder = "Поиск"
        
        navigationItem.searchController = searchField
        definesPresentationContext = false
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupCollectionView() {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        
        collectionView.register(SuplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.register(SuplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func navBarItem() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "PlusButton"),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(addNewTracker))
        self.navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    private func showOrHidePlaceholder() {
        newData.isEmpty ? showPlaceholderForEmptyScreen() : hidePlaceholderForEmptyScreen()
    }
    private func hidePlaceholderForEmptyScreen() {
        emptyTrackerImage.isHidden = true
        textLabel.isHidden = true
    }
    private func showPlaceholderForEmptyScreen() {
        if isSearchMode {
            emptyTrackerImage.image = UIImage(named: "searchPlaceholder")
            textLabel.text = "Ничего не найдено"
        } else {
            emptyTrackerImage.image = UIImage(named: "FallingStar")
            textLabel.text = "Что будем отслеживать?"
        }
        
        emptyTrackerImage.isHidden = false
        textLabel.isHidden = false
        
        textLabel.font = .systemFont(ofSize: 12, weight: .medium)
        textLabel.textAlignment = .center
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyTrackerImage.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyTrackerImage)
        view.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            emptyTrackerImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyTrackerImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            textLabel.topAnchor.constraint(equalTo: emptyTrackerImage.bottomAnchor, constant: 8),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        let dateToString = formatter.string(from: currentDate)
        return dateToString
    }
    
    private func configureCell(cell: TrackerCollectionViewCell, indexPath: IndexPath) {
        let categories = newData[indexPath.section]
        let trackersInCategory = categories.trackers
        let tracker = trackersInCategory[indexPath.row]
        let frameColor = tracker.colorName

        cell.titleLabel.text = tracker.name
        cell.frameView.backgroundColor = frameColor
        cell.emojiLabel.text = tracker.emoji
        cell.plusButton.backgroundColor = frameColor
        cell.plusButton.addTarget(self, action: #selector(cellButtonTapped), for: .touchUpInside)
        cell.plusButton.isEnabled = true
        
        showDoneOrUndoneTask(tracker: tracker, cell: cell)
        
    }
    
    private func makeTaskDone(trackForAdd: TrackerRecord, cellColor: UIColor, cell: TrackerCollectionViewCell) {
        completedTrackers?.append(trackForAdd)
        let doneImage = UIImage(named: "done")
        cell.plusButton.setImage(doneImage, for: .normal)
        cell.plusButton.backgroundColor = cellColor.withAlphaComponent(0.3)
        cell.days += 1
        cell.daysLabel.text = "\(cell.days) день"
    }
    
    private func makeTaskUndone(trackForAdd: TrackerRecord, cellColor: UIColor, cell: TrackerCollectionViewCell) {
        let plusImage = UIImage(systemName: "plus")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        cell.plusButton.backgroundColor = cellColor.withAlphaComponent(1)
        cell.plusButton.setImage(plusImage, for: .normal)
        cell.plusButton.layer.cornerRadius = cell.plusButton.frame.width / 2
        
        cell.days -= 1
        cell.daysLabel.text = "\(cell.days) день"
        if let index = completedTrackers?.firstIndex(where: { $0.id == trackForAdd.id && $0.date == trackForAdd.date}) {
            completedTrackers?.remove(at: index)
        }
    }
    
    private func showDoneOrUndoneTask(tracker: Tracker, cell: TrackerCollectionViewCell) {
        let dateOnDatePicker = datePicker.date
        let dateOnDatePickerString = dateToString(date: dateOnDatePicker)
        let color = tracker.colorName
        
        guard let check = completedTrackers?.contains(where: { $0.id == tracker.id && $0.date == dateOnDatePickerString }) else { return }
        
        if !check {
            let plusImage = UIImage(systemName: "plus")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            cell.plusButton.setImage(plusImage, for: .normal)
        } else {

            let doneImage = UIImage(named: "done")
            cell.plusButton.setImage(doneImage, for: .normal)
            cell.plusButton.backgroundColor = color.withAlphaComponent(0.3)
        }
    }
    
    private func filterNewDataFromData(weekDay: String) -> [TrackerCategory] {
        var result: [TrackerCategory] = []
        var element: [Tracker] = []
        
        for category in newData {
            for i in category.trackers {
                if i.schedule.contains(weekDay) {
                    element.append(i)
                }
            }
            if !element.isEmpty {
                result.append(TrackerCategory(header: category.header, trackers: element))
                element = []
            }
        }
        return result
    }
}

//MARK: Extensions

extension TrackerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchBarText = searchController.searchBar.text?.lowercased(),
           !searchBarText.isEmpty {
            filteredData = categories.map { category in
                let filteredTrackers = category.trackers.filter { $0.name.lowercased().contains(searchBarText) }
                return TrackerCategory(header: category.header, trackers: filteredTrackers)
            }
            filteredData = filteredData.filter({ !$0.trackers.isEmpty })
        } else {
            filteredData = categories
        }
        collectionView.reloadData()
        showOrHidePlaceholder()
    }
    
    
}

extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newData[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else { print("We have some problems with CustomCell");
            return UICollectionViewCell()
        }
        
        configureCell(cell: cell, indexPath: indexPath)
        
        return cell
    }
    

    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id = ""
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SuplementaryView
        view.label.text = newData[indexPath.section].header
        return view
    }
    
}

extension TrackerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell
        cell?.titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell
        cell?.titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2 - 9, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }
}
