//
//  RestructureTests.swift
//  Restructure macOS Tests
//
//  Created by Stephen H. Gerstacker on 11/3/18.
//  Copyright @ 2020 Stephen H. Gerstacker. All rights reserved.
//

import XCTest
@testable import Restructure

class RestructureTests: XCTestCase {
    
    var restructure: Restructure!

    override func setUpWithError() throws {
        restructure = try Restructure()
    }

    override func tearDown() {
        restructure.close()
        restructure = nil
    }
    
    // MARK: - User Version Tests
    
    func testUserVersionStartsAtZero() throws {
        restructure = try Restructure()
        XCTAssertEqual(restructure!.userVersion, 0)
    }
    
    func testUserVersionIsUpdatable() throws {
        restructure = try Restructure()
        restructure!.userVersion = 42
        
        XCTAssertEqual(restructure!.userVersion, 42)
    }
    
    // MARK: - Execution Tests
    
    func testExecutingInvalidQuery() throws {
        XCTAssertThrowsError(try restructure.execute(query: "FOO BAR BAZ"))
    }
    
    func testExecutingValidQuery() throws {
        XCTAssertNoThrow(try restructure.execute(query: "CREATE TABLE foo (a INT)"))
    }
    
    func testExecutingMultipleValidQueries() throws {
        XCTAssertNoThrow(try restructure.execute(query: "CREATE TABLE foo (a INT); INSERT INTO foo (a) VALUES(42);"))
        
        let statement = try restructure.prepare(query: "SELECT a FROM foo LIMIT 1")
        let result = statement.step()
        
        switch result {
        case let .row(row):
            XCTAssertEqual(row["a"], 42)
        default:
            XCTFail("Failed to get a row")
        }
    }
    
    
    // MARK: - Last Inserted ID Tests
    
    func testLastInsertedIdReturnsZeroWithNoInserts() throws {
        XCTAssertEqual(0, restructure.lastInsertedId)
    }
    
    func testLastInsertedIdReturnsNonZeroWithInserts() throws {
        XCTAssertNoThrow(try restructure.execute(query: "CREATE TABLE foo (a INTEGER PRIMARY KEY AUTOINCREMENT, b INT); INSERT INTO foo (b) VALUES(42);"))
        XCTAssertGreaterThan(restructure.lastInsertedId, 0)
    }

    // MARK: - SQLite Version Tests

    func testSQLiteVersionExists() throws {
        let version = restructure.sqliteVersion
        XCTAssertFalse(version.isEmpty)
    }
    
    
    // MARK: - Migration Tests
    
    func testMigrationNeedDetectable() throws {
        XCTAssertFalse(restructure.needsMigration(targetVersion: 0))
        XCTAssertTrue(restructure.needsMigration(targetVersion: 1))
        
        restructure.userVersion = 42
        
        XCTAssertFalse(restructure.needsMigration(targetVersion: 40))
        XCTAssertFalse(restructure.needsMigration(targetVersion: 41))
        XCTAssertFalse(restructure.needsMigration(targetVersion: 42))
        XCTAssertTrue(restructure.needsMigration(targetVersion: 43))
        XCTAssertTrue(restructure.needsMigration(targetVersion: 44))
    }
    
    func testMigrationWorksInitially() throws {
        XCTAssertEqual(restructure.userVersion, 0)
        
        XCTAssertNoThrow(try restructure.migrate(version: 1) {
            try $0.execute(query: "CREATE TABLE foo (A INT)")
        })
        
        XCTAssertEqual(restructure.userVersion, 1)
    }
    
    func testMigrationWorksSerially() throws {
        XCTAssertEqual(restructure.userVersion, 0)
        
        XCTAssertNoThrow(try restructure.migrate(version: 1) {
            try $0.execute(query: "CREATE TABLE foo (A INT)")
        })
        
        XCTAssertNoThrow(try restructure.migrate(version: 2) {
            try $0.execute(query: "CREATE TABLE bar (A INT)")
        })
        
        XCTAssertEqual(restructure.userVersion, 2)
    }
    
