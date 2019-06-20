//
//  RestructureInitializationTests.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/4/18.
//  Copyright @ 2019 Stephen H. Gerstacker. All rights reserved.
//

import XCTest
@testable import Restructure

class RestructureInitializationTests: XCTestCase {

    var restructure: Restructure? = nil
    var tempPath: String = ""
    
    override func setUp() {
        tempPath = testPath(description: "Initialization Tests")
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
    
    func testClosingTemporaryDeletedFile() {
        // Ensure the file doesn't exist
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempPath))
        
        // Build the structure
        restructure = try! Restructure(path: tempPath)
        restructure!.isTemporary = true
        
        // Ensure the file does exist
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempPath))
        
        // Close and clean up
        restructure!.close()
        
        // Ensure the file doesn't exist
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempPath))
    }

}
