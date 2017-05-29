//
//  Pictograph_MacTests.swift
//  Pictograph MacTests
//
//  Created by Adam Boyd on 2017-01-22.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

import XCTest
@testable import Pictograph_Mac

class Pictograph_MacTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUnencryptedEncode() {
        let testString = "This is only a test"
        
        let imageCoder = PictographImageCoder()
        
        let imageData = try! imageCoder.encodeMessage(testString, in: #imageLiteral(resourceName: "ImageForTesting.png"), encryptedWithPassword: "")
        let stringFromImage = try! imageCoder.decodeMessage(in: NSImage(data: imageData)!, encryptedWithPassword: "")
        
        assert(stringFromImage == testString)
    }
    
    func testMeasureUnencryptedEncode() {
        let testString = "This is only a test"
        let imageCoder = PictographImageCoder()
        let imageToEncode = #imageLiteral(resourceName: "ImageForTesting.png")
        
        self.measure {
            let imageData = try! imageCoder.encodeMessage(testString, in: imageToEncode, encryptedWithPassword: "")
            _ = try! imageCoder.decodeMessage(in: NSImage(data: imageData)!, encryptedWithPassword: "")
        }
    }
    
}
