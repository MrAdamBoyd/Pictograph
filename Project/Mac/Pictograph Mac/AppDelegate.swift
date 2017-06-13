//
//  AppDelegate.swift
//  Pictograph Mac
//
//  Created by Adam Boyd on 2017-01-22.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

import Cocoa
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        //Setting up the Sparkle updater
        SUUpdater.shared().automaticallyChecksForUpdates = true
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    /**
     Checks Sparkle to see if there are any updates
     */
    @IBAction func checkForUpdates(_ sender: Any) {
        SUUpdater.shared().checkForUpdates(self)
    }


}
