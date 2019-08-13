//
//  JournalMode.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 8/12/19.
//  Copyright @ 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

/// The journaling mode used by the database.
public enum JournalMode: CaseIterable, PragmaRepresentable {
    /// The rollback journal is deleted after a transaction.
    case delete
    /// The rollback journal is truncated after a transaction.
    case truncate
    /// The rollback journal is presisted and blanked after a transaction.
    case persist
    /// The rollback journal exists in-memory. This is the default for an in-memory database.
    case memory
    /// A write-ahead log is used as opposed to a rollback journal. This is the default for a file-backed database.
    case wal
    /// No rollback journal is used.
    case off
    
    /// Create a `JournalMode` from a SQlite representation
    static func from(string value: String) -> JournalMode {
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
        case "OFF":
            return .off
        default:
            fatalError("Unsupported JournalMode string: \(value)")
        }
    }
    
    /// Get a SQlite compatible string representation of the `JournalMode`.
    var pragmaString: String {
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
        case .off:
            return "OFF"
        }
    }
}
