//
//  TrackerViewController + CollectionView.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/24/24.
//

import UIKit

extension TrackerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getTrackerCategoriesItems(in: section)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getCategoriesSectionCount()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.identifier,
            for: indexPath) as? TrackerCollectionViewCell else {
            print("We have some problems with CustomCell")
            return UICollectionViewCell()
        }
        
        let trackerCategories = getTrackerCategories()
        let tracker = trackerCategories[indexPath.section].trackers[indexPath.item]
        let userSelectedDate = getUserSelectedDate()
        
        cell.dataUpdateCallback = { [weak self] in
            switch self?.filterStr {
            case "Completed":
                self?.showCompletedTrackers()
            case "Today trackers":
                print("DODELAT")
            case "Not completed":
                print("Dodelat unpin")
                self?.showUncompletedTrackers()
            default:
                self?.dataUpd()
            }
        }
        
        cell.configure(with: tracker, userSelectedDate: userSelectedDate)
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
        let categories = getTrackerCategories()
        view.label.text = categories[indexPath.section].header
    }
    
}

extension TrackerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell
        let interaction = UIContextMenuInteraction(delegate: self)
        cell?.addInteractionToFrameView(interaction: interaction)
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

