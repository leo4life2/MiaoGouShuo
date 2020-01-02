//
//  AppDelegate.swift
//  Tolocam
//
//  Created by Leo on 2018/9/5.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import AVOSCloud
import AVOSCloudIM

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    public var client:AVIMClient?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UITabBar.appearance().isTranslucent = false
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 0.9),
            NSAttributedString.Key.font : UIFont(name: "PingFangSC-Medium", size: 20)!
        ]        
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        AVOSCloud.setApplicationId("TCldgsnzV2zm3EjofgYn20U3-gzGzoHsz", clientKey: "NOTBs0QwYRx242mzzzV7eEv6")
        AVOSCloud.setAllLogsEnabled(true)
        UINavigationBar.appearance().tintColor = UIColor.lightGray
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if AVUser.current() != nil {
            self.window?.rootViewController = Tolo.getTabBarController()
        } else {
            self.window?.rootViewController = Tolo.getLoginViewController()
        }
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

