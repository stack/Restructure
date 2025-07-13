//
//  JournalMode.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 2019-08-12.
//  SPDX-License-Identifier: MIT
//

import Foundation

/// The journaling mode used by the database.
public enum JournalMode: CaseIterable, PragmaRepresentable, Sendable {
    /// The rollback journal is deleted after a transaction.
    case delete
    /// The rollback journal exists in-memory. This is the default for an in-memory database.
    case memory
    /// The rollback journal is presisted and blanked after a transaction.
    case persist
    /// The rollback journal is truncated after a transaction.
    case truncate
    /// A write-ahead log is used as opposed to a rollback journal. This is the default for a file-backed database.
    case wal

    /// Create a `JournalMode` from a SQlite representation
    static func from(value: String) -> Self {
        switch value.uppercased() {
        case "DELETE":
            return .delete
        case "TRUNCATE":
            return .truncate
        case "PERSIST":
            return .persist
        case "MEMORY":
            return .memory
        case "WAL":
            return .wal
        default:
            fatalError("Unsupported JournalMode string: \(value)")
        }
    }

    /// Get a SQlite compatible string representation of the `JournalMode`.
    var pragmaValue: String {
        switch self {
        case .delete:
            return "DELETE"
        case .truncate:
            return "TRUNCATE"
        case .persist:
            return "PERSIST"
        case .memory:
            return "MEMORY"
        case .wal:
            return "WAL"
        }
    }
}
