//
//  Extansion + String.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/24/24.
//

import Foundation

extension String {

    func localized() -> String {
        return NSLocalizedString(self, comment: self)
    }
}
