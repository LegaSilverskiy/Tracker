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

    private let coreDataManager = TrackerCoreManager.shared
    private var categories = [TrackerCategory]()
    private var isSearchMode = false
    private var filteredData: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord]?
    private var newData: [TrackerCategory] {
        isSearchMode ? filteredData : categories
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
        let localizedTextForEmptyScreen = NSLocalizedString("What are we going to track?", comment: "Text for empty screen")
        label.text = localizedTextForEmptyScreen
        label.textColor = .blackDayIOS
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    private var weekDay: String {
        get {
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.weekday], from: currentDate)
            let weekDay = dateComponents.weekday
            let weekDayString = dayNumberToDayString(weekDayNumber: weekDay)
            return weekDayString
        }
    }
    
    //MARK: View Life Cycles
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        coreDataManager.setupFetchedResultsController(weekDay: weekDay)
        categories = coreDataManager.fetchData()
        coreDataManager.delegate = self
        setupCollectionView()
        showPlaceholderForEmptyScreen()
        setupSearchController()
        completedTrackers = []
        showOrHidePlaceholder()
        navBarItem()
        coreDataManager.printTrackerRecord()
    }
    
    //MARK: Actions
    @objc private func addNewTracker(_ sender: UIButton) {
        let createNewHabit = ChooseTypeTrackerViewController()
        let navigation = UINavigationController(rootViewController: createNewHabit)
        present(navigation, animated: true)
        createNewHabit.closeScreenDelegate = self
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

        let check = coreDataManager.isTrackerExistInTrackerRecord(trackerToCheck: trackForAdd)
        
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
        
        let selectedDate = sender.date
        currentDate = selectedDate
        sender.removeFromSuperview()
        
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.weekday], from: currentDate)
        let weekDay = dateComponents.weekday
        let weekDayString = dayNumberToDayString(weekDayNumber: weekDay)
        
        coreDataManager.setupFetchedResultsController(weekDay: weekDayString)
        collectionView.reloadData()
        showOrHidePlaceholder()
        navigationItem.searchController = searchField
        
    }
    
    @objc private func updateDataWithNewCategoryNames(notification: Notification) {
        coreDataManager.setupFetchedResultsController(weekDay: weekDay)
        collectionView.reloadData()
    }
    
    //MARK: Private Methods
    //TODO: Реализовать через enum, чтобы не жанглировать строками
    private func dayNumberToDayString(weekDayNumber: Int?) -> String {
        let weekDay: [Int:String] = [1: "Вс", 2: "Пн", 3: "Вт", 4: "Ср",
                                     5: "Чт", 6: "Пт", 7: "Сб"]
        guard let weekDayNumber = weekDayNumber,
              let result = weekDay[weekDayNumber] else { return ""}
        return result
    }
    //TODO: Реализовать removeObserver, чтобы избежать утечек памяти
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateDataWithNewCategoryNames), name: Notification.Name("renameCategory"), object: nil)
    }
    
    private func setupSearchController() {
        let localizedTextForSearch = NSLocalizedString("Search", comment: "Text for placeholder in search bar")
        searchField.searchResultsUpdater = self
        searchField.obscuresBackgroundDuringPresentation = false
        searchField.hidesNavigationBarDuringPresentation = false
        searchField.searchBar.placeholder = localizedTextForSearch
        
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
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "ColorForPlusButton")
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    private func showOrHidePlaceholder() {
        let isDataEmpty = coreDataManager.isCoreDataEmpty
        isDataEmpty ? showPlaceholderForEmptyScreen() : hidePlaceholderForEmptyScreen()
    }
    private func hidePlaceholderForEmptyScreen() {
        emptyTrackerImage.isHidden = true
        textLabel.isHidden = true
    }
    private func showPlaceholderForEmptyScreen() {
        let localizedTextForEmptyScreen = NSLocalizedString("What are we going to track?", comment: "Text for empty screen")
        let localizedTextForEmptyScreenIftrackersNotFound = NSLocalizedString("Nothing found", comment: "Text for empty screen")
        
        if isSearchMode {
            emptyTrackerImage.image = UIImage(named: "searchPlaceholder")
            textLabel.text = localizedTextForEmptyScreenIftrackersNotFound
        } else {
            emptyTrackerImage.image = UIImage(named: "FallingStar")
            textLabel.text = localizedTextForEmptyScreen
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
        guard let tracker = coreDataManager.object(at: indexPath) else { return }
        
        let trackerColor = UIColor(hex: tracker.colorName ?? "#000000")
        let frameColor = trackerColor
        let today = Date()
        
        cell.titleLabel.text = tracker.name
        cell.emojiLabel.text = tracker.emoji
        cell.frameView.backgroundColor = frameColor
        cell.plusButton.backgroundColor = frameColor
        cell.plusButton.addTarget(self, action: #selector(cellButtonTapped), for: .touchUpInside)
        cell.plusButton.isEnabled = currentDate > today ? false : true
        
        showDoneOrUndoneTask(tracker: tracker, cell: cell)
    }
    
    private func makeTaskDone(trackForAdd: TrackerRecord, cellColor: UIColor, cell: TrackerCollectionViewCell) {
        coreDataManager.addTrackerRecord(trackerToAdd: trackForAdd)
        
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
        
        coreDataManager.removeTrackerRecord(trackerToRemove: trackForAdd)
    }
    
    //TODO: Реализвать через публичную функцию
    private func showDoneOrUndoneTask(tracker: TrackerCoreData, cell: TrackerCollectionViewCell) {
        let dateOnDatePicker = datePicker.date
        let dateOnDatePickerString = dateToString(date: dateOnDatePicker)
        
        let trackerColor = UIColor(hex: tracker.colorName ?? "#000000")
        let color = trackerColor
        
        guard let trackerId = tracker.id else { return }
        let trackerToCheck = TrackerRecord(id: trackerId, date: dateOnDatePickerString)
        
        let check = coreDataManager.isTrackerExistInTrackerRecord(trackerToCheck: trackerToCheck)
        
        if !check {
            let plusImage = UIImage(systemName: "plus")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            cell.plusButton.setImage(plusImage, for: .normal)
        } else {
            let doneImage = UIImage(named: "done")
            cell.plusButton.setImage(doneImage, for: .normal)
            cell.plusButton.backgroundColor = color.withAlphaComponent(0.3)
        }
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
        coreDataManager.numberOfRowsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        coreDataManager.numberOfSections
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
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SuplementaryView else {
            print("We have some problems with header"); return UICollectionReusableView()
        }
        
        if let headers = coreDataManager.fetchedResultsController?.sections  {
            view.label.text = headers[indexPath.section].name
        }
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

extension TrackerViewController: DataProviderDelegate {
    
    func didUpdate(_ update: TrackersStoreUpdate) {
        collectionView.reloadData()
        showOrHidePlaceholder()
    }
}
//MARK: Переделать череp enum
extension TrackerViewController: FilterCategoryDelegate {
    func getFilterFromPreviousVC(filter: String) {
        switch filter {
        case "Все трекеры":
            coreDataManager.setupFetchedResultsController(weekDay: weekDay)
        case "Трекеры на сегодня":
            let calendar = Calendar.current
            let date = Date()
            let dateComponents = calendar.dateComponents([.weekday], from: date)
            let weekDay = dateComponents.weekday
            let weekDayString = dayNumberToDayString(weekDayNumber: weekDay)
            print(weekDayString)
            coreDataManager.setupFetchedResultsController(weekDay: weekDayString)
            collectionView.reloadData()
            datePicker.date = date
        case "Завершенные": dismiss(animated: true)
        default: dismiss(animated: true)
        }
    }
}
extension TrackerViewController: CloseScreenDelegate {
    func closeFewVCAfterCreatingTracker() {
        self.dismiss(animated: true)
    }
}
