//
//  AppDelegate.swift
//  demo
//
//  Created by shayanbo on 2023/3/30.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let navigator = UINavigationController(rootViewController: ViewController())
        Router.shared.registerRootNavigator(navigator)
        self.window?.rootViewController = navigator
        self.window?.makeKeyAndVisible()
        
        return true
    }

}

