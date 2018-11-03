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
        do {
            restructure = try Restructure()
        } catch {
            XCTFail("Building in memory restructure failed: \(error)")
        }
        
        XCTAssertNotNil(restructure)
    }
    
    func testCreateFileWorks() {
        do {
            restructure = try Restructure(path: tempPath)
        } catch {
            XCTFail("Build file-backed restructure failed: \(error)")
        }
        
        XCTAssertNotNil(restructure)
    }
    
    func testCreateExistingFileWorks() {
        // Build the first time
        restructure = try! Restructure(path: tempPath)
        restructure!.close()
        restructure = nil
        
        // Attempt to run again
        do {
            restructure = try Restructure(path: tempPath)
        } catch {
            XCTFail("Build file-backed restructure again failed: \(error)")
        }
        
        XCTAssertNotNil(restructure)
    }
    
    func testUserVersionStartsAtZero() {
        restructure = try! Restructure()
        XCTAssertEqual(restructure!.userVersion, 0)
    }
    
    func testUserVersionIsUpdatable() {
        restructure = try! Restructure()
        restructure!.userVersion = 42
        
        XCTAssertEqual(restructure!.userVersion, 42)
    }
}
