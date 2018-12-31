//
//  StatementTests.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/4/18.
//  Copyright © 2018 Stephen H. Gerstacker. All rights reserved.
//

import XCTest
@testable import Restructure

class StatementTests: XCTestCase {

    var restructure: Restructure!
    
    override func setUp() {
        restructure = try! Restructure()
        try! restructure.execute(query: "CREATE TABLE foo (a INTEGER PRIMARY KEY AUTOINCREMENT, b TEXT, c REAL, d INT, e BLOB)")
    }

    override func tearDown() {
        restructure.close()
        restructure = nil
    }

    
    // MARK: - Prepare Tests
    
    func testPrepareInvalidStatement() {
        XCTAssertThrowsError(try restructure.prepare(query: "SELECT FOO BAR BAZ"))
    }
    
    func testPrepareValidStatementWithBindables() {
        var statement: Statement!
        XCTAssertNoThrow(statement = try restructure.prepare(query: "SELECT a, b, c FROM foo WHERE b IS :ONE OR b IS $TWO OR c IS @THREE"))
        
        XCTAssertEqual(3, statement.bindables.count)
        XCTAssertEqual(1, statement.bindables["ONE"])
        XCTAssertEqual(2, statement.bindables["TWO"])
        XCTAssertEqual(3, statement.bindables["THREE"])
        
        XCTAssertEqual(3, statement.columns.count)
        XCTAssertEqual(0, statement.columns["a"])
        XCTAssertEqual(1, statement.columns["b"])
        XCTAssertEqual(2, statement.columns["c"])
    }
    
    func testPrepareValidStatementWithoutBindables() {
        var statement: Statement!
        XCTAssertNoThrow(statement = try restructure.prepare(query: "SELECT a, b, c FROM foo WHERE b IS ? OR b IS ? OR c IS ?"))
            
        XCTAssertEqual(0, statement.bindables.count)
        
        XCTAssertEqual(3, statement.columns.count)
        XCTAssertEqual(0, statement.columns["a"])
        XCTAssertEqual(1, statement.columns["b"])
        XCTAssertEqual(2, statement.columns["c"])
    }
    
    
    // MARK: - Read / Write Tests
    
    func testDeleteStatement() {
        var insertStatement: Statement!
        
        // Insert a row
        XCTAssertNoThrow(insertStatement = try restructure.prepare(query: "INSERT INTO foo (b, c, d, e) VALUES (:B, :C, :D, :E)"))
        
        insertStatement.bind(value: "foo", for: "B")
        insertStatement.bind(value: 42.1, for: "C")
        insertStatement.bind(value: 42, for: "D")
        
        let data = Data(bytes: UnsafePointer<UInt8>([ 0x41, 0x42, 0x43 ] as [UInt8]), count: 3)
        insertStatement.bind(value: data, for: "E")
        
        XCTAssertNoThrow(try insertStatement.perform())
        
        // Ensure we have 1 row
        let initialCount = fooCount
        XCTAssertEqual(1, initialCount)
        
        // Delete all rows
        var deleteStatement: Statement!
        XCTAssertNoThrow(deleteStatement = try restructure.prepare(query: "DELETE FROM foo"))
        
        XCTAssertNoThrow(try deleteStatement.perform())
        
        // Ensure we have 0 rows
        let deletedCount = fooCount
        XCTAssertEqual(0, deletedCount)
    }
    
    func testInsertStatement() {
        // Ensure we have no rows
        let initialCount = fooCount
        XCTAssertEqual(0, initialCount)
        
        // Insert a row
        var insertStatement: Statement!
        XCTAssertNoThrow(insertStatement = try restructure.prepare(query: "INSERT INTO foo (b, c, d, e) VALUES (:B, :C, :D, :E)"))
        
        insertStatement.bind(value: "foo", for: "B")
        insertStatement.bind(value: 42.1, for: "C")
        insertStatement.bind(value: 42, for: "D")
        
        let data = Data(bytes: UnsafePointer<UInt8>([ 0x41, 0x42, 0x43 ] as [UInt8]), count: 3)
        insertStatement.bind(value: data, for: "E")
        
        XCTAssertNoThrow(try insertStatement.perform())
        
        // Ensure we have 1 row
        let updatedCount = fooCount
        XCTAssertEqual(1, updatedCount)
        
        // Get the data that was inserted
        let lastId = restructure.lastInsertedId
        
        var selectStatement: Statement!
        XCTAssertNoThrow(selectStatement = try restructure.prepare(query: "SELECT a, b, c, d, e FROM foo"))
        
        let result = selectStatement.step()
        
        guard case let .row(row) = result else {
            XCTFail("Failed to get row result")
            return
        }
        
        let aString: Int64 = row["a"]
        let bString: String? = row["b"]
        let cString: Double = row["c"]
        let dString: Int = row["d"]
        let eString: Data? = row["e"]
        
        XCTAssertEqual(lastId, aString)
        XCTAssertEqual("foo", bString)
        XCTAssertEqual(42.1, cString)
        XCTAssertEqual(42, dString)
        XCTAssertEqual(data, eString)
        
        let aInt: Int64 = row[0]
        let bInt: String? = row[1]
        let cInt: Double = row[2]
        let dInt: Int = row[3]
        let eInt: Data? = row[4]
        
        XCTAssertEqual(lastId, aInt)
        XCTAssertEqual("foo", bInt)
        XCTAssertEqual(42.1, cInt)
        XCTAssertEqual(42, dInt)
        XCTAssertEqual(data, eInt)
    }
    
