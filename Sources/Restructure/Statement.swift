//
//  Statement.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 2018-11-03.
//  SPDX-License-Identifier: MIT
//

import Foundation
import SQLite3

private let validBindPrefixes = [":", "$", "@"]

/// A high-level instance of a SQLite statement.
public class Statement {

    // MARK: - Properties

    let restructure: Restructure
    let statement: SQLiteStatement

    var bindables: [String:Int32] = [:]
    var columns: [String:Int32] = [:]

    var isFinalized: Bool = false

    /// The mechanism for converting an array of data in to a storable type and vice versa.
    public var arrayStrategy: ArrayStrategy = .bplist

    /// The mechanism for converting a date in to a storable type and vice versa.
    public var dateStrategy: DateStrategy = .integer

    /// All of the variables which are bindable in a statement.
    public var bindableNames: [String] {
        Array(bindables.keys)
    }

    /// All of the columns available in a statement.
    public var columnNames: [String] {
        Array(columns.keys)
    }

    // MARK: - Initialization

    required init(restructure: Restructure, query: String) throws {
        self.restructure = restructure

        // Build the underlying statement
        var statement: SQLiteStatement? = nil
        let result = sqlite3_prepare_v2(restructure.db, query, -1, &statement, nil)

        if result != SQLITE_OK {
            throw RestructureError.from(result: result)
        }

        guard let actualStatement = statement else {
            fatalError("Prepared statement successfully, but did not get a statement object")
        }

        // Store it!
        self.statement = actualStatement

        // Reload metadata about the statement
        reloadBindables()
        reloadColumns()
    }

    private func reloadBindables() {
        // Clear the current list
        bindables.removeAll()

        // Get the nunber of bindables, because they're indexed starting at 1
        let count = sqlite3_bind_parameter_count(statement)

        guard count >= 1 else {
            return
        }

        // Iterate through the bindables, capturing the name and index
        for idx in 1 ... count {
            // Ensure we have a name
            guard let bindName = sqlite3_bind_parameter_name(statement, idx) else {
                continue
            }

            // Ensure we have readable name
            guard let name = String(validatingCString: bindName) else {
                continue
            }

            // Ensure there actual is a name
            guard !name.isEmpty else {
                continue
            }

            // Ensure the name had a binding prefix
            let nameIndex = name.index(after: name.startIndex)
            let token = String(name.prefix(upTo: nameIndex))

            if !validBindPrefixes.contains(token) {
                continue
            }

            // Valid, so store it without the prefix
            let finalName = String(name.suffix(from: nameIndex))
            bindables[finalName] = idx
        }
    }

    private func reloadColumns() {
        // Clear the current list
        columns.removeAll()

        // Iterate through the columns
        let count = sqlite3_column_count(statement)
        for idx in 0 ..< count {
            let columnName = sqlite3_column_name(statement, idx)

            guard let column = columnName else {
                continue
            }

            guard let name = String(validatingCString: column) else {
                continue
            }

            columns[name] = idx
        }
    }

    deinit {
        finalize()
    }

    func finalize() {
        guard !isFinalized else {
            return
        }

        restructure.finalize(statement: self)

        isFinalized = true
    }

    /// Resets the statement for reuse. After a statement is used, it should be reset.
    public func reset() {
        let result = sqlite3_reset(statement)

        if result != SQLITE_OK {
            let error = RestructureError.from(result: result)
            fatalError("Failed to reset the statement: \(error)")
        }
    }

    // MARK: - Binding

    /// Bind a `Bindable` value to the given index.
    ///
    /// - Parameter value: The `Bindable` value to assign to the index.
    /// - Parameter at: The index to bind to.
    /// - Remark:
    ///     Bindable indexes start at 1, not 0.
    public func bind(value: Structurable?, at index: Int32) {
        precondition(index > 0)

        // If we didn't get a value, bind NULL.
        guard let bindable = value else {
            sqlite3_bind_null(statement, index)
            return
        }

        // Bind the value
        bindable.bind(to: self, at: Int(index))
    }

    /// Bind a `Bindable` value to the given index.
    ///
    /// - Parameter value: The `Bindable` value to assign to the index.
    /// - Parameter for: The name of the bindable.
    /// - Remark:
    ///     Bindable indexes start at 1, not 0.
    ///     Bindable names start with ':', '@', or '$' when the statement is prepared. They are referenced here without the prefix.
    public func bind(value: Structurable?, for key: String) {
        // Ensure we can map a parameter to an index
        guard let index = bindables[key] else {
            return
        }

        // Pass the value with the proper index
        bind(value: value, at: index)
    }

    // MARK: - Execution

    /// Evaluate a non-select statement, throwing if an error occurred.
    ///
    /// - Throws: `RestructureError` if the statement failed to execute.
    public func perform() throws {
        let result = sqlite3_step(statement)

        guard result == SQLITE_DONE else {
            throw RestructureError.from(result: result)
        }
    }

    /// Evaluate the statement, returning the result of the evaluation.
    ///
    /// - Returns: The result of the evaluation. Different statements returns different sets of results.
    /// - Remark:
    ///     For statements that return rows, you will get a series of `row`s followed by `done`.
    ///     For all other statements, you will get `done` on success.
    public func step() -> StepResult {
        let result = sqlite3_step(statement)

        switch result {
        case SQLITE_BUSY:
            return .busy
        case SQLITE_DONE:
            return .done
        case SQLITE_ERROR:
            return .error(RestructureError.from(result: result))
        case SQLITE_MISUSE:
            return .misuse
        case SQLITE_ROW:
            return .row(Row(statement: self))
        default:
            fatalError("Failed to handle step result \(result)")
        }
    }
}

extension Statement: Hashable {
    public static func == (lhs: Statement, rhs: Statement) -> Bool {
        lhs.statement == rhs.statement
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(statement)
    }
}

extension Statement: Sequence {
    public func makeIterator() -> StatementIterator {
        StatementIterator(self)
    }
}

public struct StatementIterator: IteratorProtocol {
    private let statement: Statement

    init(_ statement: Statement) {
        self.statement = statement
    }

    public mutating func next() -> Row? {
        let result = statement.step()

        switch result {
        case let .row(row):
            return row
        default:
            return nil
        }
    }
}
