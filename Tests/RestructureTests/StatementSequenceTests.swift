//
//  StatementSequenceTests.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/6/18.
//  SPDX-License-Identifier: MIT
//

import Foundation
import Testing

@testable import Restructure

struct StatementSequenceTests {

    var restructure: Restructure

    init() throws {
        restructure = try Restructure()
        try restructure.execute(query: "CREATE TABLE foo (a INTEGER PRIMARY KEY AUTOINCREMENT, b INT)")
    }

    @Test func emptySequenceResults() throws {
        let statement = try restructure.prepare(query: "SELECT a, b FROM foo")

        var count = 0

        for _ in statement {
            count += 1
        }

        #expect(count == 0)
    }

    @Test func fullSequenceResults() throws {
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

        #expect(count == 3)
    }

    @Test func partialSequenceResults() throws {
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

        #expect(count == 2)
    }
}
