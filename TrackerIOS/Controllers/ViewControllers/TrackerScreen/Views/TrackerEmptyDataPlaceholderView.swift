//
//  TrackerEmptyDataPlaceholderView.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/30/24.
//

import UIKit

final class TrackerEmptyDataPlaceholderView: UIView {
    
    // MARK: - PROPERTY LIST
    private var emptyDataPlaceholderImage = UIImageView()
    private var emptyDataPlaceholderDescriptionLabel = UILabel()
        
    // MARK: - INIT
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - PUBLICK METHODS
    func configure(isSearchMode: Bool) {
        setEmptyDataDescriptionLabelText(isSearchMode: isSearchMode)
        setEmptyDataPlaceholderImage(isSearchMode: isSearchMode)
    }
    
    // MARK: - CONFIGURE UI
    private func configureUI() {
        configureView()
        addSubviews()
        setupConstraints()
        configureEmptyDataDescriptionLabel()
        configureEmptyDataPlaceholderImage()
    }
    
    private func configureView() {
        backgroundColor = .systemBackground
    }
    
    private func addSubviews() {
        addSubview(emptyDataPlaceholderImage)
        addSubview(emptyDataPlaceholderDescriptionLabel)
    }
    
    // MARK: - EMPTY DATA PLACEHOLDER IMAGE
    private func configureEmptyDataPlaceholderImage() {
        emptyDataPlaceholderImage.image = UIImage(named: "FallingStar")
    }
    
    private func setEmptyDataPlaceholderImage(isSearchMode: Bool) {
        var image: UIImage?
        isSearchMode ? (image = UIImage(named: "searchPlaceholder")) : (image = UIImage(named: "FallingStar"))
        emptyDataPlaceholderImage.image = image
    }
    
    // MARK: - EMPTY DATA PLACEHOLDER DESCRIPTION LABEL
    private func configureEmptyDataDescriptionLabel() {
        let localizedTextForEmptyScreen = NSLocalizedString("What are we going to track?", comment: "Text for empty screen")
        emptyDataPlaceholderDescriptionLabel.text = localizedTextForEmptyScreen
        emptyDataPlaceholderDescriptionLabel.textColor = .blackDayIOS
        emptyDataPlaceholderDescriptionLabel.textAlignment = .center
        emptyDataPlaceholderDescriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    }
    
    private func setEmptyDataDescriptionLabelText(isSearchMode: Bool) {
        let localizedTextForEmptyScreen = NSLocalizedString("What are we going to track?", comment: "Text for empty screen")
        let localizedTextForEmptyScreenIftrackersNotFound = NSLocalizedString("Nothing found", comment: "Text for empty screen")
        
        var finalText: String
        isSearchMode ? (finalText = localizedTextForEmptyScreenIftrackersNotFound) : (finalText = localizedTextForEmptyScreen)
        emptyDataPlaceholderDescriptionLabel.text = finalText
    }
}

// MARK: - CONSTRAINTS
extension TrackerEmptyDataPlaceholderView {
    
    private func setupConstraints() {
        emptyDataPlaceholderDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyDataPlaceholderImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyDataPlaceholderImage.topAnchor.constraint(equalTo: topAnchor),
            emptyDataPlaceholderImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyDataPlaceholderImage.widthAnchor.constraint(equalToConstant: 80),
            emptyDataPlaceholderImage.heightAnchor.constraint(equalToConstant: 80),
            emptyDataPlaceholderImage.bottomAnchor.constraint(equalTo: emptyDataPlaceholderDescriptionLabel.topAnchor, constant: -8),
            
            emptyDataPlaceholderDescriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            emptyDataPlaceholderDescriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            emptyDataPlaceholderDescriptionLabel.heightAnchor.constraint(equalToConstant: 18),
            emptyDataPlaceholderDescriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
