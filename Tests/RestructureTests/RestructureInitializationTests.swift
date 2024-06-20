//
//  RestructureInitializationTests.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/4/18.
//  SPDX-License-Identifier: MIT
//

import XCTest
@testable import Restructure

class RestructureInitializationTests: XCTestCase {

    var restructure: Restructure? = nil
    var tempPath: String = ""
    
    override func setUpWithError() throws {
        tempPath = testPath(description: "Initialization Tests")
    }
    
    override func tearDownWithError() throws {
        if let restructure = restructure {
            restructure.close()
            self.restructure = nil
        }
        
        let manager = FileManager.default
        
        if manager.fileExists(atPath: tempPath) {
            try manager.removeItem(atPath: tempPath)
        }
    }
    
    func testCreateInMemoryWorks() throws {
        XCTAssertNoThrow(restructure = try Restructure())
        XCTAssertNotNil(restructure)
    }
    
    func testCreateFileWorks() throws {
        XCTAssertNoThrow(restructure = try Restructure(path: tempPath))
        XCTAssertNotNil(restructure)
    }
    
    func testCreateExistingFileWorks() throws {
        // Build the first time
        restructure = try Restructure(path: tempPath)
        restructure!.close()
        restructure = nil
        
        // Attempt to run again
        XCTAssertNoThrow(restructure = try Restructure(path: tempPath))
        XCTAssertNotNil(restructure)
        
        XCTAssertNotNil(restructure)
    }
    
    func testJournalModeDefault() throws {
        restructure = try Restructure(path: tempPath)
        XCTAssertEqual(restructure!.journalMode, .wal)
        restructure!.close()
        
        restructure = try Restructure()
        XCTAssertEqual(restructure!.journalMode, .memory)
        restructure!.close()
    }
    
    func testJournalModeSettable() throws {
        for mode in JournalMode.allCases {
            restructure = try Restructure(path: tempPath, journalMode: mode)
            XCTAssertEqual(restructure!.journalMode, mode)
            restructure!.close()
        }
    }
    
    func testSecureDeleteSettable() throws {
        for mode in SecureDelete.allCases {
            restructure = try Restructure(path: tempPath)
            restructure!.secureDelete = mode
            
            let newMode = restructure!.secureDelete
            XCTAssertEqual(newMode, mode)
            
            restructure!.close()
        }
    }
    
    func testAutoVacuumSettable() throws {
        for mode in AutoVacuum.allCases {
            restructure = try Restructure(path: tempPath)
            restructure!.autoVacuum = mode
            restructure!.vacuum()
            
            let newMode = restructure!.autoVacuum
            XCTAssertEqual(newMode, mode)
            
            restructure!.close()
        }
    }
    
    func testIncrementalAutoVacuum() throws {
        restructure = try Restructure(path: tempPath)
        restructure!.autoVacuum = .incremental
        restructure!.vacuum()
        
        restructure!.incrementalVacuum()
        restructure!.incrementalVacuum(pages: 2)
        
        XCTSuccess()
        
        restructure!.close()
    }
}
