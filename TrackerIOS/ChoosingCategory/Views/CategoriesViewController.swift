//
//  CategoriesViewController.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 4/17/24.
//

import UIKit

final class CategoriesViewController: UIViewController {
    
    //MARK: Public properties
    var viewModel: ViewModelProtocol
    
    init(viewModel: ViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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
    //MARK: Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataFromViewModel()
        
        setupBinding()
        setupUI()
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
    
    private func setupBinding() {
        viewModel.dataUpdated = { [weak self] in
            guard let self else { return }
            self.tableForCategories.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    private func getDataFromViewModel() {
        viewModel.getDataFromCoreData()
    }
    
    private func showPlaceholderForEmptyScreen() {
        
        let emptyScreenStack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 8
            stack.alignment = .center
            
            stack.addArrangedSubview(emptyImage)
            stack.addArrangedSubview(helpLabelInfo)
            return stack
        } ()
        
        emptyImage.isHidden = !viewModel.categories.isEmpty
        helpLabelInfo.isHidden = !viewModel.categories.isEmpty
        
        view.addSubViews([emptyScreenStack])
        
        NSLayoutConstraint.activate([
            emptyScreenStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            helpLabelInfo.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            helpLabelInfo.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    
    //MARK: Actions
    @objc private func createCategoryButtonTappet() {
        let viewModel = CategoriesViewModel()
        let creatingNewCategoryVC = CreateNewCategoryViewContoller(viewModel: viewModel)
        let creatingCategoryNavVC = UINavigationController(rootViewController: creatingNewCategoryVC)
        
        creatingNewCategoryVC.viewModel.updateCategory = { [weak self] newCategory in
            guard let self = self else { return }
            viewModel.coreDataManager.createNewCategory(newCategoryName: newCategory)

            
            if viewModel.categories.isEmpty {
                showPlaceholderForEmptyScreen()
            } else {
                emptyImage.isHidden = true
                helpLabelInfo.isHidden = true
            }
        }
        present(creatingCategoryNavVC, animated: true)
    }
}
