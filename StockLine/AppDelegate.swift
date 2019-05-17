//
//  AppDelegate.swift
//  StockLine
//
//  Created by Chung Han Hsin on 2019/5/7.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        runApplication()
        return true
    }
}

extension AppDelegate{
    fileprivate func runApplication(){
        window = UIWindow()
        window?.rootViewController = ChartViewController()
        window?.makeKeyAndVisible()
    }
}
