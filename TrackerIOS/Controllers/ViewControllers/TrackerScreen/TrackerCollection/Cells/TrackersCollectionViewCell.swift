//
//  TrackerCollectionViewCell.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 3/21/24.
//

import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "TrackerCustomCollectionViewCell"
    
    // MARK: - PRIVATE METHODS
    private let frameView = UIView()
    private let titleLabel = UILabel()
    private let emojiLabel = UILabel()
    private let plusButton = UIButton()
    private let daysLabel = UILabel()
    private let pinImage = UIImageView()
    
    private let emojiLabelSize = CGFloat(24)
    private let plusButtonSize = CGFloat(34)
    
    private var tracker: Tracker?
    private var userSelectedDate: Date?
    
    var dataUpdateCallback: (() -> Void)?
    
    // MARK: - INIT
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - PUBLIC METHODS
    func configure(with model: Tracker, userSelectedDate: Date) {
        tracker = model
        self.userSelectedDate = userSelectedDate
        
        let trackerColor = UIColor(hex: model.color)
        let countOfDays = MainHelper.countOfDaysForTheTrackerInString(trackerId: model.id)

        setTitleLabelText(with: model.name)
        setTitleEmojiLabelText(with: model.emoji)
        setDaysLabelText(with: countOfDays)
        setFrameViewColor(with: trackerColor)
        setPlusButtonColor(with: trackerColor)
        setPlusButtonState(isEnabled: userSelectedDate > Date())
        
        showDoneOrUndoneTaskForDatePickerDate(tracker: model, userSelectedDate: userSelectedDate)
    }
    
    func addInteractionToFrameView(interaction: UIContextMenuInteraction) {
        frameView.addInteraction(interaction)
    }
    
    // MARK: - CONFIGURE UI
    private func configureUI() {
        configureView()
        addSubviews()
        setupConstraints()
        configureTitleLabel()
        configurePlusButton()
        configureFrameView()
    }
    
    private func addSubviews() {
        contentView.addSubview(frameView)
        frameView.addSubview(titleLabel)
        frameView.addSubview(emojiLabel)
        contentView.addSubview(daysLabel)
        contentView.addSubview(plusButton)
    }
    
    private func configureView() {
        backgroundColor = .clear
        layer.cornerRadius = 10
        layer.cornerCurve = .continuous
    }
    
    // MARK: - TITLE LABEL
    private func configureTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
    }
    
    private func setTitleLabelText(with text: String) {
        titleLabel.text = text
    }
    
    // MARK: - EMOJI LABEL
    private func setTitleEmojiLabelText(with text: String) {
        emojiLabel.text = text
    }
    
    // MARK: - DAYS LABEL
    private func configureDaysLabel() {
        daysLabel.font = .systemFont(ofSize: 12, weight: .medium)
    }
    
    private func setDaysLabelText(with text: String) {
        daysLabel.text = text
    }
    
    // MARK: - FRAME VIEW
    private func configureFrameView() {
        frameView.layer.masksToBounds = true
        frameView.layer.cornerRadius = 10
        frameView.layer.cornerCurve = .continuous
    }
    
    private func setFrameViewColor(with color: UIColor) {
        frameView.backgroundColor = color
    }
    
    // MARK: - PLUS BUTTON
    private func configurePlusButton() {
        plusButton.frame.size.width = plusButtonSize
        plusButton.frame.size.height = plusButtonSize
        plusButton.layer.cornerRadius = plusButton.frame.width / 2
        plusButton.layer.cornerCurve = .continuous
        plusButton.clipsToBounds = true
        
        let plusImage = UIImage(systemName: "plus")?.withTintColor(.colorForCellPlus, renderingMode: .alwaysOriginal)
        plusButton.setImage(plusImage, for: .normal)
        
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    private func setPlusButtonColor(with color: UIColor) {
        plusButton.backgroundColor = color
    }
    
    private func setPlusButtonState(isEnabled: Bool) {
        plusButton.isEnabled = !isEnabled
    }
    
    @objc private func plusButtonTapped() {
        guard let tracker = tracker, let userSelectedDate = userSelectedDate else { return }
        guard let trackerRecord = isTrackerExistInTrackerRecord(tracker: tracker, date: userSelectedDate) else { return }
        makeTrackerDoneOrUndone(trackerRecord: trackerRecord)
        AnalyticsService.trackerButtonTapped()
    }
    
    func showDoneOrUndoneTaskForDatePickerDate(tracker: Tracker, userSelectedDate: Date) {
        let trackerColor = UIColor(hex: tracker.color)
        
        guard let check = isTrackerExistInTrackerRecordForDatePickerDate(
            tracker: tracker,
            dateOnDatePicker: userSelectedDate)
        else {
            print("Hmm, problems")
            return
        }
        
        if check {
            designCompletedTracker(cellColor: trackerColor)
        } else {
            designUnCompleteTracker(cellColor: trackerColor)
        }
    }
    
      func designCompletedTracker(cellColor: UIColor) {
          guard let color = UIColor(named: "ColorForCellPlus"),
                let image = UIImage(named: "done") else { return }
          
          let doneImage = image.withTintColor(color)
          plusButton.setImage(doneImage, for: .normal)
          plusButton.backgroundColor = cellColor.withAlphaComponent(0.3)
      }
      
      func designUnCompleteTracker(cellColor: UIColor) {
          guard let color = UIColor(named: "ColorForCellPlus") else { return }
          let plusImage = UIImage(systemName: "plus")?.withTintColor(color, renderingMode: .alwaysOriginal)
          plusButton.backgroundColor = cellColor.withAlphaComponent(1)
          plusButton.setImage(plusImage, for: .normal)
          plusButton.layer.cornerRadius = plusButton.frame.width / 2
      }
    
    func isTrackerExistInTrackerRecordForDatePickerDate(tracker: Tracker, dateOnDatePicker: Date) -> Bool? {
        let dateOnDatePickerString = MainHelper.dateToString(date: dateOnDatePicker)
        let trackerToCheck = TrackerRecord(id: tracker.id, date: dateOnDatePickerString)
        let check = TrackerCoreManager.shared.isTrackerExistInTrackerRecord(trackerToCheck: trackerToCheck)
        return check
    }
    
    private func makeTaskDone(trackToAdd: TrackerRecord) {
        TrackerCoreManager.shared.addTrackerRecord(trackerToAdd: trackToAdd)
        dataUpdateCallback?()
    }
    
    private func makeTaskUndone(trackToRemove: TrackerRecord) {
        TrackerCoreManager.shared.removeTrackerRecordForThisDay(trackerToRemove: trackToRemove)
        dataUpdateCallback?()
    }
    
    private func makeTrackerDoneOrUndone(trackerRecord: (TrackerRecord: TrackerRecord, isExist: Bool)) {
        if !trackerRecord.isExist {
            makeTaskDone(trackToAdd: trackerRecord.TrackerRecord)
        } else {
            makeTaskUndone(trackToRemove: trackerRecord.TrackerRecord)
        }
    }
    
    func isTrackerExistInTrackerRecord(tracker: Tracker, date: Date) ->
    (TrackerRecord: TrackerRecord, isExist: Bool)? {
        let trackerID = tracker.id
        let currentDateString = MainHelper.dateToString(date: date)
        let trackerToCheck = TrackerRecord(id: trackerID, date: currentDateString)
        let check = TrackerCoreManager.shared.isTrackerExistInTrackerRecord(trackerToCheck: trackerToCheck)
        
        return (trackerToCheck, check)
    }
}

// MARK: - CONSTRAINTS
extension TrackerCollectionViewCell {
    
    private func setupConstraints() {
        frameView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            frameView.topAnchor.constraint(equalTo: contentView.topAnchor),
            frameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            frameView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            frameView.heightAnchor.constraint(equalToConstant: 90),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: frameView.bottomAnchor, constant: -12),
            
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: emojiLabelSize),
            emojiLabel.heightAnchor.constraint(equalToConstant: emojiLabelSize),
            
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.topAnchor.constraint(equalTo: frameView.bottomAnchor, constant: 16),
            
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.topAnchor.constraint(equalTo: frameView.bottomAnchor, constant: 8),
            plusButton.widthAnchor.constraint(equalToConstant: plusButtonSize),
            plusButton.heightAnchor.constraint(equalToConstant: plusButtonSize),
        ])
    }
}
