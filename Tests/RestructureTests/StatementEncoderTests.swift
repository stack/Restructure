//
//  StatementEncoderTests.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/10/18.
//  SPDX-License-Identifier: MIT
//

import Foundation
import Testing

@testable import Restructure

struct StatementEncoderTests {

    var restructure: Restructure

    init() throws {
        restructure = try Restructure()
        try restructure.execute(query: "CREATE TABLE foo (a INTEGER PRIMARY KEY AUTOINCREMENT, b TEXT, c REAL, d INT, e BLOB)")
    }

    @Test func simpleEncodable() throws {
        struct Foo: Encodable {
            let a: Int64?
            let b: String
            let c: Double
            let d: Int
            let e: Data
        }

        let statement = try restructure.prepare(query: "INSERT INTO foo (b, c, d, e) VALUES (:b, :c, :d, :e)")

        let foo = Foo(a: nil, b: "1", c: 2.0, d: 3, e: Data(bytes: [0x4, 0x5, 0x6], count: 3))

        let encoder = StatementEncoder()
        try encoder.encode(foo, to: statement)

        var result = statement.step()

        guard case .done = result else {
            Issue.record("Failed to insert data")
            return
        }

        let selectStatement = try restructure.prepare(query: "SELECT a, b, c, d, e FROM foo LIMIT 1")

        result = selectStatement.step()

        guard case let .row(row) = result else {
            Issue.record("Failed to fetch row")
            return
        }

        #expect(row["b"] == "1")
        #expect(row["c"] == 2.0)
        #expect(row["d"] == 3)
        #expect(row["e"] == Data(bytes: [0x4, 0x5, 0x6], count: 3))
    }

    @Test func emojiStringEncodable() throws {
        struct Foo: Encodable {
            let a: Int64?
            let b: String
        }

        let statement = try restructure.prepare(query: "INSERT INTO foo (b) VALUES (:b)")

        let foo = Foo(a: nil, b: "👋🏻 HELLO 👋🏼")

        let encoder = StatementEncoder()
        try encoder.encode(foo, to: statement)

        var result = statement.step()

        guard case .done = result else {
            Issue.record("Failed to insert data")
            return
        }

        let selectStatement = try restructure.prepare(query: "SELECT a, b FROM foo LIMIT 1")

        result = selectStatement.step()

        guard case let .row(row) = result else {
            Issue.record("Failed to fetch row")
            return
        }

        #expect(row["b"] == "👋🏻 HELLO 👋🏼")
    }

    @Test func unicodeStringEncodable() throws {
        struct Foo: Encodable {
            let a: Int64?
            let b: String
        }

        let statement = try restructure.prepare(query: "INSERT INTO foo (b) VALUES (:b)")

        let foo = Foo(a: nil, b: "exámple óóßChloë")

        let encoder = StatementEncoder()
        try encoder.encode(foo, to: statement)

        var result = statement.step()

        guard case .done = result else {
            Issue.record("Failed to insert data")
            return
        }

        let selectStatement = try restructure.prepare(query: "SELECT a, b FROM foo LIMIT 1")

        result = selectStatement.step()

        guard case let .row(row) = result else {
            Issue.record("Failed to fetch row")
            return
        }

        #expect(row["b"] == "exámple óóßChloë")
    }

    @Test func arrayEncodable() throws {
        struct Foo: Encodable {
            let a: Int64?
            let e: [Int]
        }

        let statement = try restructure.prepare(query: "INSERT INTO foo (e) VALUES (:e)")

        let foo = Foo(a: nil, e: [1, 2, 3])

        let encoder = StatementEncoder()
        try encoder.encode(foo, to: statement)

        var result = statement.step()

        guard case .done = result else {
            Issue.record("Failed to insert data")
            return
        }

        let selectStatement = try restructure.prepare(query: "SELECT a, e FROM foo LIMIT 1")

        result = selectStatement.step()

        guard case let .row(row) = result else {
            Issue.record("Failed to fetch row")
            return
        }

        #expect(row["e"] == [1, 2, 3])
    }

