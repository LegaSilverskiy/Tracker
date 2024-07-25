//
//  UnregularEventViewController.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 4/10/24.
//

import UIKit

final class UnregularEventViewController: UIViewController {
    
    //MARK: Private UI properties
    private lazy var nameTracker: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .lightGrayIOS
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 15
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.rightViewMode = .whileEditing
        textField.textAlignment = .left
        textField.delegate = self
        return textField
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.frame.size = contentSize
        
        return contentView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 24
        stackView.backgroundColor = .white
        return stackView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = .white
        scroll.contentSize = contentSize
        return scroll
    }()
    
    private lazy var tableViewForChooseCategoryOrSchedule: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .lightGrayIOS
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.cornerRadius = 10
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        return tableView
    }()
    
    private lazy var emojisCollection: UICollectionView = {
        let emojis = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        emojis.dataSource = self
        emojis.delegate = self
        emojis.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "emojisCell")
        emojis.register(SuplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        emojis.isScrollEnabled = false
        emojis.backgroundColor = .white
        return emojis
    }()
    
    private lazy var colorsCollection: UICollectionView = {
        let colors = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        colors.dataSource = self
        colors.delegate = self
        colors.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "colorsCell")
        colors.register(SuplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        colors.isScrollEnabled = false
        colors.backgroundColor = .white
        return colors
    }()
    
    private lazy var stackViewForButtons: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.backgroundColor = .white
        return stackView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отмена", for: .normal)
        button.setTitleColor(.iosRed, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor(named: "IosRed")?.cgColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .grayIOS
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: Private properties
    
    private let coreDataManager = TrackerCoreManager.shared
    
    private let categories = ["Категория"]
    private var contentSize: CGSize {
        CGSize(width: view.frame.width, height: view.frame.height)
    }
    private var newTaskName: String?
    private var selectedEmoji: String?
    private var selectedColor: String?
    private var selectedCategory: String?
    private var selectedSchedule: String?
    private let emojiArr = ["🙂","😻","🌺","🐶","❤️","😱","😇","😡","🥶","🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝️","😪"]
    private let colorArr = [UIColor(named:"ColorSelection1"), UIColor(named:"ColorSelection2"), UIColor(named:"ColorSelection3"), UIColor(named:"ColorSelection4"), UIColor(named:"ColorSelection5"), UIColor(named:"ColorSelection6"), UIColor(named:"ColorSelection7"), UIColor(named:"ColorSelection8"), UIColor(named:"ColorSelection9"), UIColor(named:"ColorSelection10"), UIColor(named:"ColorSelection11"), UIColor(named:"ColorSelection12"), UIColor(named:"ColorSelection13"), UIColor(named:"ColorSelection14"), UIColor(named:"ColorSelection15"), UIColor(named:"ColorSelection16"), UIColor(named:"ColorSelection17"), UIColor(named:"ColorSelection18")]
    
    private let arrColorsForString = ["#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4", "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D", "#FF99CC", "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"]
    
    var informAnotherVCofCreatingTracker: ( () -> Void )?
    //MARK: Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        isCreateButtonEnable()
    }
    
    //MARK: Private methods
    private func setupUI() {
        self.title = "Новая привычка"
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        contentView.addSubview(stackViewForButtons)
        stackView.addArrangedSubview(nameTracker)
        stackView.addArrangedSubview(tableViewForChooseCategoryOrSchedule)
        stackView.addArrangedSubview(emojisCollection)
        stackView.addArrangedSubview(colorsCollection)
        stackViewForButtons.addArrangedSubview(cancelButton)
        stackViewForButtons.addArrangedSubview(createButton)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackViewForButtons.translatesAutoresizingMaskIntoConstraints = false
        tableViewForChooseCategoryOrSchedule.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        emojisCollection.translatesAutoresizingMaskIntoConstraints = false
        colorsCollection.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            nameTracker.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            nameTracker.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            nameTracker.heightAnchor.constraint(equalToConstant: 75),
            
            tableViewForChooseCategoryOrSchedule.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            tableViewForChooseCategoryOrSchedule.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            tableViewForChooseCategoryOrSchedule.heightAnchor.constraint(equalToConstant: 75),
            
            emojisCollection.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            emojisCollection.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            emojisCollection.heightAnchor.constraint(equalToConstant: 204),
            
            colorsCollection.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            colorsCollection.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            colorsCollection.heightAnchor.constraint(equalToConstant: 204),
            
            stackViewForButtons.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 46),
            stackViewForButtons.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackViewForButtons.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
    }
    
    private func isCreateButtonEnable() {
        if let text = nameTracker.text, !text.isEmpty,
           selectedCategory != nil,
           selectedEmoji != nil,
           selectedColor != nil {
            createButton.isEnabled = true
            createButton.backgroundColor = .black
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = UIColor(named: "GrayIOS")
        }
    }
    
