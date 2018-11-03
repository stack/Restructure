//
//  RestructureTests.swift
//  Restructure macOS Tests
//
//  Created by Stephen H. Gerstacker on 11/3/18.
//  Copyright © 2018 Stephen H. Gerstacker. All rights reserved.
//

import XCTest
@testable import Restructure

class RestructureTests: XCTestCase {
    
    var restructure: Restructure? = nil

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        if let restructure = restructure {
            restructure.close()
            self.restructure = nil
        }
    }
    
    func testCreateInMemoryWorks() {
        do {
            restructure = try Restructure()
        } catch {
            XCTFail("Building in memory restructure failed: \(error)")
        }
    }
}
