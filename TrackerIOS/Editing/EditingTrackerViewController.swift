//
//  EditingTrackerViewController.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/24/24.
//

import UIKit

final class EditingTrackerViewController: UIViewController {
    
    var tableViewRows = ["Категория", "Расписание"]

    var arrayOfEmoji = MainHelper.arrayOfEmoji

    var arrayOfColors = MainHelper.arrayOfColors

    let coreDataManager = TrackerCoreManager.shared

    var trackerName: String? {
        didSet {
            updateSaveButton?()
        }
    }

    var emoji: String? {
        didSet {
            updateSaveButton?()
        }
    }

    var color: String? {
        didSet {
            updateSaveButton?()
        }
    }

    var category: String? {
        didSet {
            updateSaveButton?()
        }
    }

    var countOfCompletedDays: String? {
        didSet {
            updateSaveButton?()
        }
    }

    var schedule: String? {
        didSet {
            updateSaveButton?()
        }
    }

    var initialTrackerCategory: String?

    var indexPath: IndexPath?

    var trackerId: UUID?

    var updateSaveButton: ( () -> Void )?

    var emojiIndexPath: IndexPath? {
        guard let emoji,
              let emojiIndex = arrayOfEmoji.firstIndex(of: emoji) else { print("Oops"); return nil}
        return IndexPath(row: emojiIndex, section: 0)
    }

    var colorIndexPath: IndexPath? {
        guard let color,
              let colorIndex = arrayOfColors.firstIndex(of: color) else { print("Oops"); return nil}
        return IndexPath(row: colorIndex, section: 0)
    }

    var isPinned = false

    func getBackToMainScreen() {
        let cancelCreatingTrackerNotification = Notification.Name("cancelCreatingTracker")
        NotificationCenter.default.post(name: cancelCreatingTrackerNotification, object: nil)
    }

    func createNewTracker() {
        guard let name = trackerName,
              let category = category,
              let color = color,
              let emoji = emoji,
              let schedule = schedule else {
            print("Smth's going wrong here"); return
        }

        let newTask = TrackerCategory(
            header: category,
            trackers: [Tracker(id: UUID(),
                               name: name,
                               color: color,
                               emoji: emoji,
                               schedule: schedule,
                               isPinned: isPinned)
            ])
        coreDataManager.createNewTracker(newTracker: newTask)
        getBackToMainScreen()
    }

    func isAllFieldsFilled() -> Bool {
        let allFieldsFilled =
        trackerName != nil &&
        trackerName != "" &&
        category != nil &&
        schedule != nil &&
        emoji != nil &&
        color != nil
        return allFieldsFilled
    }

    func getTrackerDataForEditing(tracker: TrackerCoreData) {
        guard let trackerID = tracker.id else { return }
        let countOfDays = MainHelper.countOfDaysForTheTrackerInString(trackerId: trackerID.uuidString)

        trackerId = tracker.id
        trackerName = tracker.name
        category = tracker.category?.header
        schedule = tracker.schedule
        emoji = tracker.emoji
        color = tracker.colorName
        countOfCompletedDays = countOfDays
        
        initialTrackerCategory = tracker.category?.header
        isPinned = tracker.isPinned
    }

    func updateTracker() {
        if isPinned {
            //            print("Tracker is Pinned")
            updatePinnedTracker()
        } else {
            //            print("Tracker is NOT Pinned")
            updateUnpinnedTracker()
        }
    }

    func updatePinnedTracker() {
        guard let indexPath,
              let tracker = coreDataManager.pinnedTrackersFetchedResultsController?.object(at: indexPath) else { print("Ooops"); return }

        if isCategoryChanged() {
            changeTrackerCategory(tracker: tracker)
        } else {
            updateTracker(tracker: tracker)
        }
    }

    func updateTracker(tracker: TrackerCoreData) {
        tracker.name = trackerName
        tracker.schedule = schedule
        tracker.emoji = emoji
        tracker.colorName = color

        coreDataManager.save()

        print("Tracker updated successfully ✅")
    }

    func updateUnpinnedTracker() {

        guard let indexPath,
              let tracker = coreDataManager.trackersFetchedResultsController?.object(at: indexPath) else {
            print("We cant find tracker"); return }

        if isCategoryChanged() {
            updateTracker(tracker: tracker)
            changeTrackerCategory(tracker: tracker)
        } else {
            updateTracker(tracker: tracker)
        }
    }

