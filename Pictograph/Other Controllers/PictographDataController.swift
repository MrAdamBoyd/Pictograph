//
//  PictographDataController.swift
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-25.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation
import Crashlytics
import Fabric

private let currentUserKey = "kCurrentUserKey"

class PictographDataController: NSObject {
    
    static let sharedController = PictographDataController()
    private var user = CurrentUser()
    
    //When the singleton is first initialized
    private override init() {
        super.init()

        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData {
            //If the saved object exists
            
            if let savedUser = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? CurrentUser {
                //If the app could successfully unarchive it
                user = savedUser
            }
        }
        
        //Save the user
        saveCurrentUser()
    }
    
    
    //MARK: - CurrentUser methods
    
    //Saving the user and settings to disk
    func saveCurrentUser() {
        let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(user)
        NSUserDefaults.standardUserDefaults().setObject(archivedObject, forKey: currentUserKey)
    }
    
    func getUserFirstTimeOpeningApp() -> Bool {
        return user.firstTimeOpeningApp
    }
    
    func setUserFirstTimeOpeningApp(firstTime: Bool) {
        user.firstTimeOpeningApp = firstTime
        saveCurrentUser()
    }
    
    func getUserEncryptionEnabled() -> Bool {
        return user.encryptionEnabled;
    }
    
    func setUserEncryptionEnabled(enabledOrNot: Bool) {
        user.encryptionEnabled = enabledOrNot
        saveCurrentUser()
    }
    
    func getUserEncryptionKey() -> String? {
        let password = user.encryptionPassword as String
        if password == "" {
            return nil
        }
        
        return password
    }
    
    func getUserEncryptionKeyString() -> String {
        if let password = user.encryptionPassword as? String {
            return password
        }
    }
    
    func getUserEncryptionKeyIfEnabled() -> String? {
        if user.encryptionEnabled {
            return self.getUserEncryptionKey()
        }
        
        return nil
    }
    
    func setUserEncryptionKey(newKey: String) {
        user.encryptionPassword = newKey
        saveCurrentUser()
    }
    
    func getUserShowPasswordOnScreen() -> Bool {
        return user.showPasswordOnScreen
    }
    
    func setUserShowPasswordOnScreen(enabledOrNot: Bool) {
        user.showPasswordOnScreen = enabledOrNot
        saveCurrentUser()
    }
    
    func getUserNightModeEnabled() -> Bool {
        return user.nightModeEnabled
    }
    
    func setUserDarkModeEnabled(enabledOrNot: Bool) {
        user.nightModeEnabled = enabledOrNot
        saveCurrentUser()
    }
    
    
    //MARK: - analytics methods
    
    //Record a message encrypted event
    func analyticsEncodeSend(encrypted:Bool) {
        let encryptedOrNot = encrypted ? "Encrypted" : "Unencrypted"
    
        Answers.logCustomEventWithName("Encode Message", customAttributes: ["Encryption" : encryptedOrNot])
    }
    
    //Record a message decrypted event
    func analyticsDecodeSend(encrypted: Bool) {
        let encryptedOrNot = encrypted ? "Encrypted" : "Unencrypted"
    
        Answers.logCustomEventWithName("Decode Message", customAttributes: ["Encryption" : encryptedOrNot])
    }
    
    //MARK: - Other methods
    
    //Opens the website in Safari
    func goToWebsite() {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://adamjboyd.com")!)
    }
    
}