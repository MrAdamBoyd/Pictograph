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
        
        let imageCoder = PictographImageCoder()
        
        let imageData = try! imageCoder.encode(message: testString, in: #imageLiteral(resourceName: "IconForSettings"), encryptedWithPassword: "")
        let stringFromImage = try! imageCoder.decodeMessage(in: UIImage(data: imageData)!, encryptedWithPassword: "")
        
        assert(stringFromImage == testString)
    }
    
    func testMeasureUnencryptedEncode() {
        let testString = "This is only a test"
        let imageCoder = PictographImageCoder()
        let imageToEncode = #imageLiteral(resourceName: "IconForSettings")
        
        self.measure {
            let imageData = try! imageCoder.encode(message: testString, in: imageToEncode, encryptedWithPassword: "")
            _ = try! imageCoder.decodeMessage(in: UIImage(data: imageData)!, encryptedWithPassword: "")
        }
    }
    
    func testEncryptedEncode() {
        let testString = "This is only a test"
        let password = "password"
        
        let imageCoder = PictographImageCoder()
        
        let imageData = try! imageCoder.encode(testString, in: #imageLiteral(resourceName: "IconForSettings"), encryptedWithPassword: password)
        let stringFromImage = try! imageCoder.decodeMessage(in: UIImage(data: imageData)!, encryptedWithPassword: password)
        
        assert(stringFromImage == testString)
    }
    
    func testMeasureEncryptedEncode() {
        let testString = "This is only a test"
        let password = "password"
        let imageCoder = PictographImageCoder()
        let imageToEncode = #imageLiteral(resourceName: "IconForSettings")
        
        self.measure {
            let imageData = try! imageCoder.encodeMessage(testString, in: imageToEncode, encryptedWithPassword: password)
            _ = try! imageCoder.decodeMessage(in: UIImage(data: imageData)!, encryptedWithPassword: password)
        }
    }
    
}