    func isCategoryChanged() -> Bool {
        return category != initialTrackerCategory
    }

    func changeTrackerCategory(tracker: TrackerCoreData) {
        guard let category,
              let initialTrackerCategory,
              let id = tracker.id,
              let name = tracker.name,
              let colorHex = tracker.colorName,
              let emoji = tracker.emoji,
              let schedule = tracker.schedule else {
            print("Hmmmm, bad thing"); return
        }

        let trackerWithAnotherCategory = TrackerCategory(
            header: category,
            trackers: [Tracker(
                id: id,
                name: name,
                color: colorHex,
                emoji: emoji,
                schedule: schedule,
                isPinned: tracker.isPinned
            )
            ])

        print(trackerWithAnotherCategory)

        coreDataManager.createNewTracker(newTracker: trackerWithAnotherCategory)

        coreDataManager.deleteTrackerFromCategory(categoryName: initialTrackerCategory, trackerIDToDelete: id)

        //        let allDataAfter = coreDataManager.fetchData()
        //        print("allData after: \(allDataAfter)")

    }



    // MARK: - UI Properties
    lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.text = countOfCompletedDays
        return label
    }()
    lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.text = trackerName
        textField.placeholder = "Введите название трекера"
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 75))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        textField.textAlignment = .left
        textField.layer.cornerRadius = 10
        textField.backgroundColor = UIColor(named: "textFieldBackgroundColor")
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        textField.delegate = self
        return textField
    }()
    lazy var cancelButton = setupButtons(title: "Отмена")
    lazy var saveButton = setupButtons(title: "Сохранить")
    lazy var exceedLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .red
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.isHidden = true
        return label
    }()
    lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalCentering
        return stack
    }()

    let emojiCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let colorsCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    let tableViewForEditing = UITableView()
    let rowHeight = CGFloat(75)

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        dataBinding()
        setupUI()
    }

    // MARK: - IB Actions

    func dataBinding() {
        updateSaveButton = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async { [self] in
                self.isCreateButtonEnable()
            }
        }
    }

    @objc private func clearTextButtonTapped(_ sender: UIButton) {
        trackerNameTextField.text = ""
        isCreateButtonEnable()
    }

    @objc func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @objc func createButtonTapped(_ sender: UIButton) {
        updateTracker()
        dismiss(animated: true)
    }

    // MARK: - Private Methods

    private func setupTextField() {

        let rightPaddingView = UIView()
        let clearTextFieldButton: UIButton = {
            let button = UIButton(type: .custom)
            let configuration = UIImage.SymbolConfiguration(pointSize: 17)
            let imageColor = UIColor(named: "GrayIOS") ?? .lightGray
            let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: configuration)?
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(imageColor)
            button.setImage(image, for: .normal)
            button.addTarget(self, action: #selector(clearTextButtonTapped), for: .touchUpInside)
            return button
        }()

        lazy var clearTextStack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.addArrangedSubview(clearTextFieldButton)
            stack.addArrangedSubview(rightPaddingView)
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.widthAnchor.constraint(equalToConstant: 28).isActive = true
            return stack
        }()

        trackerNameTextField.rightView = clearTextStack
        trackerNameTextField.rightViewMode = .whileEditing
    }

    func isCreateButtonEnable() {
        if isAllFieldsFilled() {
            saveButtonIsActive()
        } else { saveButtonIsNotActive()
        }
    }

    func saveButtonIsActive() {
        saveButton.isEnabled = true
        saveButton.backgroundColor = UIColor(named: "ColorForPlusButton")
    }

    func saveButtonIsNotActive() {
        saveButton.isEnabled = false
        saveButton.backgroundColor = UIColor(named: "GrayIOS")
    }

    private func setupUI() {

        self.title = "Редактирование привычки"
        view.backgroundColor = .systemBackground

        setupTextField()
        setupContentStack()
        setupScrollView()
        setupTableView()
        setupEmojiCollectionView()
        setupColorsCollectionView()

    }

    private func setupButtons(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(named: "ColorForCellPlus"), for: .normal)
        button.backgroundColor = UIColor(named: "ColorForPlusButton")
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }

    func showLabelExceedTextFieldLimit() {
        exceedLabel.isHidden = false
    }

    func hideLabelExceedTextFieldLimit() {
        exceedLabel.isHidden = true
    }
}
