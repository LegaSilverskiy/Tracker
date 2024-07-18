//
//  OnboardingVC.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/15/24.
//

import UIKit

final class OnboardingVC: UIPageViewController {
    
    var pages = [UIViewController]()
    let pageController = UIPageControl()
    let initialPage = 0
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPageVC()
        
    }
    
    private func setupPageVC() {
        dataSource = self
        delegate = self
                
        pageController.addTarget(self, action: #selector(pageControllerTapped), for: .valueChanged)
        
        let firstScreen = OnboardingPageViewController(image: "blueScreen", labelText: "Отслеживайте только то, что хотите")
        let secondScreen = OnboardingPageViewController(image: "orangeScreen", labelText: "Даже если это не литры воды и йога")

        pages.append(firstScreen)
        pages.append(secondScreen)
        
        setViewControllers([pages[initialPage]], direction: .forward, animated: true)
        
        pageController.translatesAutoresizingMaskIntoConstraints = false
        pageController.currentPageIndicatorTintColor = .black
        pageController.pageIndicatorTintColor = .gray
        pageController.numberOfPages = pages.count
        pageController.currentPage = initialPage
        
        view.addSubview(pageController)
        NSLayoutConstraint.activate([
            pageController.widthAnchor.constraint(equalTo: view.widthAnchor),
            pageController.heightAnchor.constraint(equalToConstant: 18),
            pageController.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -168)
        ])
        
    }
    
    @objc private func pageControllerTapped(_ sender: UIPageControl) {
        setViewControllers([pages[sender.currentPage]], direction: .forward, animated: true)
    }
}

extension OnboardingVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        
        if currentIndex == 0 {
            return pages.last
        } else {
            return pages[currentIndex - 1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        
        if currentIndex == pages.count - 1 {
            return pages.first
        } else {
            return pages[currentIndex + 1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let visibleViewController = pageViewController.viewControllers?.first,
           let index = pages.firstIndex(of: visibleViewController) {
            pageController.currentPage = index
        }
    }
}
