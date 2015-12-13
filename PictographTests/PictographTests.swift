//
//  PictographTests.swift
//  Pictograph
//
//  Created by Adam on 2015-12-12.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation
import XCTest

class PictographTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testUnencryptedEncode() {
        let testString = "This is only a test"
        
        let imageCoder = UIImageCoder()
        
        let imageData = try! imageCoder.encodeMessage(testString, inImage: UIImage(named: "AppIcon.png")!, encryptedWithPassword: nil)
        let stringFromImage = try! imageCoder.decodeMessageInImage(UIImage(data: imageData)!, encryptedWithPassword: nil)
        
        assert(stringFromImage == testString)
    }
    
    func testEncryptedEncode() {
        let testString = "This is only a test"
        let password = "Password"
        
        let imageCoder = UIImageCoder()
        
        let imageData = try! imageCoder.encodeMessage(testString, inImage: UIImage(named: "AppIcon.png")!, encryptedWithPassword: password)
        let stringFromImage = try! imageCoder.decodeMessageInImage(UIImage(data: imageData)!, encryptedWithPassword: password)
        
        assert(stringFromImage == testString)
    }
}