//
//  AudioBarTests.swift
//  AudioBarTests
//
//  Created by Rudolf Adamkovic on 1.11.2016.
//  Copyright © 2016 TBD. All rights reserved.
//

import XCTest
@testable import AudioBar

class AudioBarTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testAudioBarType() {
        let audioBar = AudioBar()
        XCTAssert(audioBar as Any is UIView)
    }
    
}
