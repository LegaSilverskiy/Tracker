//
//  CategoriesViewController.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 4/17/24.
//

import UIKit

final class CategoriesViewController: UIViewController {
    
    
    //MARK: Private properties
    
    var updateCategory: ( (String) -> Void)?
    
    var categories: [String] = []
    
    //MARK: Private UI properties
    
    private lazy var tableForCategories: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellCategories")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableHeaderView = UIView()
        tableView.layer.cornerRadius = 16
        return tableView
    }()
    
    private lazy var emptyImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "FallingStar")
        return image
    }()
    private lazy var helpLabelInfo: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно объединить по смыслу"
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var createCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(createCategoryButtonTappet), for: .touchUpInside)
        return button
    }()
    
    private lazy var listOfCategories: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    //MARK: Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        recieveCategoryNamesFromSingleton()
    }
    
    //MARK: Private methods
    
    private func setupUI() {
        self.title = "Категория"
        view.backgroundColor = .systemBackground
        view.addSubview(emptyImage)
        view.addSubview(helpLabelInfo)
        view.addSubview(createCategoryButton)
        view.addSubview(tableForCategories)

        emptyImage.translatesAutoresizingMaskIntoConstraints = false
        helpLabelInfo.translatesAutoresizingMaskIntoConstraints = false
        createCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        tableForCategories.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            helpLabelInfo.centerXAnchor.constraint(equalTo: emptyImage.centerXAnchor),
            helpLabelInfo.topAnchor.constraint(equalTo: emptyImage.bottomAnchor, constant: 8),
            
            createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            createCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            createCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            
            tableForCategories.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableForCategories.bottomAnchor.constraint(equalTo: createCategoryButton.topAnchor, constant: -16),
            tableForCategories.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableForCategories.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    func recieveCategoryNamesFromSingleton() {
        self.categories = CategoryDB.shared.getCategoryNames()
    }
    
    func sendCategoryNamesToSingleton() {
        CategoryDB.shared.updateCategoryNames(categoryNames: categories)
    }
    
    //MARK: Actions
    @objc private func createCategoryButtonTappet() {
        let creatingNewCategoryVC = CreateNewCategoryViewContoller()
        let creatingCategoryNavVC = UINavigationController(rootViewController: creatingNewCategoryVC)
        creatingNewCategoryVC.updateTableClosure = { [weak self] newCategory in
            guard let self = self else { return }
            self.categories.append(newCategory)
            self.tableForCategories.reloadData()
            self.tableForCategories.layoutIfNeeded()
        }
        present(creatingCategoryNavVC, animated: true)
    }
}

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategories", for: indexPath)
        cell.backgroundColor = .backgroundDayIOS
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.text = categories[indexPath.row]
        
        if indexPath.row == categories.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
}

extension CategoriesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.selectionStyle = .none
        let selectionImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
        selectionImage.image = UIImage(systemName: "checkmark")
        cell?.accessoryView = selectionImage
        
        guard let categoryName = cell?.textLabel?.text else { return }
        updateCategory?(categoryName)
        dismiss(animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryView = UIView()
    }
}


