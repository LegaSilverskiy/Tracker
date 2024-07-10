//
//  extensions + UIView.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/1/24.
//

import Foundation
import UIKit

extension UIView {
    func addSubViews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false }
    }
}