    func testMigrationFailsOutOfSequence() throws {
        XCTAssertEqual(restructure.userVersion, 0)
        
        XCTAssertThrowsError(try restructure.migrate(version: 2) {
            try $0.execute(query: "CREATE TABLE foo (A INT)")
        })
        
        XCTAssertEqual(restructure.userVersion, 0)
    }
    
    func testMigrationSkipsIfDone() throws {
        XCTAssertEqual(restructure.userVersion, 0)
        
        XCTAssertNoThrow(try restructure.migrate(version: 1) {
            try $0.execute(query: "CREATE TABLE foo (A INT)")
        })
        
        XCTAssertEqual(try getFooCount(), 0)
        
        XCTAssertNoThrow(try restructure.migrate(version: 1) {
            try $0.execute(query: "INSERT INTO foo (a) VALUES (1)")
        })
        
        XCTAssertEqual(try getFooCount(), 0)
    }
    
    // MARK: - Custom Function Tests
    
    func testUpperFunctionWithStandardString() throws {
        // Create a table that stores strings
        try restructure.execute(query: "CREATE TABLE foo (id INTEGER PRIMARY KEY, value TEXT)")
        
        // Insert some test data
        try restructure.execute(query: "INSERT INTO foo (value) VALUES ('Hello')")
        let id = restructure.lastInsertedId
        
        // Fetch the data back out, with upper case values
        let fetchStatement = try restructure.prepare(query: "SELECT UPPER(value) AS value FROM foo WHERE id = :id")
        fetchStatement.bind(value: id, for: "id")
        
        guard case .row(let row) = fetchStatement.step() else {
            XCTFail("Failed to get inserted data")
            return
        }
        
        XCTAssertEqual(row["value"], "HELLO")
    }
    
    func testUpperFunctionWithComplexString() throws {
        // Create a table that stores strings
        try restructure.execute(query: "CREATE TABLE foo (id INTEGER PRIMARY KEY, value TEXT)")
        
        // Insert some test data
        try restructure.execute(query: "INSERT INTO foo (value) VALUES ('👋🏻 Hello 👋🏼')")
        let id = restructure.lastInsertedId
        
        // Fetch the data back out, with upper case values
        let fetchStatement = try restructure.prepare(query: "SELECT UPPER(value) AS value FROM foo WHERE id = :id")
        fetchStatement.bind(value: id, for: "id")
        
        guard case .row(let row) = fetchStatement.step() else {
            XCTFail("Failed to get inserted data")
            return
        }
        
        XCTAssertEqual(row["value"], "👋🏻 HELLO 👋🏼")
    }
    
    func testUpperFunctionWithUnicodeString() throws {
        // Create a table that stores strings
        try restructure.execute(query: "CREATE TABLE foo (id INTEGER PRIMARY KEY, value TEXT)")
        
        // Insert some test data
        try restructure.execute(query: "INSERT INTO foo (value) VALUES ('exámple óóßChloë')")
        let id = restructure.lastInsertedId
        
        // Fetch the data back out, with upper case values
        let fetchStatement = try restructure.prepare(query: "SELECT UPPER(value) AS value FROM foo WHERE id = :id")
        fetchStatement.bind(value: id, for: "id")
        
        guard case .row(let row) = fetchStatement.step() else {
            XCTFail("Failed to get inserted data")
            return
        }
        
        XCTAssertEqual(row["value"], "EXÁMPLE ÓÓSSCHLOË")
    }
    
    // MARK: - Utilities
    
    private func getFooCount() throws -> Int {
        let statement = try restructure.prepare(query: "SELECT COUNT(a) FROM foo")
        let result = statement.step()
        
        switch result {
        case let .row(row):
            return row[0]
        default:
            return Int.min
        }
    }
}