    func testInsertNull() {
        // Ensure we have no rows
        let initialCount = fooCount
        XCTAssertEqual(0, initialCount)
        
        // Insert a row
        var insertStatement: Statement!
        XCTAssertNoThrow(insertStatement = try restructure.prepare(query: "INSERT INTO foo (b, c, d, e) VALUES (:B, :C, :D, :E)"))
        
        let nullString: String? = nil
        let nullDouble: Double? = nil
        let nullInt: Int? = nil
        let nullData: Data? = nil
        
        insertStatement.bind(value: nullString, for: "B")
        insertStatement.bind(value: nullDouble, for: "C")
        insertStatement.bind(value: nullInt, for: "D")
        insertStatement.bind(value: nullData, for: "E")
        
        XCTAssertNoThrow(try insertStatement.perform())
        
        // Ensure we have 1 row
        let updatedCount = fooCount
        XCTAssertEqual(1, updatedCount)
        
        // Get the data that was inserted
        let lastId = restructure.lastInsertedId
        
        var selectStatement: Statement!
        XCTAssertNoThrow(selectStatement = try restructure.prepare(query: "SELECT a, b, c, d, e FROM foo"))
        
        let result = selectStatement.step()
        
        guard case let .row(row) = result else {
            XCTFail("Failed to get row result")
            return
        }
        
        let aValue: Int64 = row["a"]
        let bValue: String? = row["b"]
        let cValue: Double? = row["c"]
        let dValue: Int? = row["d"]
        let eValue: Data? = row["e"]
        
        XCTAssertEqual(lastId, aValue)
        XCTAssertNil(bValue)
        XCTAssertNil(cValue)
        XCTAssertNil(dValue)
        XCTAssertNil(eValue)
    }
    
    func testUpdateStatement() {
        // Insert a row
        var insertStatement: Statement!
        XCTAssertNoThrow(insertStatement = try restructure.prepare(query: "INSERT INTO foo (b, c, d, e) VALUES (:B, :C, :D, :E)"))
        
        insertStatement.bind(value: "foo", for: "B")
        insertStatement.bind(value: 42.1, for: "C")
        insertStatement.bind(value: 42, for: "D")
        
        let data = Data(bytes: UnsafePointer<UInt8>([ 0x41, 0x42, 0x43 ] as [UInt8]), count: 3)
        insertStatement.bind(value: data, for: "E")
        
        XCTAssertNoThrow(try insertStatement.perform())
        
        // Ensure we have 1 row
        let initialCount = fooCount
        XCTAssertEqual(1, initialCount)
        
        // Get the data that was inserted
        let lastId = restructure.lastInsertedId
        
        // Update the row
        var updateStatement: Statement!
        XCTAssertNoThrow(updateStatement = try restructure.prepare(query: "UPDATE foo SET b = :B, c = :C, d = :D, e = :E where a = :A"))
        
        updateStatement.bind(value: "bar", for: "B")
        updateStatement.bind(value: 1.1, for: "C")
        updateStatement.bind(value: 2, for: "D")
        updateStatement.bind(value: lastId, for: "A")
        
        let data2 = Data(bytes: UnsafePointer<UInt8>([ 0x44, 0x45, 0x46 ] as [UInt8]), count: 3)
        updateStatement.bind(value: data2, for: "E")
        
        XCTAssertNoThrow(try updateStatement.perform())
        
        // Ensure there is still one row
        let updatedCount = fooCount
        XCTAssertEqual(1, updatedCount)
        
        // Ensure the updated values are set
        var selectStatement: Statement!
        XCTAssertNoThrow(selectStatement = try restructure.prepare(query: "SELECT a, b, c, d, e FROM foo WHERE a = :A"))
        
        selectStatement.bind(value: lastId, for: "A")
        
        let result = selectStatement.step()
        
        guard case let .row(row) = result else {
            XCTFail("Failed to get row result")
            return
        }
        
        let aString: Int64 = row["a"]
        let bString: String? = row["b"]
        let cString: Double = row["c"]
        let dString: Int = row["d"]
        let eString: Data? = row["e"]
        
        XCTAssertEqual(lastId, aString)
        XCTAssertEqual("bar", bString)
        XCTAssertEqual(1.1, cString)
        XCTAssertEqual(2, dString)
        XCTAssertEqual(data2, eString)
        
        let aInt: Int64 = row[0]
        let bInt: String? = row[1]
        let cInt: Double = row[2]
        let dInt: Int = row[3]
        let eInt: Data? = row[4]
        
        XCTAssertEqual(lastId, aInt)
        XCTAssertEqual("bar", bInt)
        XCTAssertEqual(1.1, cInt)
        XCTAssertEqual(2, dInt)
        XCTAssertEqual(data2, eInt)
    }
    
