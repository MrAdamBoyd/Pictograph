//
//  AppDelegate.swift
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-25.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics
import Fabric

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        application.statusBarStyle = UIStatusBarStyle.lightContent
        
        let navigationController = UINavigationController(rootViewController: PictographMainViewController())
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = mainAppColor
        UINavigationBar.appearance().tintColor = UIColor.white
        
        //This sets the font attributes of the titles and back button text
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white
        ]
        
        //Sets the font attributes of the bar button items
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white
            ], for: UIControlState())
        
        //Setting up Fabric
        Fabric.with([Crashlytics()])
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        //Blurring view for app switcher
        self.blurPresentedView()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //Unbluring view for app switcher
        self.unblurPresentedView()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        PictographDataController.shared.saveCurrentUser()
    }
}
