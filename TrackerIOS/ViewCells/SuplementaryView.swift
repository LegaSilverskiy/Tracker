//
//  SuplementaryView.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 4/15/24.
//

import Foundation
import UIKit

final class SuplementaryView: UICollectionReusableView {
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