    func testReturnsMultipleRows() {
        // Build the insertion statement
        let insertStatement = try! restructure.prepare(query: "INSERT INTO foo (b, c, d, e) VALUES (:B, :C, :D, :E)")
        
        // Insert 1
        insertStatement.bind(value: "one", for: "B")
        insertStatement.bind(value: 1.1, for: "C")
        insertStatement.bind(value: 1, for: "D")
        
        let data1 = Data(bytes: UnsafePointer<UInt8>([ 0x01 ] as [UInt8]), count: 1)
        insertStatement.bind(value: data1, for: "E")
        
        XCTAssertNoThrow(try insertStatement.perform())
        
        // Insert 2
        insertStatement.reset()
        
        insertStatement.bind(value: "two", for: "B")
        insertStatement.bind(value: 2.2, for: "C")
        insertStatement.bind(value: 2, for: "D")
        
        let data2 = Data(bytes: UnsafePointer<UInt8>([ 0x02 ] as [UInt8]), count: 1)
        insertStatement.bind(value: data2, for: "E")
        
        XCTAssertNoThrow(try insertStatement.perform())
        insertStatement.reset()
        
        // Insert 3
        insertStatement.reset()
        
        insertStatement.bind(value: "three", for: "B")
        insertStatement.bind(value: 3.3, for: "C")
        insertStatement.bind(value: 3, for: "D")
        
        let data3 = Data(bytes: UnsafePointer<UInt8>([ 0x03 ] as [UInt8]), count: 1)
        insertStatement.bind(value: data3, for: "E")
        
        XCTAssertNoThrow(try insertStatement.perform())
        
        // Read rows
        let selectStatement = try! restructure.prepare(query: "SELECT a, b, c, d, e FROM foo ORDER BY c ASC")
        
        // Read 1
        guard case let .row(row1) = selectStatement.step() else {
            XCTFail("Failed to read row")
            return
        }
        
        let b1: String? = row1[1]
        let c1: Double = row1[2]
        let d1: Int = row1[3]
        let e1: Data? = row1[4]
        
        XCTAssertEqual("one", b1)
        XCTAssertEqual(1.1, c1)
        XCTAssertEqual(1, d1)
        XCTAssertNotNil(e1)
        XCTAssertEqual(1, e1!.count)
        XCTAssertEqual(0x01, e1![0])
        
        // Read 2
        guard case let .row(row2) = selectStatement.step() else {
            XCTFail("Failed to read row")
            return
        }
        
        let b2: String? = row2[1]
        let c2: Double = row2[2]
        let d2: Int = row2[3]
        let e2: Data? = row2[4]
        
        XCTAssertEqual("two", b2)
        XCTAssertEqual(2.2, c2)
        XCTAssertEqual(2, d2)
        XCTAssertNotNil(e2)
        XCTAssertEqual(1, e2!.count)
        XCTAssertEqual(0x02, e2![0])
        
        // Read 3
        guard case let .row(row3) = selectStatement.step() else {
            XCTFail("Failed to read row")
            return
        }
        
        let b3: String? = row3[1]
        let c3: Double = row3[2]
        let d3: Int = row3[3]
        let e3: Data? = row3[4]
        
        XCTAssertEqual("three", b3)
        XCTAssertEqual(3.3, c3)
        XCTAssertEqual(3, d3)
        XCTAssertNotNil(e3)
        XCTAssertEqual(1, e3!.count)
        XCTAssertEqual(0x03, e3![0])
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
