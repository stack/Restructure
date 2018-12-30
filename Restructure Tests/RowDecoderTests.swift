//
//  RowDecoderTests.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/30/18.
//  Copyright © 2018 Stephen H. Gerstacker. All rights reserved.
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

    func testSimpleDecodable() throws {
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

        var result = insertStatement.step()
        
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
        
        let decoder = RowDecoder()
        let foo = try decoder.decode(Foo.self, from: row)
        
        XCTAssertEqual(foo.b, "1")
        XCTAssertEqual(foo.c, 2.0)
        XCTAssertEqual(foo.d, 3)
        XCTAssertEqual(foo.e, Data(bytes: [0x4, 0x5, 0x6], count: 3))
    }
    
    func testArrayDecodable() throws {
        struct Foo: Decodable {
            let a: Int64?
            let e: [Int]
        }
        
        let insertStatement = try! restructure.prepare(query: "INSERT INTO foo (e) VALUES (:e)")
        insertStatement.bind(value: [1, 2, 3], for: "e")
        
        var result = insertStatement.step()
        
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
        
        let decoder = RowDecoder()
        let foo = try decoder.decode(Foo.self, from: row)
        
        XCTAssertEqual(foo.e, [1, 2, 3])
    }
    
    func testMultiDimensionArrayDecodable() throws {
        struct Foo: Decodable {
            let a: Int64?
            let e: [[Int]]
        }
        
        let insertStatement = try! restructure.prepare(query: "INSERT INTO foo (e) VALUES (:e)")
        insertStatement.bind(value: [[1, 2, 3], [4, 5, 6], [7, 8, 9]], for: "e")
        
        var result = insertStatement.step()
        
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
        
        let decoder = RowDecoder()
        let foo = try decoder.decode(Foo.self, from: row)
        
        XCTAssertEqual(foo.e, [[1, 2, 3], [4, 5, 6], [7, 8, 9]])
    }

}
