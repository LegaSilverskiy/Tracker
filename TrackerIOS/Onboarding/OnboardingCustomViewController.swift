//
//  OnboardingCustomVC.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/15/24.
//

import UIKit

final class OnboardingPageViewController: UIViewController {
    
    private let image = UIImageView()
    private let label = UILabel()
    private let button = UIButton()
    
    let userDefaults = UserDefaults.standard
    
    init(image: String, labelText: String) {
        self.image.image = UIImage(named: image)
        self.label.text = labelText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        
        setupLabel()
        setupButton()
        
        view.addSubViews([image, label, button])
        
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: view.topAnchor),
            image.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            image.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -304),
            
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
        
    }
    
    private func setupLabel() {
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
    }
    
    private func setupButton() {
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(onboardingButtonTapped), for: .touchUpInside)
    }
    
    @objc private func onboardingButtonTapped(_ sender: UIButton) {
        userDefaults.set(true, forKey: "onboardingButtonTapped")
        let tabBar = TabBarController()
        tabBar.modalPresentationStyle = .fullScreen
        present(tabBar, animated: true)
    }
}
