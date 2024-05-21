//
//  TabBarController.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 3/11/24.
//

import Foundation
import UIKit


final class TabBarController: UITabBarController {
    
//MARK: override method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTabs()
    }
    //MARK: Tab setup
    
    private func setupTabs() {
        let trackers = self.createNav(with: "Трекеры", vc: TrackerViewController())
        let stats = self.createNav(with: "Статистика", vc: StatisticsViewController())
        trackers.tabBarItem = UITabBarItem(title: "Трекер", image: UIImage(systemName: "record.circle.fill"), tag: 0)
        stats.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(systemName: "hare.fill"), tag: 1)
        self.setViewControllers([trackers, stats], animated: true)
        
        self.tabBar.backgroundColor = .white
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
