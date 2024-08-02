//
//  TrackerViewController.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 3/11/24.
//

import Foundation
import UIKit

final class TrackerViewController: UIViewController {
    
    // MARK: - PRIVATE PROPERTIES
    let coreDataManager = TrackerCoreManager.shared
    weak var passTrackerToEditDelegate: PassTrackerToEditDelegate?
    private let searchField = UISearchController(searchResultsController: nil)
    lazy var userSelectedDate = datePicker.date
    private var categories = [TrackerCategory]()
    private var isSearchMode = false
    private var filteredData: [TrackerCategory] = []
    private var completedTrackers: [TrackerCategory]?
    
    var filterStr: String?
    var isFilter = false
    
    // MARK: - PRIVATE UI PROPERTIES
    private lazy var emptyDataPlaceholderView = TrackerEmptyDataPlaceholderView()
    let trackersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    lazy var filtersButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Filter", comment: "Text for filter button"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "IosBlue")
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var datePicker: UIDatePicker = {
        let date = UIDatePicker()
        date.addTarget(self, action: #selector(datePickerTapped), for: .valueChanged)
        date.calendar = Calendar(identifier: .gregorian)
        date.locale = Locale(identifier: "ru_RU")
        date.datePickerMode = .date
        date.preferredDatePickerStyle = .compact
        date.widthAnchor.constraint(equalToConstant: 120).isActive = true
        return date
    }()
    
    var weekDay: String {
        getWeekdayFromCurrentDate(currentDate: userSelectedDate)
    }
    
    //MARK: - View Life Cycles
    override func viewDidLoad() {
        configureUI()
        
        coreDataManager.getAllTrackersForWeekday(weekDay: weekDay)
        coreDataManager.setupPinnedFetchedResultsController()
        coreDataManager.delegate = self
        
        dataSourceCreation()
        
        configureEmptyDataPlaceholderVisability()
        setupTrackersCollectionView()
        setupSearchController()
        
        completedTrackers = []
        navBarItem()
        coreDataManager.printTrackerRecord()
        setupFiltersButton()
        setupNotification()
        AnalyticsService.openMainScreen()

    }
        
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.closeMainScreen()
    }
    
    // MARK: - PUBLICK GET METHODS
    func getCategoriesSectionCount() -> Int {
        categories.count
    }
    
    func getTrackerCategoriesItems(in section: Int) -> Int {
        categories[section].trackers.count
    }
    
    func getTrackerCategories() -> [TrackerCategory] {
        categories
    }
    
    func getUserSelectedDate() -> Date {
        userSelectedDate
    }
    
    // MARK: - CONFIGURE UI
    private func configureUI() {
        configureView()
        addSubviews()
        setupConstraints()
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
    }
    
    private func addSubviews() {
        view.addSubview(emptyDataPlaceholderView)
        view.addSubview(trackersCollectionView)
    }
    
    // MARK: - EMPTY DATA PLACEHOLDER
       func configureEmptyDataPlaceholderVisability() {
           let isDataEmpty = categories.isEmpty
           
           if isDataEmpty {
               emptyDataPlaceholderView.configure(isSearchMode: isSearchMode)
               showEmptyDataPlaceholder()
               
           } else {
               hideEmptyDataPlaceholder()
               showFilterButton()
           }
       }
       
       private func hideEmptyDataPlaceholder() {
           emptyDataPlaceholderView.isHidden = true
       }
       
       private func showEmptyDataPlaceholder() {
           emptyDataPlaceholderView.configure(isSearchMode: isSearchMode)
           emptyDataPlaceholderView.isHidden = false
           view.bringSubviewToFront(emptyDataPlaceholderView)
       }
       
