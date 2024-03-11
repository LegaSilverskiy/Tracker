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
    
    private lazy var plusButton: UIButton = {
        let buttonImage = UIImage(named: "PlusButton")
        guard let buttonImage = buttonImage else {return UIButton()}
        
        let button = UIButton.systemButton(with: buttonImage,
                                           target: self,
                                           action: #selector(PlusButtonTapped(_ :)))
        return button
    }()
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "14.12.22"
        label.backgroundColor = .lightGrayIOS
        label.textColor = .blackDayIOS
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.textColor = .blackDayIOS
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private lazy var searchField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Поиск"
        textField.backgroundColor = .backgroundDayIOS
        return textField
    }()
    
    private var imageSize = 70.0
    private lazy var emptyTrackerImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Comet")
        image.tintColor = .backgroundDayIOS
        image.layer.cornerRadius = imageSize / 2
        image.clipsToBounds = true
        return image
    }()
    
    private lazy var labelWithTextForEmpty: UILabel = {
       let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = .blackDayIOS
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    //MARK: View Life Cycles
    
    override func viewDidLoad() {
        
        displayViewElemets()
        constraintActivate()
    }
    
    //MARK: Actions
    @objc private func PlusButtonTapped(_ sender: UIButton) {
    }
    
    //MARK: Private Methods
    
    private func constraintActivate () {
        NSLayoutConstraint.activate([
            plusButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18),
            plusButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 57),
            plusButton.widthAnchor.constraint(equalToConstant: 19),
            plusButton.heightAnchor.constraint(equalToConstant: 18),
            dateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 49),
            dateLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 282),
            textLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 88),
            searchField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16),
            searchField.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 7),
            emptyTrackerImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 402),
            emptyTrackerImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 147),
            emptyTrackerImage.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -148),
            labelWithTextForEmpty.topAnchor.constraint(equalTo: emptyTrackerImage.bottomAnchor, constant: 8),
            labelWithTextForEmpty.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            labelWithTextForEmpty.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    private func displayViewElemets() {
        view.addSubview(plusButton)
        view.addSubview(dateLabel)
        view.addSubview(textLabel)
        view.addSubview(searchField)
        view.addSubview(emptyTrackerImage)
        view.addSubview(labelWithTextForEmpty)
        
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        searchField.translatesAutoresizingMaskIntoConstraints = false
        emptyTrackerImage.translatesAutoresizingMaskIntoConstraints = false
        labelWithTextForEmpty.translatesAutoresizingMaskIntoConstraints = false
    }
}
