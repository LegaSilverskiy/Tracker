//
//  ChooseTypeTrackerViewController.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 4/10/24.
//

import UIKit

final class ChooseTypeTrackerViewController: UIViewController {
    
    //MARK: Private UI properties
    private lazy var createHabitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(createHabitButtonTappet), for: .touchUpInside)
        return button
    }()
    private lazy var createEventButton: UIButton = {
        let button = UIButton()
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(createEventButtonTappet), for: .touchUpInside)
        return button
    }()
    
    //MARK: Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: Private methods
    private func setupUI () {
        
        self.title = "Создание Трекера"
        
        view.backgroundColor = .systemBackground
        view.addSubview(createEventButton)
        view.addSubview(createHabitButton)
        
        createEventButton.translatesAutoresizingMaskIntoConstraints = false
        createHabitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            createHabitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 281),
            createHabitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createHabitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createHabitButton.heightAnchor.constraint(equalToConstant: 60),
            
            createEventButton.topAnchor.constraint(equalTo: createHabitButton.bottomAnchor, constant: 16),
            createEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    //MARK: Actions
    @objc private func createHabitButtonTappet(_ sender: UIButton) {
        let createNewHabbit = CreateHabitViewController()
        let navigation = UINavigationController(rootViewController: createNewHabbit)
        present(navigation, animated: true)
    }
    
    @objc private func createEventButtonTappet(_ sender: UIButton){
        let createUnregularEvent = UnregularEventViewController()
        let navigation = UINavigationController(rootViewController: createUnregularEvent)
        present(navigation, animated: true)
    }
}
