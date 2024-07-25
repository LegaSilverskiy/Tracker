//
//  EditingTrackerVC+CollectionView.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/24/24.
//

import UIKit

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension EditingTrackerViewController: UICollectionViewDataSource,
                                        UICollectionViewDelegate,
                                        UICollectionViewDelegateFlowLayout {

    func setupEmojiCollectionView() {
        emojiCollection.dataSource = self
        emojiCollection.delegate = self
        emojiCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        emojiCollection.register(SuplementaryView.self,
                                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                 withReuseIdentifier: "header")
        emojiCollection.backgroundColor = .systemBackground
        emojiCollection.isScrollEnabled = false
    }

    func setupColorsCollectionView() {
        colorsCollection.dataSource = self
        colorsCollection.delegate = self
        colorsCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "colorsCell")
        colorsCollection.register(SuplementaryView.self,
                                  forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                  withReuseIdentifier: "header")
        colorsCollection.backgroundColor = .systemBackground
        colorsCollection.isScrollEnabled = false
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollection {
            arrayOfEmoji.count
        } else {
            arrayOfColors.count
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == emojiCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath)
            let view = UILabel(frame: cell.contentView.bounds)
            view.text = arrayOfEmoji[indexPath.row]
            view.font = .systemFont(ofSize: 32)
            view.textAlignment = .center
            cell.addSubview(view)

            if indexPath == emojiIndexPath {
                cell.isSelected = true
                cell.layer.cornerRadius = 8
                cell.backgroundColor = UIColor(named: "LightGrayIOS")
            }

            return cell

        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorsCell", for: indexPath)
            let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            view.layer.cornerRadius = 8
            let colors = colorFromHexToRGB(hexColors: arrayOfColors)
            view.backgroundColor = colors[indexPath.row]
            cell.contentView.addSubview(view)
            view.center = CGPoint(x: cell.contentView.bounds.midX,
                                  y: cell.contentView.bounds.midY)

            if indexPath == colorIndexPath {
                cell.isSelected = true
                cell.layer.borderWidth = 3
                let cellColor = colors[indexPath.row].withAlphaComponent(0.3)
                cell.layer.borderColor = cellColor.cgColor
                cell.layer.cornerRadius = 8
            }

            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let emojiIndexPath = emojiIndexPath,
              let colorIndexPath = colorIndexPath else {
            print("Smth's going wrong"); return
        }

        if collectionView == emojiCollection {
            if let originalEmojiCell = collectionView.cellForItem(at: emojiIndexPath) {
                originalEmojiCell.backgroundColor = .clear
            }

            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.layer.cornerRadius = 8
                cell.backgroundColor = UIColor(named: "LightGrayIOS")
                emoji = arrayOfEmoji[indexPath.row]
            }
        } else {
            if let originalColorCell = collectionView.cellForItem(at: colorIndexPath) {
                originalColorCell.layer.borderWidth = 0
            }

            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.layer.borderWidth = 3
                let colors = colorFromHexToRGB(hexColors: arrayOfColors)
                let cellColor = colors[indexPath.row].withAlphaComponent(0.3)
                cell.layer.borderColor = cellColor.cgColor
                cell.layer.cornerRadius = 8
                color = arrayOfColors[indexPath.row]
            }
        }
        isCreateButtonEnable()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let emojiIndexPath = emojiIndexPath else {
            print("Smth's going wrong"); return
        }

        if collectionView == emojiCollection {
            collectionView.cellForItem(at: emojiIndexPath)?.backgroundColor = .clear
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.backgroundColor = .clear
        } else {
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 0
        }
    }

    private func colorFromHexToRGB(hexColors: [String]) -> [UIColor] {
        return hexColors.map { UIColor(hex: $0) }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        5
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        1
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 32)
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
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
            ofKind: kind,
            withReuseIdentifier: id,
            for: indexPath) as? SuplementaryView else { return UICollectionReusableView() }
        if collectionView == emojiCollection {
            view.label.text = "Emoji"
        } else {
            view.label.text = "Цвет"
        }
        return view
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
    }
}
