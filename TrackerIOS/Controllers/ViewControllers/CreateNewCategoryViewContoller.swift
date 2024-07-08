//
//  CreateNewCategoryViewContoller.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 4/18/24.
//

import UIKit

final class CreateNewCategoryViewContoller: UIViewController {
    
    //MARK: Private properties
    
    var updateTableClosure: ( (String) -> Void )?
    
    //MARK: UI private properties
    private lazy var textFieldForCategories: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = .lightGrayIOS
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 15
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.addTarget(self, action: #selector(textFildEditing), for: .editingChanged)
        textField.delegate = self
        return textField
    }()
    
    private lazy var createCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(createCategoryButtonTappet), for: .touchUpInside)
        return button
    }()
    
    //MARK: Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    private func setupUI() {
        self.title = "Новая категория"
        view.backgroundColor = .systemBackground
        view.addSubview(textFieldForCategories)
        view.addSubview(createCategoryButton)
        
        textFieldForCategories.translatesAutoresizingMaskIntoConstraints = false
        createCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textFieldForCategories.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textFieldForCategories.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textFieldForCategories.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textFieldForCategories.heightAnchor.constraint(equalToConstant: 75),
            
            createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            createCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            createCategoryButton.heightAnchor.constraint(equalToConstant: 60)
            
        ])
    }
    
    //MARK: Actions
    @objc private func createCategoryButtonTappet() {
        guard let newCategoryName = textFieldForCategories.text else { return }
        updateTableClosure?(newCategoryName)
        dismiss(animated: true)
        
    }
    
    @objc private func textFildEditing(_ sender: UITextField) {
        if let text = sender.text,
           !text.isEmpty {
            createCategoryButton.isEnabled = true
            createCategoryButton.backgroundColor = .black
        } else {
            createCategoryButton.isEnabled = false
            createCategoryButton.backgroundColor = .systemGray
        }
    }
}

    //MARK: Extensions

extension CreateNewCategoryViewContoller: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldForCategories.resignFirstResponder()
    }
}
