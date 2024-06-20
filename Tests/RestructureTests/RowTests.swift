//
//  RowTests.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/4/18.
//  Copyright @ 2020 Stephen H. Gerstacker. All rights reserved.
//

import XCTest
@testable import Restructure

class RowTests: XCTestCase {

    // MARK: - Properties
    
    var restructure: Restructure!
    
    
    // MARK: - Set Up & Tear Down
    
    override func setUpWithError() throws {
        restructure = try Restructure()
    }

    override func tearDown() {
        restructure.close()
        restructure = nil
    }
    
    // MARK: - Boolean Tests
    
    func testBool() throws {
        try restructure.execute(query: "CREATE TABLE foo (a INT, p INT)")
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a, p) VALUES (:a, :p)")
        
        insertStatement.bind(value: false, for: "a")
        insertStatement.bind(value: 0, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: true, for: "a")
        insertStatement.bind(value: 0, for: "p")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a FROM foo ORDER BY p")
        
        guard case let .row(row1) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value1: Bool = row1["a"]
        XCTAssertFalse(value1)
        
        guard case let .row(row2) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value2: Bool = row2["a"]
        XCTAssertTrue(value2)
    }
    
    
    // MARK: - Signed Integer Tests
    
    func testInt() throws {
        try restructure.execute(query: "CREATE TABLE foo (a INT, p INT)")
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a, p) VALUES (:a, :p)")
        
        insertStatement.bind(value: Int(0), for: "a")
        insertStatement.bind(value: 0, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: Int.min, for: "a")
        insertStatement.bind(value: 1, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: Int.max, for: "a")
        insertStatement.bind(value: 2, for: "p")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a FROM foo ORDER BY p")
        
        guard case let .row(row1) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value1: Int = row1["a"]
        XCTAssertEqual(value1, 0)
        
        guard case let .row(row2) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value2: Int = row2["a"]
        XCTAssertEqual(value2, Int.min)
        
        
        guard case let .row(row3) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value3: Int = row3["a"]
        XCTAssertEqual(value3, Int.max)
    }
    
    func testInt8() throws {
        try restructure.execute(query: "CREATE TABLE foo (a INT, p INT)")
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a, p) VALUES (:a, :p)")
        
        insertStatement.bind(value: Int8(0), for: "a")
        insertStatement.bind(value: 0, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: Int8.min, for: "a")
        insertStatement.bind(value: 1, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: Int8.max, for: "a")
        insertStatement.bind(value: 2, for: "p")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a FROM foo ORDER BY p")
        
        guard case let .row(row1) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value1: Int8 = row1["a"]
        XCTAssertEqual(value1, 0)
        
        guard case let .row(row2) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value2: Int8 = row2["a"]
        XCTAssertEqual(value2, Int8.min)
        
        
        guard case let .row(row3) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value3: Int8 = row3["a"]
        XCTAssertEqual(value3, Int8.max)
    }
    
    func testInt16() throws {
        try restructure.execute(query: "CREATE TABLE foo (a INT, p INT)")
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a, p) VALUES (:a, :p)")
        
        insertStatement.bind(value: Int16(0), for: "a")
        insertStatement.bind(value: 0, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: Int16.min, for: "a")
        insertStatement.bind(value: 1, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: Int16.max, for: "a")
        insertStatement.bind(value: 2, for: "p")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a FROM foo ORDER BY p")
        
        guard case let .row(row1) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value1: Int16 = row1["a"]
        XCTAssertEqual(value1, 0)
        
        guard case let .row(row2) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value2: Int16 = row2["a"]
        XCTAssertEqual(value2, Int16.min)
        
        
        guard case let .row(row3) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value3: Int16 = row3["a"]
        XCTAssertEqual(value3, Int16.max)
    }
    
    func testInt32() throws {
        try restructure.execute(query: "CREATE TABLE foo (a INT, p INT)")
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a, p) VALUES (:a, :p)")
        
        insertStatement.bind(value: Int32(0), for: "a")
        insertStatement.bind(value: 0, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: Int32.min, for: "a")
        insertStatement.bind(value: 1, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: Int32.max, for: "a")
        insertStatement.bind(value: 2, for: "p")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a FROM foo ORDER BY p")
        
        guard case let .row(row1) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value1: Int32 = row1["a"]
        XCTAssertEqual(value1, 0)
        
        guard case let .row(row2) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value2: Int32 = row2["a"]
        XCTAssertEqual(value2, Int32.min)
        
        
        guard case let .row(row3) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value3: Int32 = row3["a"]
        XCTAssertEqual(value3, Int32.max)
    }
    
    func testInt64() throws {
        try restructure.execute(query: "CREATE TABLE foo (a INT, p INT)")
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a, p) VALUES (:a, :p)")
        
        insertStatement.bind(value: Int64(0), for: "a")
        insertStatement.bind(value: 0, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: Int64.min, for: "a")
        insertStatement.bind(value: 1, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: Int64.max, for: "a")
        insertStatement.bind(value: 2, for: "p")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a FROM foo ORDER BY p")
        
        guard case let .row(row1) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value1: Int64 = row1["a"]
        XCTAssertEqual(value1, 0)
        
        guard case let .row(row2) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value2: Int64 = row2["a"]
        XCTAssertEqual(value2, Int64.min)
        
        
        guard case let .row(row3) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value3: Int64 = row3["a"]
        XCTAssertEqual(value3, Int64.max)
    }
    
    // MARK: - Unsigned Integer Tests
    
    func testUInt() throws {
        try restructure.execute(query: "CREATE TABLE foo (a INT, p INT)")
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a, p) VALUES (:a, :p)")
        
        insertStatement.bind(value: UInt(0), for: "a")
        insertStatement.bind(value: 0, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: UInt.min, for: "a")
        insertStatement.bind(value: 1, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: UInt.max, for: "a")
        insertStatement.bind(value: 2, for: "p")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a FROM foo ORDER BY p")
        
        guard case let .row(row1) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value1: UInt = row1["a"]
        XCTAssertEqual(value1, 0)
        
        guard case let .row(row2) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value2: UInt = row2["a"]
        XCTAssertEqual(value2, UInt.min)
        
        
        guard case let .row(row3) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value3: UInt = row3["a"]
        XCTAssertEqual(value3, UInt.max)
    }
    
    func testUInt8() throws {
        try restructure.execute(query: "CREATE TABLE foo (a INT, p INT)")
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a, p) VALUES (:a, :p)")
        
        insertStatement.bind(value: UInt8(0), for: "a")
        insertStatement.bind(value: 0, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: UInt8.min, for: "a")
        insertStatement.bind(value: 1, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: UInt8.max, for: "a")
        insertStatement.bind(value: 2, for: "p")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a FROM foo ORDER BY p")
        
        guard case let .row(row1) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value1: UInt8 = row1["a"]
        XCTAssertEqual(value1, 0)
        
        guard case let .row(row2) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value2: UInt8 = row2["a"]
        XCTAssertEqual(value2, UInt8.min)
        
        
        guard case let .row(row3) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value3: UInt8 = row3["a"]
        XCTAssertEqual(value3, UInt8.max)
    }
    
    func testUInt16() throws {
        try restructure.execute(query: "CREATE TABLE foo (a INT, p INT)")
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a, p) VALUES (:a, :p)")
        
        insertStatement.bind(value: UInt16(0), for: "a")
        insertStatement.bind(value: 0, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: UInt16.min, for: "a")
        insertStatement.bind(value: 1, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: UInt16.max, for: "a")
        insertStatement.bind(value: 2, for: "p")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a FROM foo ORDER BY p")
        
        guard case let .row(row1) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value1: UInt16 = row1["a"]
        XCTAssertEqual(value1, 0)
        
        guard case let .row(row2) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value2: UInt16 = row2["a"]
        XCTAssertEqual(value2, UInt16.min)
        
        
        guard case let .row(row3) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value3: UInt16 = row3["a"]
        XCTAssertEqual(value3, UInt16.max)
    }
    
    func testUInt32() throws {
        try restructure.execute(query: "CREATE TABLE foo (a INT, p INT)")
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a, p) VALUES (:a, :p)")
        
        insertStatement.bind(value: UInt32(0), for: "a")
        insertStatement.bind(value: 0, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: UInt32.min, for: "a")
        insertStatement.bind(value: 1, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: UInt32.max, for: "a")
        insertStatement.bind(value: 2, for: "p")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a FROM foo ORDER BY p")
        
        guard case let .row(row1) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value1: UInt32 = row1["a"]
        XCTAssertEqual(value1, 0)
        
        guard case let .row(row2) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value2: UInt32 = row2["a"]
        XCTAssertEqual(value2, UInt32.min)
        
        
        guard case let .row(row3) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value3: UInt32 = row3["a"]
        XCTAssertEqual(value3, UInt32.max)
    }
    
    
    // MARK: - Array Tests
    
    func testArrayBinaryPList() throws {
        restructure.arrayStrategy = .bplist
        
        try restructure.execute(query: "CREATE TABLE foo (a BLOB, p INT)")
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a, p) VALUES (:a, :p)")
        
        insertStatement.bind(value: [1, 2, 3], for: "a")
        insertStatement.bind(value: 0, for: "p")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a FROM foo ORDER BY p")
        
        guard case let .row(row) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        XCTAssertEqual(row["a"], [1, 2, 3])
    }
    
    func testArrayJSON() throws {
        restructure.arrayStrategy = .json
        
        try restructure.execute(query: "CREATE TABLE foo (a BLOB, p INT)")
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a, p) VALUES (:a, :p)")
        
        insertStatement.bind(value: [1, 2, 3], for: "a")
        insertStatement.bind(value: 0, for: "p")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a FROM foo ORDER BY p")
        
        guard case let .row(row) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        XCTAssertEqual(row["a"], [1, 2, 3])
    }
    
    func testMultiDimensionalArrayBinaryPList() throws {
        restructure.arrayStrategy = .bplist
        
        try restructure.execute(query: "CREATE TABLE foo (a BLOB, p INT)")
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a, p) VALUES (:a, :p)")
        
        insertStatement.bind(value: [[1.0, 2.0, 3.0]], for: "a")
        insertStatement.bind(value: 0, for: "p")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a FROM foo ORDER BY p")
        
        guard case let .row(row) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        XCTAssertEqual(row["a"], [[1.0, 2.0, 3.0]])
    }
    
    func testMultiDimensionalArrayJSON() throws {
        restructure.arrayStrategy = .json
        
        try restructure.execute(query: "CREATE TABLE foo (a BLOB, p INT)")
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a, p) VALUES (:a, :p)")
        
        insertStatement.bind(value: [[1.0, 2.0, 3.0]], for: "a")
        insertStatement.bind(value: 0, for: "p")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a FROM foo ORDER BY p")
        
        guard case let .row(row) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        XCTAssertEqual(row["a"], [[1.0, 2.0, 3.0]])
    }
    
    // MARK: - Real Tests
    
    func testFloat() throws {
        try restructure.execute(query: "CREATE TABLE foo (a REAL, p INT)")
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a, p) VALUES (:a, :p)")
        
        insertStatement.bind(value: Float(0.0), for: "a")
        insertStatement.bind(value: 0, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: Float.greatestFiniteMagnitude * -1.0, for: "a")
        insertStatement.bind(value: 1, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: Float.greatestFiniteMagnitude, for: "a")
        insertStatement.bind(value: 2, for: "p")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a FROM foo ORDER BY p")
        
        guard case let .row(row1) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value1: Float = row1["a"]
        XCTAssertEqual(value1, 0.0)
        
        guard case let .row(row2) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value2: Float = row2["a"]
        XCTAssertEqual(value2, Float.greatestFiniteMagnitude * -1.0)
        
        
        guard case let .row(row3) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value3: Float = row3["a"]
        XCTAssertEqual(value3, Float.greatestFiniteMagnitude)
    }
    
    func testDouble() throws {
        try restructure.execute(query: "CREATE TABLE foo (a REAL, p INT)")
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a, p) VALUES (:a, :p)")
        
        insertStatement.bind(value: Double(0.0), for: "a")
        insertStatement.bind(value: 0, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: Double.greatestFiniteMagnitude * -1.0, for: "a")
        insertStatement.bind(value: 1, for: "p")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: Double.greatestFiniteMagnitude, for: "a")
        insertStatement.bind(value: 2, for: "p")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a FROM foo ORDER BY p")
        
        guard case let .row(row1) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value1: Double = row1["a"]
        XCTAssertEqual(value1, 0.0)
        
        guard case let .row(row2) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value2: Double = row2["a"]
        XCTAssertEqual(value2, Double.greatestFiniteMagnitude * -1.0)
        
        
        guard case let .row(row3) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let value3: Double = row3["a"]
        XCTAssertEqual(value3, Double.greatestFiniteMagnitude)
    }
    
    
    // MARK: - Complex Tests

    func testData() throws {
        try restructure.execute(query: "CREATE TABLE foo (a BLOB)")
        
        let data1 = Data(bytes: [0x41, 0x42, 0x43], count: 3)
        
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a) VALUES (:a)")
        insertStatement.bind(value: data1, for: "a")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a FROM foo LIMIT 1")
        
        guard case let .row(row) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let data2: Data? = row["a"]
        
        XCTAssertNotNil(data2)
        XCTAssertEqual(data1, data2!)
    }
    
    func testIntegerDate() throws {
        let now =  Date()
        
        try restructure.execute(query: "CREATE TABLE foo (a INT)")
        
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a) VALUES (:a)")
        insertStatement.dateStrategy = .integer
        insertStatement.bind(value: now, for: "a")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a from foo LIMIT 1")
        
        guard case let .row(row) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let date: Date = row["a"]
        
        // NOTE: Accuracy is lost because Date's time interval is down to fractions of a second, and values are stored in whole seconds
        XCTAssertEqual(date.timeIntervalSince1970, now.timeIntervalSince1970, accuracy: 1.0)
    }
    
    func testRealDate() throws {
        let now =  Date()
        
        try restructure.execute(query: "CREATE TABLE foo (a REAL)")
        
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a) VALUES (:a)")
        insertStatement.dateStrategy = .real
        insertStatement.bind(value: now, for: "a")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a from foo LIMIT 1")
        selectStatement.dateStrategy = .real
        
        guard case let .row(row) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let date: Date = row["a"]
        
        // NOTE: Accuracy is lost here, but only just slightly
        XCTAssertEqual(date.timeIntervalSince1970, now.timeIntervalSince1970, accuracy: 1.0)
    }
    
    func testTextDate() throws {
        let now =  Date()
        
        try restructure.execute(query: "CREATE TABLE foo (a TEXT)")
        
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a) VALUES (:a)")
        insertStatement.dateStrategy = .text
        insertStatement.bind(value: now, for: "a")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a from foo LIMIT 1")
        selectStatement.dateStrategy = .text
        
        guard case let .row(row) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let date: Date = row["a"]
        
        // NOTE: Accuracy is lost because Date's time interval is down to fractions of a second, and values are stored in whole seconds
        XCTAssertEqual(date.timeIntervalSince1970, now.timeIntervalSince1970, accuracy: 1.0)
    }
    
    func testSimpleString() throws {
        try restructure.execute(query: "CREATE TABLE foo (a TEXT)")
        
        let data1 = "Hello, World!"
        
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a) VALUES (:a)")
        insertStatement.bind(value: data1, for: "a")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a FROM foo LIMIT 1")
        
        guard case let .row(row) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let data2: String? = row["a"]
        
        XCTAssertNotNil(data2)
        XCTAssertEqual(data1, data2!)
    }
    
    func testEmojiString() throws {
        try restructure.execute(query: "CREATE TABLE foo (a TEXT)")
        
        let data1 = "👨‍👨‍👧‍👧 Hello, World! 👋🏼"
        
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a) VALUES (:a)")
        insertStatement.bind(value: data1, for: "a")
        _ = insertStatement.step()
        
        let selectStatement = try restructure.prepare(query: "SELECT a FROM foo LIMIT 1")
        
        guard case let .row(row) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let data2: String? = row["a"]
        
        XCTAssertNotNil(data2)
        XCTAssertEqual(data1, data2!)
    }


    // MARK: - Dynamic Member Tests

    func testDynamicMembers() throws {
        try restructure.execute(query: "CREATE TABLE foo (a INT, t TEXT)")
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (a, t) VALUES (:a, :t)")

        insertStatement.bind(value: 0, for: "a")
        insertStatement.bind(value: "Text 0", for: "t")
        _ = insertStatement.step()

        insertStatement.reset()

        insertStatement.bind(value: 1, for: "a")
        insertStatement.bind(value: "Text 1", for: "t")
        _ = insertStatement.step()

        insertStatement.reset()

        insertStatement.bind(value: 2, for: "a")
        insertStatement.bind(value: "Text 2", for: "t")
        _ = insertStatement.step()

        let selectStatement = try restructure.prepare(query: "SELECT a, t FROM foo ORDER BY t")

        guard case let .row(row1) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }

        let row1Int: Int = row1.a
        let row1String: String = row1.t

        XCTAssertEqual(row1Int, 0)
        XCTAssertEqual(row1String, "Text 0")

        guard case let .row(row2) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }

        let row2Int: Int = row2.a
        let row2String: String = row2.t

        XCTAssertEqual(row2Int, 1)
        XCTAssertEqual(row2String, "Text 1")

        guard case let .row(row3) = selectStatement.step() else {
            XCTFail("Failed to fetch row")
            return
        }

        let row3Int: Int = row3.a
        let row3String: String = row3.t

        XCTAssertEqual(row3Int, 2)
        XCTAssertEqual(row3String, "Text 2")
    }
}
