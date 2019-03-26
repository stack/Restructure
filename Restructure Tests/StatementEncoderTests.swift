//
//  StatementEncoderTests.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/10/18.
//  Copyright @ 2019 Stephen H. Gerstacker. All rights reserved.
//

import XCTest
@testable import Restructure

class StatementEncoderTests: XCTestCase {

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
        struct Foo: Encodable {
            let a: Int64?
            let b: String
            let c: Double
            let d: Int
            let e: Data
        }
        
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
    
    func testEmojiStringEncodable() {
        struct Foo: Encodable {
            let a: Int64?
            let b: String
        }
        
        let statement = try! restructure.prepare(query: "INSERT INTO foo (b) VALUES (:b)")
        
        let foo = Foo(a: nil, b: "👋🏻 HELLO 👋🏼")
        
        let encoder = StatementEncoder()
        
        XCTAssertNoThrow(try encoder.encode(foo, to: statement))
        
        var result = statement.step()
        
        guard case .done = result else {
            XCTFail("Failed to insert data")
            return
        }
        
        let selectStatement = try! restructure.prepare(query: "SELECT a, b FROM foo LIMIT 1")
        
        result = selectStatement.step()
        
        guard case let .row(row) = result else {
            XCTFail("Failed to fetch row")
            return
        }
        
        XCTAssertEqual(row["b"], "👋🏻 HELLO 👋🏼")
    }
    
    func testUnicodeStringEncodable() {
        struct Foo: Encodable {
            let a: Int64?
            let b: String
        }
        
        let statement = try! restructure.prepare(query: "INSERT INTO foo (b) VALUES (:b)")
        
        let foo = Foo(a: nil, b: "exámple óóßChloë")
        
        let encoder = StatementEncoder()
        
        XCTAssertNoThrow(try encoder.encode(foo, to: statement))
        
        var result = statement.step()
        
        guard case .done = result else {
            XCTFail("Failed to insert data")
            return
        }
        
        let selectStatement = try! restructure.prepare(query: "SELECT a, b FROM foo LIMIT 1")
        
        result = selectStatement.step()
        
        guard case let .row(row) = result else {
            XCTFail("Failed to fetch row")
            return
        }
        
        XCTAssertEqual(row["b"], "exámple óóßChloë")
    }
    
    func testArrayEncodable() {
        struct Foo: Encodable {
            let a: Int64?
            let e: [Int]
        }
        
        let statement = try! restructure.prepare(query: "INSERT INTO foo (e) VALUES (:e)")
        
        let foo = Foo(a: nil, e: [1, 2, 3])
        
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
        struct Foo: Encodable {
            let a: Int64?
            let e: [[Int]]
        }
        
        let statement = try! restructure.prepare(query: "INSERT INTO foo (e) VALUES (:e)")
        
        let foo = Foo(a: nil, e: [[1, 2, 3]])
        
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
    
    func testEncodingEnumRawValues() {
        enum FooType: Int, Encodable {
            case one = 0
            case two = 1
        }
        
        struct Foo: Encodable {
            let id: Int64?
            let type: FooType
        }
        
        try! restructure.execute(query: "CREATE TABLE foobar (id INTEGER PRIMARY KEY AUTOINCREMENT, type INTEGER)")
        
        let statement = try! restructure.prepare(query: "INSERT INTO foobar (type) VALUES (:type)")
        
        let foo = Foo(id: nil, type: .two)
        
        let encoder = StatementEncoder()
        
        XCTAssertNoThrow(try encoder.encode(foo, to: statement))
        
        var result = statement.step()
        
        guard case .done = result else {
            XCTFail("Failed to insert data")
            return
        }
        
        let selectStatement = try! restructure.prepare(query: "SELECT id, type FROM foobar LIMIT 1")
        
        result = selectStatement.step()
        
        guard case let .row(row) = result else {
            XCTFail("Failed to fetch row")
            return
        }
        
        XCTAssertEqual(row["type"], 1)
    }
}
