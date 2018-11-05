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
    
    var restructure: Restructure!

    override func setUp() {
        restructure = try! Restructure()
    }

    override func tearDown() {
        restructure.close()
        restructure = nil
    }
    
    // MARK: - User Version Tests
    
    func testUserVersionStartsAtZero() {
        restructure = try! Restructure()
        XCTAssertEqual(restructure!.userVersion, 0)
    }
    
    func testUserVersionIsUpdatable() {
        restructure = try! Restructure()
        restructure!.userVersion = 42
        
        XCTAssertEqual(restructure!.userVersion, 42)
    }
    
    
    // MARK: - Execution Tests
    
    func testExecutingInvalidQuery() {
        XCTAssertThrowsError(try restructure.execute(query: "FOO BAR BAZ"))
    }
    
    func testExecutingValidQuery() {
        XCTAssertNoThrow(try restructure.execute(query: "CREATE TABLE foo (a INT)"))
    }
    
    func testExecutingMultipleValidQueries() {
        XCTAssertNoThrow(try restructure.execute(query: "CREATE TABLE foo (a INT); INSERT INTO foo (a) VALUES(42);"))
        
        let statement = try! restructure.prepare(query: "SELECT a FROM foo LIMIT 1")
        let result = statement.step()
        
        switch result {
        case let .row(row):
            XCTAssertEqual(row["a"], 42)
        default:
            XCTFail("Failed to get a row")
        }
    }
    
    
    // MARK: - Last Inserted ID Tests
    
    func testLastInsertedIdReturnsZeroWithNoInserts() {
        XCTAssertEqual(0, restructure.lastInsertedId)
    }
    
    func testLastInsertedIdReturnsNonZeroWithInserts() {
        XCTAssertNoThrow(try restructure.execute(query: "CREATE TABLE foo (a INTEGER PRIMARY KEY AUTOINCREMENT, b INT); INSERT INTO foo (b) VALUES(42);"))
        XCTAssertGreaterThan(restructure.lastInsertedId, 0)
    }
}
