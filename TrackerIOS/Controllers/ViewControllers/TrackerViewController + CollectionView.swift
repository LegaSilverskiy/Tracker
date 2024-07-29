//
//  TrackerViewController + CollectionView.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/24/24.
//

import UIKit

extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == stickyCollectionView {
            return coreDataManager.numberOfPinnedTrackers(section)
        } else {
            return coreDataManager.numberOfRowsInSection(section)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == stickyCollectionView {
            return coreDataManager.pinnedSection
        } else {
            return coreDataManager.numberOfSections
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.identifier,
            for: indexPath) as? TrackerCollectionViewCell else {
            print("We have some problems with CustomCell")
            return UICollectionViewCell()
        }

        if collectionView == stickyCollectionView {
            configureStickyCollection(cell: cell, indexPath: indexPath)
        } else {
            configureTrackerCollection(cell: cell, indexPath: indexPath)
        }
        return cell
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

        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SuplementaryView else {
            print("We have some problems with header"); return UICollectionReusableView()
        }
        if kind == UICollectionView.elementKindSectionHeader {
            collectionsHeaders(collection: collectionView, view: view, indexPath: indexPath)
        }
        return view
    }
    
    func collectionsHeaders(collection: UICollectionView, view: SuplementaryView, indexPath: IndexPath) {
        if collection == stickyCollectionView {
            let header = NSLocalizedString("Pinned", comment: "")
            view.label.text = header
        } else {
            if let headers = coreDataManager.trackersFetchedResultsController?.sections {
                view.label.text = headers[indexPath.section].name
            }
        }
    }
    
}

extension TrackerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell
        cell?.titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        let interaction = UIContextMenuInteraction(delegate: self)
        cell?.frameView.addInteraction(interaction)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell
        cell?.titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2 - 9, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {

            if collectionView == trackersCollectionView {
                if section == collectionView.numberOfSections - 1 {
                    return CGSize(width: collectionView.bounds.width, height: 60)
                }
            }
            return CGSize(width: 0, height: 0)
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
    }
    
}

extension TrackerViewController {
    
    
    func setupCollectionView() {
        
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self
        trackersCollectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        
        trackersCollectionView.register(SuplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        trackersCollectionView.register(SuplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        
        trackersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        setupContraints()
        
    }

    
    func calculationOfStickyCollectionHeight() -> CGFloat {

        guard let collectionElements = coreDataManager.pinnedTrackersFetchedResultsController?.fetchedObjects?.count else {
            print("Nil"); return 0}
        let numberOfRows = ceil(Double(collectionElements) / 2.0)
        let cellHeight = numberOfRows > 1 ? 180 : 200
        let collectionHeight = numberOfRows * Double(cellHeight)

        return collectionHeight
    }
    
    func setStickyCollectionHeight() {

        let height = calculationOfStickyCollectionHeight()
        stickyCollectionHeightConstraint?.constant = height
    }
    
    func setupContraints() {

        view.addSubViews([stickyCollectionView, trackersCollectionView])

        NSLayoutConstraint.activate([
            stickyCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stickyCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stickyCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            trackersCollectionView.topAnchor.constraint(equalTo: stickyCollectionView.bottomAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        setStickyCollectionHeight()

    }

}
