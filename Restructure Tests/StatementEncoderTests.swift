//
//  StatementEncoderTests.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/10/18.
//  Copyright © 2018 Stephen H. Gerstacker. All rights reserved.
//

import XCTest
@testable import Restructure

class StatementEncoderTests: XCTestCase {
    
    struct Foo: Encodable {
        let a: Int64?
        let b: String
        let c: Double
        let d: Int
        let e: Data
    }
    
    struct FooWithArray: Encodable {
        let a: Int64?
        let e: [Int]
    }
    
    struct FooWithMultiArray: Encodable {
        let a: Int64?
        let e: [[Int]]
    }

    var restructure: Restructure!
    
    override func setUp() {
        restructure = try! Restructure()
        try! restructure.execute(query: "CREATE TABLE foo (a INTEGER PRIMARY KEY AUTOINCREMENT, b TEXT, c REAL, d INT, e BLOB)")
    }

    override func tearDown() {
        restructure.close()
        restructure = nil
    }

    func testSimpleEncodable() {
        let statement = try! restructure.prepare(query: "INSERT INTO foo (b, c, d, e) VALUES (:b, :c, :d, :e)")
        
        let foo = Foo(a: nil, b: "1", c: 2.0, d: 3, e: Data(bytes: [0x4, 0x5, 0x6], count: 3))
        
        let encoder = StatementEncoder()
        
        XCTAssertNoThrow(try encoder.encode(foo, to: statement))
        
        var result = statement.step()
        
        guard case .done = result else {
            XCTFail("Failed to insert data")
            return
        }
        
        let selectStatement = try! restructure.prepare(query: "SELECT a, b, c, d, e FROM foo LIMIT 1")
        
        result = selectStatement.step()
        
        guard case let .row(row) = result else {
            XCTFail("Failed to fetch row")
            return
        }
        
        XCTAssertEqual(row["b"], "1")
        XCTAssertEqual(row["c"], 2.0)
        XCTAssertEqual(row["d"], 3)
        XCTAssertEqual(row["e"], Data(bytes: [0x4, 0x5, 0x6], count: 3))
    }
    
    func testArrayEncodable() {
        let statement = try! restructure.prepare(query: "INSERT INTO foo (e) VALUES (:e)")
        
        let foo = FooWithArray(a: nil, e: [1, 2, 3])
        
        let encoder = StatementEncoder()
        
        XCTAssertNoThrow(try encoder.encode(foo, to: statement))
        
        var result = statement.step()
        
        guard case .done = result else {
            XCTFail("Failed to insert data")
            return
        }
        
        let selectStatement = try! restructure.prepare(query: "SELECT a, e FROM foo LIMIT 1")
        
        result = selectStatement.step()
        
        guard case let .row(row) = result else {
            XCTFail("Failed to fetch row")
            return
        }
        
        XCTAssertEqual(row["e"], [1, 2, 3])
    }
    
    func testMultiArrayEncodable() {
        let statement = try! restructure.prepare(query: "INSERT INTO foo (e) VALUES (:e)")
        
        let foo = FooWithMultiArray(a: nil, e: [[1, 2, 3]])
        
        let encoder = StatementEncoder()
        
        XCTAssertNoThrow(try encoder.encode(foo, to: statement))
        
        var result = statement.step()
        
        guard case .done = result else {
            XCTFail("Failed to insert data")
            return
        }
        
        let selectStatement = try! restructure.prepare(query: "SELECT a, e FROM foo LIMIT 1")
        
        result = selectStatement.step()
        
        guard case let .row(row) = result else {
            XCTFail("Failed to fetch row")
            return
        }
        
        XCTAssertEqual(row["e"], [[1, 2, 3]])
    }
}
