//
//  EditingTrackerViewController+ScrollView.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/24/24.
//

import UIKit

// MARK: - setupScrollView
extension EditingTrackerViewController {

    func setupScrollView() {

        let screenScrollView = UIScrollView()

        view.addSubViews([screenScrollView])

        NSLayoutConstraint.activate([
            screenScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            screenScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            screenScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            screenScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        let contentView = UIView()

        screenScrollView.addSubViews([contentView])
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: screenScrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: screenScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: screenScrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: screenScrollView.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: screenScrollView.widthAnchor)
        ])

        contentView.addSubViews([contentStackView])

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ])
    }

    func setupContentStack() {

        let textFieldViewStack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 10
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(trackerNameTextField)
            stack.addArrangedSubview(exceedLabel)
            return stack
        }()

        cancelButton.backgroundColor = .clear
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor(named: "IosRed")?.cgColor
        cancelButton.setTitleColor(UIColor(named: "IosRed"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)

        saveButton.setTitleColor(UIColor(named: "ColorForCellPlus"), for: .normal)
        saveButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)

        let buttonsStack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.spacing = 8
            stack.addArrangedSubview(cancelButton)
            stack.addArrangedSubview(saveButton)
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.heightAnchor.constraint(equalToConstant: 60).isActive = true
            return stack
        }()

        [contentStackView, counterLabel, tableViewForEditing,
         emojiCollection, colorsCollection, buttonsStack].forEach { $0.translatesAutoresizingMaskIntoConstraints = false
        }

        [counterLabel, textFieldViewStack, tableViewForEditing,
         emojiCollection, colorsCollection, buttonsStack].forEach {
            contentStackView.addArrangedSubview($0)
        }

        NSLayoutConstraint.activate([
            counterLabel.topAnchor.constraint(equalTo: contentStackView.topAnchor),
            counterLabel.heightAnchor.constraint(equalToConstant: 75),

            textFieldViewStack.topAnchor.constraint(equalTo: counterLabel.bottomAnchor, constant: 40),
            textFieldViewStack.heightAnchor.constraint(equalToConstant: 75),

            tableViewForEditing.topAnchor.constraint(equalTo: textFieldViewStack.bottomAnchor, constant: 24),
            tableViewForEditing.heightAnchor.constraint(equalToConstant: 150),

            emojiCollection.topAnchor.constraint(equalTo: tableViewForEditing.bottomAnchor),
            emojiCollection.heightAnchor.constraint(equalToConstant: 222),

            colorsCollection.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor),
            colorsCollection.heightAnchor.constraint(equalToConstant: 222),

            buttonsStack.topAnchor.constraint(equalTo: colorsCollection.bottomAnchor, constant: 16),
            buttonsStack.bottomAnchor.constraint(equalTo: contentStackView.bottomAnchor)
        ])
    }
}