    @Test func multiArrayEncodable() throws {
        struct Foo: Encodable {
            let a: Int64?
            let e: [[Int]]
        }

        let statement = try restructure.prepare(query: "INSERT INTO foo (e) VALUES (:e)")

        let foo = Foo(a: nil, e: [[1, 2, 3]])

        let encoder = StatementEncoder()
        try encoder.encode(foo, to: statement)

        var result = statement.step()

        guard case .done = result else {
            Issue.record("Failed to insert data")
            return
        }

        let selectStatement = try restructure.prepare(query: "SELECT a, e FROM foo LIMIT 1")

        result = selectStatement.step()

        guard case let .row(row) = result else {
            Issue.record("Failed to fetch row")
            return
        }

        #expect(row["e"] == [[1, 2, 3]])
    }

    @Test func encodingEnumRawValues() throws {
        enum FooType: Int, Encodable {
            case one = 0
            case two = 1
        }

        struct Foo: Encodable {
            let id: Int64?
            let type: FooType
        }

        try restructure.execute(query: "CREATE TABLE foobar (id INTEGER PRIMARY KEY AUTOINCREMENT, type INTEGER)")

        let statement = try restructure.prepare(query: "INSERT INTO foobar (type) VALUES (:type)")

        let foo = Foo(id: nil, type: .two)

        let encoder = StatementEncoder()
        try encoder.encode(foo, to: statement)

        var result = statement.step()

        guard case .done = result else {
            Issue.record("Failed to insert data")
            return
        }

        let selectStatement = try restructure.prepare(query: "SELECT id, type FROM foobar LIMIT 1")

        result = selectStatement.step()

        guard case let .row(row) = result else {
            Issue.record("Failed to fetch row")
            return
        }

        #expect(row["type"] == 1)
    }

    @Test func encodingNil() throws {
        struct Foo: Encodable {
            let id: Int64
            let name: String?
            let value: Int?
        }

        try restructure.execute(query: "CREATE TABLE foobar (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NULL, value INTEGER NULL)")

        let insertStatement = try restructure.prepare(query: "INSERT INTO foobar (id, name, value) VALUES (:id, :name, :value)")
        let encoder = StatementEncoder()

        let foo1 = Foo(id: 1, name: "Hello", value: 42)

        insertStatement.reset()
        try encoder.encode(foo1, to: insertStatement)

        guard case .done = insertStatement.step() else {
            Issue.record("Failed to insert first row")
            return
        }

        let foo2 = Foo(id: 2, name: nil, value: 42)

        insertStatement.reset()
        try encoder.encode(foo2, to: insertStatement)

        guard case .done = insertStatement.step() else {
            Issue.record("Failed to insert second row")
            return
        }

        let foo3 = Foo(id: 3, name: "Hello", value: nil)

        insertStatement.reset()
        try encoder.encode(foo3, to: insertStatement)

        guard case .done = insertStatement.step() else {
            Issue.record("Failed to insert second row")
            return
        }

        let fetchAllStatement = try restructure.prepare(query: "SELECT COUNT(id) AS count FROM foobar")

        guard case .row(let allRow) = fetchAllStatement.step(), let allCount: Int = allRow["count"] else {
            Issue.record("Failed to get all count")
            return
        }

        let fetchNilNameStatement = try restructure.prepare(query: "SELECT COUNT(id) AS count FROM foobar WHERE name IS NULL")

        guard case .row(let nilNameRow) = fetchNilNameStatement.step(), let nilNameCount: Int = nilNameRow["count"] else {
            Issue.record("Failed to get nil name count")
            return
        }

        let fetchNilValueStatement = try restructure.prepare(query: "SELECT COUNT(id) AS count FROM foobar WHERE value IS NULL")

        guard case .row(let nilValueRow) = fetchNilValueStatement.step(), let nilValueCount: Int = nilValueRow["count"] else {
            Issue.record("Failed to get nil value count")
            return
        }

        #expect(allCount == 3)
        #expect(nilNameCount == 1)
        #expect(nilValueCount == 1)
    }
}
