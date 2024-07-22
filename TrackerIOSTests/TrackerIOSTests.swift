//
//  TrackerIOSTests.swift
//  TrackerIOSTests
//
//  Created by Олег Серебрянский on 7/20/24.
//

import XCTest
import SnapshotTesting
@testable import TrackerIOS

final class TrackerIOSTests: XCTestCase {
    func testTrackerViewController() {
        let vc = TrackerViewController()

        assertSnapshots(matching: vc, as: [.image])
    }

}
