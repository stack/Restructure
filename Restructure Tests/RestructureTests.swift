//
//  RestructureTests.swift
//  Restructure macOS Tests
//
//  Created by Stephen H. Gerstacker on 11/3/18.
//  Copyright @ 2019 Stephen H. Gerstacker. All rights reserved.
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
    
    
    // MARK: - Migration Tests
    
    func testMigrationWorksInitially() {
        XCTAssertEqual(restructure.userVersion, 0)
        
        XCTAssertNoThrow(try restructure.migrate(version: 1) {
            try $0.execute(query: "CREATE TABLE foo (A INT)")
        })
        
        XCTAssertEqual(restructure.userVersion, 1)
    }
    
    func testMigrationWorksSerially() {
        XCTAssertEqual(restructure.userVersion, 0)
        
        XCTAssertNoThrow(try restructure.migrate(version: 1) {
            try $0.execute(query: "CREATE TABLE foo (A INT)")
        })
        
        XCTAssertNoThrow(try restructure.migrate(version: 2) {
            try $0.execute(query: "CREATE TABLE bar (A INT)")
        })
        
        XCTAssertEqual(restructure.userVersion, 2)
    }
    
    func testMigrationFailsOutOfSequence() {
        XCTAssertEqual(restructure.userVersion, 0)
        
        XCTAssertThrowsError(try restructure.migrate(version: 2) {
            try $0.execute(query: "CREATE TABLE foo (A INT)")
        })
        
        XCTAssertEqual(restructure.userVersion, 0)
    }
    
    func testMigrationSkipsIfDone() {
        XCTAssertEqual(restructure.userVersion, 0)
        
        XCTAssertNoThrow(try restructure.migrate(version: 1) {
            try $0.execute(query: "CREATE TABLE foo (A INT)")
        })
        
        XCTAssertEqual(fooCount, 0)
        
        XCTAssertNoThrow(try restructure.migrate(version: 1) {
            try $0.execute(query: "INSERT INTO foo (a) VALUES (1)")
        })
        
        XCTAssertEqual(fooCount, 0)
    }
    
    // MARK: - Custom Function Tests
    
    func testUpperFunctionWithStandardString() {
        // Create a table that stores strings
        try! restructure.execute(query: "CREATE TABLE foo (id INTEGER PRIMARY KEY, value TEXT)")
        
        // Insert some test data
        try! restructure.execute(query: "INSERT INTO foo (value) VALUES ('Hello')")
        let id = restructure.lastInsertedId
        
        // Fetch the data back out, with upper case values
        let fetchStatement = try! restructure.prepare(query: "SELECT UPPER(value) AS value FROM foo WHERE id = :id")
        fetchStatement.bind(value: id, for: "id")
        
        guard case .row(let row) = fetchStatement.step() else {
            XCTFail("Failed to get inserted data")
            return
        }
        
        XCTAssertEqual(row["value"], "HELLO")
    }
    
    func testUpperFunctionWithComplexString() {
        // Create a table that stores strings
        try! restructure.execute(query: "CREATE TABLE foo (id INTEGER PRIMARY KEY, value TEXT)")
        
        // Insert some test data
        try! restructure.execute(query: "INSERT INTO foo (value) VALUES ('👋🏻 Hello 👋🏼')")
        let id = restructure.lastInsertedId
        
        // Fetch the data back out, with upper case values
        let fetchStatement = try! restructure.prepare(query: "SELECT UPPER(value) AS value FROM foo WHERE id = :id")
        fetchStatement.bind(value: id, for: "id")
        
        guard case .row(let row) = fetchStatement.step() else {
            XCTFail("Failed to get inserted data")
            return
        }
        
        XCTAssertEqual(row["value"], "👋🏻 HELLO 👋🏼")
    }
    
    func testUpperFunctionWithUnicodeString() {
        // Create a table that stores strings
        try! restructure.execute(query: "CREATE TABLE foo (id INTEGER PRIMARY KEY, value TEXT)")
        
        // Insert some test data
        try! restructure.execute(query: "INSERT INTO foo (value) VALUES ('exámple óóßChloë')")
        let id = restructure.lastInsertedId
        
        // Fetch the data back out, with upper case values
        let fetchStatement = try! restructure.prepare(query: "SELECT UPPER(value) AS value FROM foo WHERE id = :id")
        fetchStatement.bind(value: id, for: "id")
        
        guard case .row(let row) = fetchStatement.step() else {
            XCTFail("Failed to get inserted data")
            return
        }
        
        XCTAssertEqual(row["value"], "EXÁMPLE ÓÓSSCHLOË")
    }
    
    // MARK: - Utilities
    
    private var fooCount: Int {
        let statement = try! restructure.prepare(query: "SELECT COUNT(a) FROM foo")
        let result = statement.step()
        
        switch result {
        case let .row(row):
            return row[0]
        default:
            return Int.min
        }
    }
}
