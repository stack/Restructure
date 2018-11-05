//
//  RestructureInitializationTests.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/4/18.
//  Copyright © 2018 Stephen H. Gerstacker. All rights reserved.
//

import XCTest
@testable import Restructure

class RestructureInitializationTests: XCTestCase {

    var restructure: Restructure? = nil
    var tempPath: String = ""
    
    override func setUp() {
        let baseURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempURL = baseURL.appendingPathComponent("Restructure Tests.db")
        tempPath = tempURL.path
        
        let manager = FileManager.default
        
        if manager.fileExists(atPath: tempPath) {
            try! manager.removeItem(atPath: tempPath)
        }
    }
    
    override func tearDown() {
        if let restructure = restructure {
            restructure.close()
            self.restructure = nil
        }
        
        let manager = FileManager.default
        
        if manager.fileExists(atPath: tempPath) {
            try! manager.removeItem(atPath: tempPath)
        }
    }
    
    func testCreateInMemoryWorks() {
        XCTAssertNoThrow(restructure = try Restructure())
        XCTAssertNotNil(restructure)
    }
    
    func testCreateFileWorks() {
        XCTAssertNoThrow(restructure = try Restructure(path: tempPath))
        XCTAssertNotNil(restructure)
    }
    
    func testCreateExistingFileWorks() {
        // Build the first time
        restructure = try! Restructure(path: tempPath)
        restructure!.close()
        restructure = nil
        
        // Attempt to run again
        XCTAssertNoThrow(restructure = try Restructure(path: tempPath))
        XCTAssertNotNil(restructure)
        
        XCTAssertNotNil(restructure)
    }

}