//MARK: Actions
    @objc private func createButtonTapped(_ sender: UIButton) {
        guard let selectedCategory = selectedCategory,
              let name = nameTracker.text,
              let selectedColor = selectedColor,
              let selectedEmoji = selectedEmoji else { print("Что-то пошло не так"); return }
        
        let newTask = TrackerCategory(header: selectedCategory, trackers: [Tracker(id: UUID(), name: name, color: selectedColor, emoji: selectedEmoji, schedule: "Пн, Вт, Ср, Чт, Пт, Сб, Вс")])
        coreDataManager.createNewTracker(newTracker: newTask)
        informAnotherVCofCreatingTracker?()
    }
    
    @objc private func clearTextButtonTapped(_ sender: UIButton) {
        nameTracker.text = ""
        isCreateButtonEnable()
    }
}

//MARK: Extensions for TableView
extension UnregularEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = categories[indexPath.row]
        cell.backgroundColor = .backgroundDayIOS
        cell.selectionStyle = .none
        
        let chevronImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 7, height: 12))
        chevronImage.image = UIImage(named: "chevron")
        cell.accessoryView = chevronImage
        
        if indexPath.row == categories.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
}

extension UnregularEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = CategoriesViewModel()
            let navigationCategories = CategoriesViewController(viewModel: viewModel)
            let navigation = UINavigationController(rootViewController: navigationCategories)
            viewModel.updateCategory = { [weak self] categoryName in
                guard let self = self,
                      let cell = tableView.cellForRow(at: indexPath) else { return }
                cell.detailTextLabel?.text = categoryName
                self.selectedCategory = categoryName
                self.isCreateButtonEnable()
            }
            present(navigation, animated: true)
        
    }
}


//MARK: Extensions for CollectionView
extension UnregularEventViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojisCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojisCell", for: indexPath)
            let view = UILabel(frame: cell.contentView.bounds)
            view.text = emojiArr[indexPath.row]
            view.font = .systemFont(ofSize: 32)
            view.textAlignment = .center
            cell.addSubview(view)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorsCell", for: indexPath)
            let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            view.layer.cornerRadius = 8
            let colors = colorArr
            view.backgroundColor = colors[indexPath.row]
            cell.contentView.addSubview(view)
            view.center = CGPoint(x: cell.contentView.bounds.midX,
                                  y: cell.contentView.bounds.midY)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id = ""
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SuplementaryView
        if collectionView == emojisCollection {
            view.label.text = "Emoji"
        } else {
            view.label.text = "Цвет"
        }
        return view
    }
    
}

extension UnregularEventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 32)
    }
}

extension UnregularEventViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojisCollection {
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.cornerRadius = 8
            cell?.backgroundColor = .backgroundDayIOS
            selectedEmoji = emojiArr[indexPath.row]
        } else {
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 3
            let cellColor = colorArr[indexPath.row]
            cell?.layer.borderColor = cellColor?.cgColor
            cell?.layer.cornerRadius = 8
            selectedColor = arrColorsForString[indexPath.row]
        }
        isCreateButtonEnable()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojisCollection {
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.backgroundColor = .clear
        } else {
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 0
        }
    }
}

extension UnregularEventViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if currentCharacterCount <= 25 {
            isCreateButtonEnable()
            nameTracker.textColor = .black
            return true
        } else {
            textField.textColor = .red
            return true
        }
    }
}
