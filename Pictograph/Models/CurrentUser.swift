//
//  CurrentUser.swift
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-25.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation

//Need to use hungarian notation with the keys because that is how it was originally, it would be possible to change it later
private let firstTimeOpeningAppKey = "kFirstTimeOpeningAppKey"
private let encryptionEnabledKey = "kEncryptionEnabledKey"
private let encryptionPasswordKey = "kEncryptionKey"

class CurrentUser: NSObject, NSCoding, NSSecureCoding {
    var firstTimeOpeningApp: Bool = true
    var encryptionEnabled: Bool = false
    var encryptionPassword : NSString = ""

    override init() { super.init() }
    
    //MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        //First time opening app
        if let firstTimeOpeningAppNumber = aDecoder.decodeObjectOfClass(NSNumber.self, forKey: firstTimeOpeningAppKey) {
            firstTimeOpeningApp = firstTimeOpeningAppNumber.boolValue
        }
        
        //Encryption enabled
        if let encryptionEnabledNumber = aDecoder.decodeObjectOfClass(NSNumber.self, forKey: encryptionEnabledKey) {
            encryptionEnabled = encryptionEnabledNumber.boolValue
        }
        
        //Encryption key
        if let storedEncryptionPassword = aDecoder.decodeObjectOfClass(NSString.self, forKey: encryptionPasswordKey) {
            encryptionPassword = storedEncryptionPassword
        }
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        let firstTimeOpeningAppNumber = NSNumber(bool: firstTimeOpeningApp)
        aCoder.encodeObject(firstTimeOpeningAppNumber, forKey: firstTimeOpeningAppKey)
        
        let encryptionEnabledNumber = NSNumber(bool: encryptionEnabled)
        aCoder.encodeObject(encryptionEnabledNumber, forKey: encryptionEnabledKey)
        
        aCoder.encodeObject(encryptionPassword, forKey: encryptionPasswordKey)
    }
    
    //MARK: - NSSecureCoding
    class func supportsSecureCoding() -> Bool {
        return true
    }
}