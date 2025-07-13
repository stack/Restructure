//
//  StatementTests.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/4/18.
//  SPDX-License-Identifier: MIT
//

import Foundation
import Testing

@testable import Restructure

struct StatementTests {

    var restructure: Restructure

    init() throws {
        restructure = try Restructure()
        try restructure.execute(query: "CREATE TABLE foo (a INTEGER PRIMARY KEY AUTOINCREMENT, b TEXT, c REAL, d INT, e BLOB)")
    }

    // MARK: - Finalzie Tests

    @Test func finalizeStoredStatement() throws {
        var restructure: Restructure? = try Restructure()
        try restructure!.execute(query: "CREATE TABLE foo (a INTEGER PRIMARY KEY AUTOINCREMENT)")

        var statement: Statement?  = try restructure!.prepare(query: "SELECT a FROM foo")
        #expect(statement?.columnNames == ["a"]) // Simple test to hide the warning from the statement creation

        restructure?.close()
        restructure = nil

        statement = nil
    }

    // MARK: - Prepare Tests

    @Test func prepareInvalidStatement() throws {
        #expect(throws: RestructureError.self) {
            try restructure.prepare(query: "SELECT FOO BAR BAZ")
        }
    }

    @Test func prepareValidStatementWithBindables() throws {
        let statement: Statement = try restructure.prepare(query: "SELECT a, b, c FROM foo WHERE b IS :ONE OR b IS $TWO OR c IS @THREE")

        #expect(statement.bindables.count == 3)
        #expect(statement.bindables["ONE"] == 1)
        #expect(statement.bindables["TWO"] == 2)
        #expect(statement.bindables["THREE"] == 3)

        #expect(statement.columns.count == 3)
        #expect(statement.columns["a"] == 0)
        #expect(statement.columns["b"] == 1)
        #expect(statement.columns["c"] == 2)
    }

    @Test func prepareValidStatementWithoutBindables() throws {
        let statement: Statement = try restructure.prepare(query: "SELECT a, b, c FROM foo WHERE b IS ? OR b IS ? OR c IS ?")

        #expect(statement.bindables.count == 0)

        #expect(statement.columns.count == 3)
        #expect(statement.columns["a"] == 0)
        #expect(statement.columns["b"] == 1)
        #expect(statement.columns["c"] == 2)
    }

    // MARK: - Read / Write Tests

    @Test func deleteStatement() throws {
        // Insert a row
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (b, c, d, e) VALUES (:B, :C, :D, :E)")

        insertStatement.bind(value: "foo", for: "B")
        insertStatement.bind(value: 42.1, for: "C")
        insertStatement.bind(value: 42, for: "D")

        let data = Data(bytes: [0x41, 0x42, 0x43], count: 3)
        insertStatement.bind(value: data, for: "E")

        try insertStatement.perform()

        // Ensure we have 1 row
        let initialCount = try getFooCount()
        #expect(initialCount == 1)

        // Delete all rows
        let deleteStatement = try restructure.prepare(query: "DELETE FROM foo")
        try deleteStatement.perform()

        // Ensure we have 0 rows
        let deletedCount = try getFooCount()
        #expect(deletedCount == 0)
    }

    @Test func insertStatement() throws {
        // Ensure we have no rows
        let initialCount = try getFooCount()
        #expect(initialCount == 0)

        // Insert a row
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (b, c, d, e) VALUES (:B, :C, :D, :E)")

        insertStatement.bind(value: "foo", for: "B")
        insertStatement.bind(value: 42.1, for: "C")
        insertStatement.bind(value: 42, for: "D")

        let data = Data(bytes: [0x41, 0x42, 0x43 ], count: 3)
        insertStatement.bind(value: data, for: "E")

        try insertStatement.perform()

        // Ensure we have 1 row
        let updatedCount = try getFooCount()
        #expect(updatedCount == 1)

        // Get the data that was inserted
        let lastId = restructure.lastInsertedId

        let selectStatement = try restructure.prepare(query: "SELECT a, b, c, d, e FROM foo")

        let result = selectStatement.step()

        guard case let .row(row) = result else {
            Issue.record("Failed to get row result")
            return
        }

        let aString: Int64 = row["a"]
        let bString: String? = row["b"]
        let cString: Double = row["c"]
        let dString: Int = row["d"]
        let eString: Data? = row["e"]

        #expect(aString == lastId)
        #expect(bString == "foo")
        #expect(cString == 42.1)
        #expect(dString == 42)
        #expect(eString == data)

        let aInt: Int64 = row[0]
        let bInt: String? = row[1]
        let cInt: Double = row[2]
        let dInt: Int = row[3]
        let eInt: Data? = row[4]

        #expect(aInt == lastId)
        #expect(bInt == "foo")
        #expect(cInt == 42.1)
        #expect(dInt == 42)
        #expect(eInt == data)
    }

    @Test func insertNull() throws {
        // Ensure we have no rows
        let initialCount = try getFooCount()
        #expect(initialCount == 0)

        // Insert a row
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (b, c, d, e) VALUES (:B, :C, :D, :E)")

        let nullString: String? = nil
        let nullDouble: Double? = nil
        let nullInt: Int? = nil
        let nullData: Data? = nil

        insertStatement.bind(value: nullString, for: "B")
        insertStatement.bind(value: nullDouble, for: "C")
        insertStatement.bind(value: nullInt, for: "D")
        insertStatement.bind(value: nullData, for: "E")

        try insertStatement.perform()

        // Ensure we have 1 row
        let updatedCount = try getFooCount()
        #expect(updatedCount == 1)

        // Get the data that was inserted
        let lastId = restructure.lastInsertedId

        let selectStatement = try restructure.prepare(query: "SELECT a, b, c, d, e FROM foo")

        let result = selectStatement.step()

        guard case let .row(row) = result else {
            Issue.record("Failed to get row result")
            return
        }

        let aValue: Int64 = row["a"]
        let bValue: String? = row["b"]
        let cValue: Double? = row["c"]
        let dValue: Int? = row["d"]
        let eValue: Data? = row["e"]

        #expect(aValue == lastId)
        #expect(nil == bValue)
        #expect(nil == cValue)
        #expect(nil == dValue)
        #expect(nil == eValue)
    }

    @Test func updateStatement() throws {
        // Insert a row
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (b, c, d, e) VALUES (:B, :C, :D, :E)")

        insertStatement.bind(value: "foo", for: "B")
        insertStatement.bind(value: 42.1, for: "C")
        insertStatement.bind(value: 42, for: "D")

        let data = Data(bytes: [0x41, 0x42, 0x43], count: 3)
        insertStatement.bind(value: data, for: "E")

        try insertStatement.perform()

        // Ensure we have 1 row
        let initialCount = try getFooCount()
        #expect(initialCount == 1)

        // Get the data that was inserted
        let lastId = restructure.lastInsertedId

        // Update the row
        let updateStatement = try restructure.prepare(query: "UPDATE foo SET b = :B, c = :C, d = :D, e = :E where a = :A")

        updateStatement.bind(value: "bar", for: "B")
        updateStatement.bind(value: 1.1, for: "C")
        updateStatement.bind(value: 2, for: "D")
        updateStatement.bind(value: lastId, for: "A")

        let data2 = Data(bytes: [0x44, 0x45, 0x46], count: 3)
        updateStatement.bind(value: data2, for: "E")

        try updateStatement.perform()

        // Ensure there is still one row
        let updatedCount = try getFooCount()
        #expect(updatedCount == 1)

        // Ensure the updated values are set
        let selectStatement = try restructure.prepare(query: "SELECT a, b, c, d, e FROM foo WHERE a = :A")

        selectStatement.bind(value: lastId, for: "A")

        let result = selectStatement.step()

        guard case let .row(row) = result else {
            Issue.record("Failed to get row result")
            return
        }

        let aString: Int64 = row["a"]
        let bString: String? = row["b"]
        let cString: Double = row["c"]
        let dString: Int = row["d"]
        let eString: Data? = row["e"]

        #expect(aString == lastId)
        #expect(bString == "bar")
        #expect(cString == 1.1)
        #expect(dString == 2)
        #expect(eString == data2)

        let aInt: Int64 = row[0]
        let bInt: String? = row[1]
        let cInt: Double = row[2]
        let dInt: Int = row[3]
        let eInt: Data? = row[4]

        #expect(aInt == lastId)
        #expect(bInt == "bar")
        #expect(cInt == 1.1)
        #expect(dInt == 2)
        #expect(eInt == data2)
    }

    @Test func returnsMultipleRows() throws {
        // Build the insertion statement
        let insertStatement = try restructure.prepare(query: "INSERT INTO foo (b, c, d, e) VALUES (:B, :C, :D, :E)")

        // Insert 1
        insertStatement.bind(value: "one", for: "B")
        insertStatement.bind(value: 1.1, for: "C")
        insertStatement.bind(value: 1, for: "D")

        let data1 = Data(bytes: [0x01], count: 1)
        insertStatement.bind(value: data1, for: "E")

        try insertStatement.perform()

        // Insert 2
        insertStatement.reset()

        insertStatement.bind(value: "two", for: "B")
        insertStatement.bind(value: 2.2, for: "C")
        insertStatement.bind(value: 2, for: "D")

        let data2 = Data(bytes: [0x02], count: 1)
        insertStatement.bind(value: data2, for: "E")

        try insertStatement.perform()
        insertStatement.reset()

        // Insert 3
        insertStatement.reset()

        insertStatement.bind(value: "three", for: "B")
        insertStatement.bind(value: 3.3, for: "C")
        insertStatement.bind(value: 3, for: "D")

        let data3 = Data(bytes: [0x03], count: 1)
        insertStatement.bind(value: data3, for: "E")

        try insertStatement.perform()

        // Read rows
        let selectStatement = try restructure.prepare(query: "SELECT a, b, c, d, e FROM foo ORDER BY c ASC")

        // Read 1
        guard case let .row(row1) = selectStatement.step() else {
            Issue.record("Failed to read row")
            return
        }

        let b1: String? = row1[1]
        let c1: Double = row1[2]
        let d1: Int = row1[3]
        let e1: Data = try #require(row1[4])

        #expect(b1 == "one")
        #expect(c1 == 1.1)
        #expect(d1 == 1)
        #expect(e1.count == 1)
        #expect(e1[0] == 0x01)

        // Read 2
        guard case let .row(row2) = selectStatement.step() else {
            Issue.record("Failed to read row")
            return
        }

        let b2: String? = row2[1]
        let c2: Double = row2[2]
        let d2: Int = row2[3]
        let e2: Data = try #require(row2[4])

        #expect(b2 == "two")
        #expect(c2 == 2.2)
        #expect(d2 == 2)
        #expect(e2.count == 1)
        #expect(e2[0] == 0x02)

        // Read 3
        guard case let .row(row3) = selectStatement.step() else {
            Issue.record("Failed to read row")
            return
        }

        let b3: String? = row3[1]
        let c3: Double = row3[2]
        let d3: Int = row3[3]
        let e3: Data = try #require(row3[4])

        #expect(b3 == "three")
        #expect(c3 == 3.3)
        #expect(d3 == 3)
        #expect(e3.count == 1)
        #expect(e3[0] == 0x03)
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
