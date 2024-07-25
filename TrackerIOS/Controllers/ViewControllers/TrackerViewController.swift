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
    lazy var currentDate = datePicker.date
    var dataUpdated: ( () -> Void )?
    weak var passTrackerToEditDelegate: PassTrackerToEditDelegate?
    let coreDataManager = TrackerCoreManager.shared
    private var categories = [TrackerCategory]()
    private var isSearchMode = false
    private var filteredData: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord]?
    private var newData: [TrackerCategory] {
        isSearchMode ? filteredData : categories
    }

    
    //MARK: Private UI properties
    
    let trackersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let stickyCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var stickyCollectionHeightConstraint: NSLayoutConstraint?
    
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
        setupStickyCollectionView()
        coreDataManager.printTrackerRecord()
        dataUpd()
        coreDataManager.setupPinnedFetchedResultsController()
    }
    
    //MARK: Actions
    @objc private func addNewTracker(_ sender: UIButton) {
        let createNewHabit = ChooseTypeTrackerViewController()
        let navigation = UINavigationController(rootViewController: createNewHabit)
        present(navigation, animated: true)
        createNewHabit.closeScreenDelegate = self
    }
    
    @objc func cellButtonTapped(_ sender: UIButton) {

        guard let result = findTrackerAndIndexPathByTouch(sender: sender)
        else { print("We cant find Tracker by touch"); return }

        guard let trackerRecord = isTrackerExistInTrackerRecord(
            tracker: result.Tracker, date: currentDate) else { print("Some problems here"); return }
        print("trackerRecord \(trackerRecord)")

        makeTrackerDoneOrUndone(trackerRecord: trackerRecord)
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
        trackersCollectionView.reloadData()
        showOrHidePlaceholder()
        navigationItem.searchController = searchField
        
    }
    
    @objc private func updateDataWithNewCategoryNames(notification: Notification) {
        coreDataManager.setupFetchedResultsController(weekDay: weekDay)
        trackersCollectionView.reloadData()
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
        
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self
        setupStickyCollectionView()
        trackersCollectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        
        trackersCollectionView.register(SuplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        trackersCollectionView.register(SuplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        
        view.addSubview(trackersCollectionView)
        view.addSubview(stickyCollectionView)
        trackersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        stickyCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stickyCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stickyCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stickyCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            trackersCollectionView.topAnchor.constraint(equalTo: stickyCollectionView.bottomAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
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
    
    private func dataUpd() {
        dataUpdated = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.trackersCollectionView.reloadData()
                self.stickyCollectionView.reloadData()
                self.setStickyCollectionHeight()
                self.showOrHidePlaceholder()
            }
        }
    }
    
    private func uploadDataFormCoreData() {
        updateDataFromCoreData(weekDay: weekDay)
        coreDataManager.delegate = self
    }
    
    func configureStickyCollection(cell: TrackerCollectionViewCell, indexPath: IndexPath) {
        guard let pinnedTrackers = coreDataManager.getAllPinnedTrackers() else {
            print("1We have some problems with decoding here")
            return
        }
        let pinnedTrackerCD = pinnedTrackers[indexPath.item]
        let pinnedTracker = Tracker(coreDataObject: pinnedTrackerCD)

        configureCell(tracker: pinnedTracker, cell: cell)
    }
    func configureTrackerCollection(cell: TrackerCollectionViewCell, indexPath: IndexPath) {
        guard let trackerCD = coreDataManager.object(at: indexPath) else {
            print("Hmm"); return }

        let tracker = Tracker(coreDataObject: trackerCD)
        configureCell(tracker: tracker, cell: cell)
    }
    
    func configureCell(tracker: Tracker,
                               cell: TrackerCollectionViewCell) {

        let trackerColor = UIColor(hex: tracker.color)
        let frameColor = trackerColor
        let today = Date()

        cell.titleLabel.text = tracker.name
        cell.emojiLabel.text = tracker.emoji
        cell.frameView.backgroundColor = frameColor
        cell.plusButton.backgroundColor = frameColor
        cell.plusButton.addTarget(self, action: #selector(cellButtonTapped), for: .touchUpInside)
        cell.plusButton.isEnabled = currentDate > today ? false : true

        let countOfDays = MainHelper.countOfDaysForTheTrackerInString(trackerId: tracker.id.uuidString)
        cell.daysLabel.text = countOfDays

        showDoneOrUndoneTaskForDatePickerDate(tracker: tracker, cell: cell)

        let interaction = UIContextMenuInteraction(delegate: self)
        cell.frameView.addInteraction(interaction)
    }
    
    func updateDataFromCoreData(weekDay: String) {
        coreDataManager.getAllTrackersForWeekday(weekDay: weekDay)
        categories = coreDataManager.fetchData()
    }
    
    private func makeTaskDone(trackToAdd: TrackerRecord) {
        coreDataManager.addTrackerRecord(trackerToAdd: trackToAdd)
        dataUpdated?()
    }

    private func makeTaskUndone(trackToRemove: TrackerRecord) {
        coreDataManager.removeTrackerRecordForThisDay(trackerToRemove: trackToRemove)
        dataUpdated?()
    }
    
    private func makeTrackerDoneOrUndone(trackerRecord: (TrackerRecord: TrackerRecord, isExist: Bool)) {
        if !trackerRecord.isExist {
            makeTaskDone(trackToAdd: trackerRecord.TrackerRecord)
        } else {
            makeTaskUndone(trackToRemove: trackerRecord.TrackerRecord)
        }
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
    
    func showDoneOrUndoneTaskForDatePickerDate(tracker: Tracker, cell: TrackerCollectionViewCell) {
        let trackerColor = UIColor(hex: tracker.color)
        let dateOnDatePicker = datePicker.date

        guard let check = isTrackerExistInTrackerRecordForDatePickerDate(
            tracker: tracker, dateOnDatePicker: dateOnDatePicker) else { print("Hmm, problems"); return }


        if check {
            designCompletedTracker(cell: cell, cellColor: trackerColor)
        } else {
            designInCompleteTracker(cell: cell, cellColor: trackerColor)
        }
    }
    
    func designCompletedTracker(cell: TrackerCollectionViewCell, cellColor: UIColor) {
        guard let color = UIColor(named: "ColorForCellPlus"),
              let image = UIImage(named: "done") else { return }

        let doneImage = image.withTintColor(color)
        cell.plusButton.setImage(doneImage, for: .normal)
        cell.plusButton.backgroundColor = cellColor.withAlphaComponent(0.3)
    }

    func designInCompleteTracker(cell: TrackerCollectionViewCell, cellColor: UIColor) {
        guard let color = UIColor(named: "ColorForCellPlus") else { return }
        let plusImage = UIImage(systemName: "plus")?.withTintColor(color, renderingMode: .alwaysOriginal)
        cell.plusButton.backgroundColor = cellColor.withAlphaComponent(1)
        cell.plusButton.setImage(plusImage, for: .normal)
        cell.plusButton.layer.cornerRadius = cell.plusButton.frame.width / 2
    }
    
    func isTrackerExistInTrackerRecordForDatePickerDate(tracker: Tracker, dateOnDatePicker: Date) -> Bool? {
        //        guard let trackerId = tracker.id else { return nil}

        let dateOnDatePickerString = MainHelper.dateToString(date: dateOnDatePicker)
        let trackerToCheck = TrackerRecord(id: tracker.id, date: dateOnDatePickerString)
        let check = coreDataManager.isTrackerExistInTrackerRecord(trackerToCheck: trackerToCheck)
        return check
    }
    
    func findTrackerAndIndexPathByTouch(sender: UIButton) -> (Tracker: TrackerCoreData, indexPath: IndexPath)? {

        let touchPoint = sender.convert(CGPoint.zero, to: view)
        //        print("buttonIndexPath \(touchPoint)")

        if trackersCollectionView.frame.contains(touchPoint) {
            //            print("Tracker")
            let convertedPoint = view.convert(touchPoint, to: trackersCollectionView)
            guard let indexPath = trackersCollectionView.indexPathForItem(at: convertedPoint),
                  let tracker = coreDataManager.trackersFetchedResultsController?.object(at: indexPath) else { return nil }
            return (tracker, indexPath)
        }
        if stickyCollectionView.frame.contains(touchPoint) {
            //            print("Sticky")
            let convertedPoint = view.convert(touchPoint, to: stickyCollectionView)
            //            print("convertedPoint \(convertedPoint)")

            guard let indexPath = stickyCollectionView.indexPathForItem(at: convertedPoint),
                  let tracker = coreDataManager.pinnedTrackersFetchedResultsController?.object(at: indexPath)
            else { print("Yhhh"); return nil}
            //            print(indexPath)
            return (tracker, indexPath)
        }
        return nil
    }
    
    func isTrackerExistInTrackerRecord(tracker: TrackerCoreData, date: Date) ->
    (TrackerRecord: TrackerRecord, isExist: Bool)? {
        guard let trackerID = tracker.id else { print("234"); return nil }
        let currentDateString = MainHelper.dateToString(date: date)
        let trackerToCheck = TrackerRecord(id: trackerID, date: currentDateString)
        let check = coreDataManager.isTrackerExistInTrackerRecord(trackerToCheck: trackerToCheck)

        return (trackerToCheck, check)
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
        trackersCollectionView.reloadData()
        showOrHidePlaceholder()
    }
}

extension TrackerViewController: DataProviderDelegate {
    
    func didUpdate(_ update: TrackersStoreUpdate) {
        trackersCollectionView.reloadData()
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
            trackersCollectionView.reloadData()
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