       private func setupEmptyDataPlaceholderViewConstraints() {
           emptyDataPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               emptyDataPlaceholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
               emptyDataPlaceholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
               emptyDataPlaceholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               emptyDataPlaceholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
           ])
       }
    
    // MARK: - SEARCH CONTROLLER
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
    
    // MARK: - FILTER BUTTON
    private func setupFiltersButton() {
        view.addSubViews([filtersButton])
        
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func showFilterButton() {
        filtersButton.isHidden = false
    }
    
    private func hideFilterButton() {
        filtersButton.isHidden = true
    }
    
    // MARK: - TRACKERS COLLECTION VIEW
    func setupTrackersCollectionView() {
        trackersCollectionView.backgroundColor = .systemBackground
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self
        trackersCollectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        
        trackersCollectionView.register(SuplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        trackersCollectionView.register(SuplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
    }
    
    private func setupTrackerCollectionConstraint() {
        trackersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            trackersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func dataSourceCreation() {
        categories = []
        
        var pinnedTrackers: [Tracker] = []
        
        // смотрим запининые трекеры
        coreDataManager.pinnedTrackersFetchedResultsController?.fetchedObjects?.forEach({ trackerCD in
            let tracker = Tracker(coreDataObject: trackerCD)
            pinnedTrackers.append(tracker)
        })
        
        // если есть запининые трекеры
        if !pinnedTrackers.isEmpty {
            categories.append(TrackerCategory(header: NSLocalizedString("Pinned", comment: ""), trackers: pinnedTrackers))
        }
        
        let tackersWithCategories = coreDataManager.fetchData()
                
        tackersWithCategories.forEach { trackerCategory in
            var category: TrackerCategory = TrackerCategory(header: trackerCategory.header, trackers: [])
            trackerCategory.trackers.forEach { tracker in
                if !(tracker.isPinned ?? false) {
                    category.trackers.append(tracker)
                }
            }
            if !category.trackers.isEmpty {
                self.categories.append(category)
            }
        }
    }
    
    // MARK: - RECORDED & UNRECORDED TRACKERS
    private func findRecordedUnrecordedTrackersByID(allTrackersCD: [TrackerCoreData], recordedTrackerIDs: [String], isRecorded: Bool) -> [Tracker] {
        
        var allTrackers: [Tracker] = []
        
        allTrackersCD.forEach { trackerCD in
            let tracker = Tracker(coreDataObject: trackerCD)
            allTrackers.append(tracker)
        }
        
        let recordedSet = Set(recordedTrackerIDs)
        var resultTrackers: [Tracker] = []
        
        if isRecorded {
            resultTrackers = allTrackers.filter { recordedSet.contains($0.id) }
        } else {
            resultTrackers = allTrackers.filter { !recordedSet.contains($0.id) }
        }
        
        return resultTrackers
    }
    
    func showCompletedTrackers() {
        
        let dateString = dateToString(date: Date())
        let recordedTrackersIDs = getCompletedTrackers()
        
        guard let unpinnedTrackers = coreDataManager.trackersFetchedResultsController?.fetchedObjects else { return }
        guard let pinnedTrackers = coreDataManager.pinnedTrackersFetchedResultsController?.fetchedObjects else { return }

        let allTrackers = unpinnedTrackers + pinnedTrackers
        let recordedTrackers = findRecordedUnrecordedTrackersByID(allTrackersCD: allTrackers, recordedTrackerIDs: recordedTrackersIDs, isRecorded: true)
        
        if !recordedTrackers.isEmpty {
            categories = [.init(header: NSLocalizedString("Completed trackers", comment: ""), trackers: recordedTrackers)]
        } else {
            isSearchMode = true
            categories = []
        }
        
        DispatchQueue.main.async {
            self.trackersCollectionView.reloadData()
            self.configureEmptyDataPlaceholderVisability()
        }
    }
    
    func showUncompletedTrackers() {
        
        let dateString = dateToString(date: Date())
        let recordedTrackersIDs = getCompletedTrackers()
        
        guard let unpinnedTrackers = coreDataManager.trackersFetchedResultsController?.fetchedObjects else { return }
        guard let pinnedTrackers = coreDataManager.pinnedTrackersFetchedResultsController?.fetchedObjects else { return }

        let allTrackers = unpinnedTrackers + pinnedTrackers
        let unrecordedTrackers = findRecordedUnrecordedTrackersByID(allTrackersCD: allTrackers, recordedTrackerIDs: recordedTrackersIDs, isRecorded: false)
        
        if !unrecordedTrackers.isEmpty {
            categories = [.init(header: NSLocalizedString("Uncompleted trackers", comment: ""), trackers: unrecordedTrackers)]
        } else {
            isSearchMode = true
            categories = []
        }
        
        DispatchQueue.main.async {
            self.trackersCollectionView.reloadData()
            self.configureEmptyDataPlaceholderVisability()
        }
    }
    
    func showTodayTrackers() {
        
    }

    
    // MARK: - Actions
    @objc private func addNewTracker(_ sender: UIButton) {
        let createNewHabit = ChooseTypeTrackerViewController()
        let navigation = UINavigationController(rootViewController: createNewHabit)
        present(navigation, animated: true)
        AnalyticsService.addTrackerButton()
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
    }
    
    @objc private func filterButtonTapped(_ sender: UIButton) {
        let filterVC = FilterTrackersViewController()
        let navVC = UINavigationController(rootViewController: filterVC)
        filterVC.filterDelegate = self
        AnalyticsService.filterButtonTapped()
        present(navVC, animated: true)
    }
    
    @objc private func datePickerTapped(_ sender: UIDatePicker) {
        
        let selectedDate = sender.date
        userSelectedDate = selectedDate
        sender.removeFromSuperview()
        
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.weekday], from: userSelectedDate)
        let weekDay = dateComponents.weekday
        let weekDayString = dayNumberToDayString(weekDayNumber: weekDay)
        
        showCorrectTrackersWithFilter()
        coreDataManager.getAllTrackersForWeekday(weekDay: weekDayString)
        trackersCollectionView.reloadData()
        configureEmptyDataPlaceholderVisability()
        navigationItem.searchController = searchField

    }
    
    @objc private func updateDataWithNewCategoryNames(notification: Notification) {
        coreDataManager.getAllTrackersForWeekday(weekDay: weekDay)
        trackersCollectionView.reloadData()
    }
    
    //TODO: Реализовать через enum, чтобы не жанглировать строками
    func dayNumberToDayString(weekDayNumber: Int?) -> String {
        let weekDay: [Int:String] = [1: "Вс", 2: "Пн", 3: "Вт", 4: "Ср",
                                     5: "Чт", 6: "Пт", 7: "Сб"]
        guard let weekDayNumber = weekDayNumber,
              let result = weekDay[weekDayNumber] else { return ""}
        return result
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(updateDataWithNewCategoryNames),
            name: Notification.Name("renameCategory"), object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(closeFewVCAfterCreatingTracker),
            name: Notification.Name("cancelCreatingTracker"),
            object: nil)
    }
    
    
    private func navBarItem() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "PlusButton"),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(addNewTracker))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "ColorForPlusButton")
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        let dateToString = formatter.string(from: userSelectedDate)
        return dateToString
    }
    
    func dataUpd() {
        dataSourceCreation()
        DispatchQueue.main.async {
            self.trackersCollectionView.reloadData()
            self.configureEmptyDataPlaceholderVisability()
        }
    }
    
    private func uploadDataFormCoreData() {
        updateDataFromCoreData(weekDay: weekDay)
        coreDataManager.delegate = self
    }
    
    func getWeekdayFromCurrentDate(currentDate: Date) -> String {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.weekday], from: currentDate)
        let weekDay = dateComponents.weekday
        let weekDayString = dayNumberToDayString(weekDayNumber: weekDay)
        return weekDayString
    }
    
    func updateDataFromCoreData(weekDay: String) {
        coreDataManager.getAllTrackersForWeekday(weekDay: weekDay)
        categories = coreDataManager.fetchData()
    }
    
    func showCorrectTrackersWithFilter() {
        if isFilter {
            guard let filter = filterStr else { print("Ooops"); return }
            getFilterFromPreviousVC(filter: filter)
        } else {
            uploadDataFormCoreData()
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
        trackersCollectionView.reloadData()
        configureEmptyDataPlaceholderVisability()
    }
}

// MARK: - CLOSE SCREEN AFTER CREATE TRACKER EXTANSION
extension TrackerViewController: CloseScreenDelegate {
    @objc func closeFewVCAfterCreatingTracker() {
        self.dismiss(animated: true)
    }
}

// MARK: - UPDATE DATA DELEGATE
extension TrackerViewController: DataProviderDelegate {
    func didUpdate(_ update: TrackersStoreUpdate) {
        dataUpd()
    }
}

// MARK: - CONSTRAINTS
extension TrackerViewController {
    
    private func setupConstraints() {
        setupEmptyDataPlaceholderViewConstraints()
        setupTrackerCollectionConstraint()
    }
}
