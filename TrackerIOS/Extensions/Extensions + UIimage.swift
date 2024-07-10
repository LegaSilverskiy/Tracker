//
//  Extensions + UIimage.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 3/29/24.
//

import Foundation
import UIKit

extension UIImage {
  static func named(_ name: String) -> UIImage {
    if let image = UIImage(named: name) {
      return image
    } else {
      fatalError("Could not initialize \(UIImage.self) named \(name).")
    }
  }
}
