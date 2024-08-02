//
//  TabBarController.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 3/11/24.
//

import Foundation
import UIKit


final class TabBarController: UITabBarController {
    
    private var titleLocalize = NSLocalizedString("Trackers", comment: "Title for main screen")
    
//MARK: override method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTabs()
    }
    //MARK: Tab setup
    
    private func setupTabs() {
        let localizedTextForStatistic = NSLocalizedString("Statistics", comment: "Text for Statistic in right tab")
        let localizedTextForTracker = NSLocalizedString("Tracker", comment: "Text for Tracker in left tab")
        let viewModel = StatisticViewModel()
        let trackers = self.createNav(with: titleLocalize, vc: TrackerViewController())
        let stats = self.createNav(with: "Статистика", vc: StatisticViewController(viewModel: viewModel))
        trackers.tabBarItem = UITabBarItem(title: localizedTextForTracker, image: UIImage(systemName: "record.circle.fill"), tag: 0)
        stats.tabBarItem = UITabBarItem(title: localizedTextForStatistic, image: UIImage(systemName: "hare.fill"), tag: 1)
        self.setViewControllers([trackers, stats], animated: true)
        
        self.tabBar.backgroundColor = .systemBackground
        self.tabBar.layer.borderWidth = 0.5
        self.tabBar.layer.borderColor = UIColor(named: "tabBarBorderColor")?.cgColor
    }
    
    private func createNav(with title: String, vc: UIViewController) -> UINavigationController {
     
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.topItem?.title = title
        nav.navigationBar.barStyle = .default
        nav.navigationBar.isTranslucent = true
        nav.navigationBar.backgroundColor = .systemBackground
        nav.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        nav.navigationBar.prefersLargeTitles = true
        nav.navigationItem.hidesSearchBarWhenScrolling = false
        return nav
    }
}

extension TabBarController: UITabBarControllerDelegate {
   func tabBarController(_ tabBarController: UITabBarController, didSelect vc: UIViewController) {
        
    }
}
