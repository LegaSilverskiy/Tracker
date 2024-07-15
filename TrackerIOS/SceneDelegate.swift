//
//  SceneDelegate.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 3/11/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: scene)
        isNeedToShowOnboarding()
        window?.makeKeyAndVisible()
    }
    
    func isNeedToShowOnboarding() {
        if UserDefaults.standard.object(forKey: "onboardingButtonTapped") == nil {
            window?.rootViewController = OnboardingVC()
        } else {
            window?.rootViewController = TabBarController()
        }
    }
}
