//
//  RestructureTests.swift
//  Restructure macOS Tests
//
//  Created by Stephen H. Gerstacker on 11/3/18.
//  SPDX-License-Identifier: MIT
//

import Foundation
import Testing

@testable import Restructure

struct RestructureTests {

    let restructure: Restructure

    init() throws {
        restructure = try Restructure()
    }

    // MARK: - User Version Tests

    @Test func userVersionStartsAtZero() throws {
        #expect(restructure.userVersion == 0)
    }

    @Test func userVersionIsUpdatable() throws {
        restructure.userVersion = 42
        #expect(restructure.userVersion == 42)
    }

    // MARK: - Execution Tests

    @Test func executingInvalidQuery() throws {
        #expect(throws: RestructureError.self) {
            try restructure.execute(query: "FOO BAR BAZ")
        }
    }

    @Test func executingValidQuery() throws {
        try restructure.execute(query: "CREATE TABLE foo (a INT)")
    }

    @Test func executingMultipleValidQueries() throws {
        try restructure.execute(query: "CREATE TABLE foo (a INT); INSERT INTO foo (a) VALUES(42);")

        let statement = try restructure.prepare(query: "SELECT a FROM foo LIMIT 1")
        let result = statement.step()

        guard case .row(let row) = result else {
            Issue.record("Failed to get a row")
            return
        }

        #expect(row["a"] == 42)
    }

    // MARK: - Last Inserted ID Tests

    @Test func lastInsertedIdReturnsZeroWithNoInserts() throws {
        #expect(restructure.lastInsertedId == 0)
    }

    @Test func lastInsertedIdReturnsNonZeroWithInserts() throws {
        try restructure.execute(query: "CREATE TABLE foo (a INTEGER PRIMARY KEY AUTOINCREMENT, b INT); INSERT INTO foo (b) VALUES(42);")
        #expect(restructure.lastInsertedId > 0)
    }

    // MARK: - SQLite Version Tests

    @Test func sqliteVersionExists() throws {
        let version = restructure.sqliteVersion
        #expect(!version.isEmpty)
    }

    // MARK: - Migration Tests

    @Test func migrationNeedDetectable() throws {
        #expect(!restructure.needsMigration(targetVersion: 0))
        #expect(restructure.needsMigration(targetVersion: 1))

        restructure.userVersion = 42

        #expect(!restructure.needsMigration(targetVersion: 40))
        #expect(!restructure.needsMigration(targetVersion: 41))
        #expect(!restructure.needsMigration(targetVersion: 42))
        #expect(restructure.needsMigration(targetVersion: 43))
        #expect(restructure.needsMigration(targetVersion: 44))
    }

    @Test func migrationWorksInitially() throws {
        #expect(restructure.userVersion == 0)

        try restructure.migrate(version: 1) {
            try $0.execute(query: "CREATE TABLE foo (A INT)")
        }

        #expect(restructure.userVersion == 1)
    }

    @Test func migrationWorksSerially() throws {
        #expect(restructure.userVersion == 0)

        try restructure.migrate(version: 1) {
            try $0.execute(query: "CREATE TABLE foo (A INT)")
        }

        try restructure.migrate(version: 2) {
            try $0.execute(query: "CREATE TABLE bar (A INT)")
        }

        #expect(restructure.userVersion == 2)
    }

    @Test func migrationFailsOutOfSequence() throws {
        #expect(restructure.userVersion == 0)

        #expect(throws: RestructureError.self) {
            try restructure.migrate(version: 2) {
                try $0.execute(query: "CREATE TABLE foo (A INT)")
            }
        }

        #expect(restructure.userVersion == 0)
    }

    @Test func migrationSkipsIfDone() throws {
        #expect(restructure.userVersion == 0)

        try restructure.migrate(version: 1) {
            try $0.execute(query: "CREATE TABLE foo (A INT)")
        }

        #expect(try getFooCount() == 0)

        try restructure.migrate(version: 1) {
            try $0.execute(query: "INSERT INTO foo (a) VALUES (1)")
        }

        #expect(try getFooCount() == 0)
    }

    // MARK: - Custom Function Tests

    @Test func upperFunctionWithStandardString() throws {
        // Create a table that stores strings
        try restructure.execute(query: "CREATE TABLE foo (id INTEGER PRIMARY KEY, value TEXT)")

        // Insert some test data
        try restructure.execute(query: "INSERT INTO foo (value) VALUES ('Hello')")
        let id = restructure.lastInsertedId

        // Fetch the data back out, with upper case values
        let fetchStatement = try restructure.prepare(query: "SELECT UPPER(value) AS value FROM foo WHERE id = :id")
        fetchStatement.bind(value: id, for: "id")

        guard case .row(let row) = fetchStatement.step() else {
            Issue.record("Failed to get inserted data")
            return
        }

        #expect(row["value"] == "HELLO")
    }

    @Test func upperFunctionWithComplexString() throws {
        // Create a table that stores strings
        try restructure.execute(query: "CREATE TABLE foo (id INTEGER PRIMARY KEY, value TEXT)")

        // Insert some test data
        try restructure.execute(query: "INSERT INTO foo (value) VALUES ('👋🏻 Hello 👋🏼')")
        let id = restructure.lastInsertedId

        // Fetch the data back out, with upper case values
        let fetchStatement = try restructure.prepare(query: "SELECT UPPER(value) AS value FROM foo WHERE id = :id")
        fetchStatement.bind(value: id, for: "id")

        guard case .row(let row) = fetchStatement.step() else {
            Issue.record("Failed to get inserted data")
            return
        }

        #expect(row["value"] == "👋🏻 HELLO 👋🏼")
    }

    @Test func upperFunctionWithUnicodeString() throws {
        // Create a table that stores strings
        try restructure.execute(query: "CREATE TABLE foo (id INTEGER PRIMARY KEY, value TEXT)")

        // Insert some test data
        try restructure.execute(query: "INSERT INTO foo (value) VALUES ('exámple óóßChloë')")
        let id = restructure.lastInsertedId

        // Fetch the data back out, with upper case values
        let fetchStatement = try restructure.prepare(query: "SELECT UPPER(value) AS value FROM foo WHERE id = :id")
        fetchStatement.bind(value: id, for: "id")

        guard case .row(let row) = fetchStatement.step() else {
            Issue.record("Failed to get inserted data")
            return
        }

        #expect(row["value"] == "EXÁMPLE ÓÓSSCHLOË")
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
