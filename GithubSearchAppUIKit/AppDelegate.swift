//
//  AppDelegate.swift
//  GithubSearchAppUIKit
//
//  Created by Reinaldo Camargo on 25/04/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = GFTabBarController()
        window?.makeKeyAndVisible()
        configureNavigationBar()
        
        return true
    }
    
    func configureNavigationBar() {
        UINavigationBar.appearance().tintColor = .systemGreen
    }
    
}

