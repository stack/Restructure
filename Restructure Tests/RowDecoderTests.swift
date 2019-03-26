//
//  RowDecoderTests.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/30/18.
//  Copyright @ 2019 Stephen H. Gerstacker. All rights reserved.
//

import XCTest

class RowDecoderTests: XCTestCase {
    
    var restructure: Restructure!

    override func setUp() {
        restructure = try! Restructure()
        try! restructure.execute(query: "CREATE TABLE foo (a INTEGER PRIMARY KEY AUTOINCREMENT, b TEXT, c REAL, d INT, e BLOB)")
    }

    override func tearDown() {
        restructure.close()
        restructure = nil
    }

    func testSimpleDecodable() {
        struct Foo: Decodable {
            let a: Int64?
            let b: String
            let c: Double
            let d: Int
            let e: Data
        }
        
        let insertStatement = try! restructure.prepare(query: "INSERT INTO foo (b, c, d, e) VALUES (:b, :c, :d, :e)")
        insertStatement.bind(value: "1", for: "b")
        insertStatement.bind(value: 2.0, for: "c")
        insertStatement.bind(value: 3, for: "d")
        insertStatement.bind(value: Data(bytes: [0x4, 0x5, 0x6], count: 3), for: "e")

        try! insertStatement.perform()
        
        let selectStatement = try! restructure.prepare(query: "SELECT a, b, c, d, e FROM foo LIMIT 1")
        
        let result = selectStatement.step()
        
        guard case let .row(row) = result else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let decoder = RowDecoder()
        let foo = try! decoder.decode(Foo.self, from: row)
        
        XCTAssertEqual(foo.b, "1")
        XCTAssertEqual(foo.c, 2.0)
        XCTAssertEqual(foo.d, 3)
        XCTAssertEqual(foo.e, Data(bytes: [0x4, 0x5, 0x6], count: 3))
    }
    
    func testEmojiStringDecodable() {
        struct Foo: Decodable {
            let a: Int64?
            let b: String
        }
        
        let insertStatement = try! restructure.prepare(query: "INSERT INTO foo (b) VALUES (:b)")
        insertStatement.bind(value: "👋🏻 HELLO 👋🏼", for: "b")
        
        try! insertStatement.perform()
        
        let selectStatement = try! restructure.prepare(query: "SELECT a, b FROM foo LIMIT 1")
        
        let result = selectStatement.step()
        
        guard case let .row(row) = result else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let decoder = RowDecoder()
        let foo = try! decoder.decode(Foo.self, from: row)
        
        XCTAssertEqual(foo.b, "👋🏻 HELLO 👋🏼")
    }
    
    func testUnicodeStringDecodable() {
        struct Foo: Decodable {
            let a: Int64?
            let b: String
        }
        
        let insertStatement = try! restructure.prepare(query: "INSERT INTO foo (b) VALUES (:b)")
        insertStatement.bind(value: "exámple óóßChloë", for: "b")
        
        try! insertStatement.perform()
        
        let selectStatement = try! restructure.prepare(query: "SELECT a, b FROM foo LIMIT 1")
        
        let result = selectStatement.step()
        
        guard case let .row(row) = result else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let decoder = RowDecoder()
        let foo = try! decoder.decode(Foo.self, from: row)
        
        XCTAssertEqual(foo.b, "exámple óóßChloë")
    }
    
    func testArrayDecodable() {
        struct Foo: Decodable {
            let a: Int64?
            let e: [Int]
        }
        
        let insertStatement = try! restructure.prepare(query: "INSERT INTO foo (e) VALUES (:e)")
        insertStatement.bind(value: [1, 2, 3], for: "e")
        
        try! insertStatement.perform()
        
        let selectStatement = try! restructure.prepare(query: "SELECT a, e FROM foo LIMIT 1")
        
        let result = selectStatement.step()
        
        guard case let .row(row) = result else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let decoder = RowDecoder()
        let foo = try! decoder.decode(Foo.self, from: row)
        
        XCTAssertEqual(foo.e, [1, 2, 3])
    }
    
    func testMultiDimensionArrayDecodable() {
        struct Foo: Decodable {
            let a: Int64?
            let e: [[Int]]
        }
        
        let insertStatement = try! restructure.prepare(query: "INSERT INTO foo (e) VALUES (:e)")
        insertStatement.bind(value: [[1, 2, 3], [4, 5, 6], [7, 8, 9]], for: "e")
        
        try! insertStatement.perform()
        
        let selectStatement = try! restructure.prepare(query: "SELECT a, e FROM foo LIMIT 1")
        
        let result = selectStatement.step()
        
        guard case let .row(row) = result else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let decoder = RowDecoder()
        let foo = try! decoder.decode(Foo.self, from: row)
        
        XCTAssertEqual(foo.e, [[1, 2, 3], [4, 5, 6], [7, 8, 9]])
    }
    
    func testDecodingEnumRawValues() {
        enum FooType: Int, Decodable {
            case one = 0
            case two = 1
        }
        
        struct Foo: Decodable {
            let id: Int64?
            let type: FooType
        }
        
        try! restructure.execute(query: "CREATE TABLE foobar (id INTEGER PRIMARY KEY AUTOINCREMENT, type INTEGER)")
        
        let insertStatement = try! restructure.prepare(query: "INSERT INTO foobar (type) VALUES (:type)")
        insertStatement.bind(value: 1, for: "type")
        
        try! insertStatement.perform()
        
        let selectStatement = try! restructure.prepare(query: "SELECT id, type FROM foobar LIMIT 1")
        
        let result = selectStatement.step()
        
        guard case let .row(row) = result else {
            XCTFail("Failed to fetch row")
            return
        }
        
        let decoder = RowDecoder()
        let foo = try! decoder.decode(Foo.self, from: row)
        
        XCTAssertEqual(foo.type, .two)
    }

}
