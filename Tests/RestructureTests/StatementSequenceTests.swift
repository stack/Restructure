//
//  StatementSequenceTests.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/6/18.
//  SPDX-License-Identifier: MIT
//

import XCTest
@testable import Restructure

class StatementSequenceTests: XCTestCase {

    var restructure: Restructure!
    
    override func setUpWithError() throws {
        restructure = try Restructure()
        try restructure.execute(query: "CREATE TABLE foo (a INTEGER PRIMARY KEY AUTOINCREMENT, b INT)")
    }
    
    override func tearDown() {
        restructure.close()
        restructure = nil
    }
    
    func testEmptySequenceResults() throws {
        let statement = try restructure.prepare(query: "SELECT a, b FROM foo")
        
        var count = 0
        
        for _ in statement {
            count += 1
        }
        
        XCTAssertEqual(count, 0)
    }
    
    func testFullSequenceResults() throws {
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (b) VALUES (:b)")
        
        insertStatement.bind(value: 1, for: "b")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: 2, for: "b")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: 3, for: "b")
        _ = insertStatement.step()
        
        let statement = try restructure.prepare(query: "SELECT a, b FROM foo")
        
        var count = 0
        
        for _ in statement {
            count += 1
        }
        
        XCTAssertEqual(count, 3)
    }
    
    func testPartialSequenceResults() throws {
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (b) VALUES (:b)")
        
        insertStatement.bind(value: 1, for: "b")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: 2, for: "b")
        _ = insertStatement.step()
        
        insertStatement.reset()
        
        insertStatement.bind(value: 2, for: "b")
        _ = insertStatement.step()
        
        let statement = try restructure.prepare(query: "SELECT a, b FROM foo WHERE b = :b")
        statement.bind(value: 2, for: "b")
        
        var count = 0
        
        for _ in statement {
            count += 1
        }
        
        XCTAssertEqual(count, 2)
    }

}
