//
//  AutoVacuum.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 2019-08-12.
//  SPDX-License-Identifier: MIT
//

import Foundation

/// The automatic vacuuming setting to use for the database
public enum AutoVacuum: CaseIterable, PragmaRepresentable, Sendable {

    /// Auto vacuuming occurs after every transaction.
    case full
    /// Auto vacuuming occurs with the `Restructure.incrementalVacuum` call.
    case incremental
    /// No auto vacuuming is done.
    case noVacuuming

    /// Create an `AutoVacuum` value from a database string.
    static func from(value: String) -> Self {
        switch value.uppercased() {
        case "0", "NONE":
            return .noVacuuming
        case "1", "FULL":
            return .full
        case "2", "INCREMENTAL":
            return .incremental
        default:
            fatalError("Unhandled auto_vacuum string: \(value)")
        }
    }

    /// Create a database string representation of an `AutoVacuum` value.
    var pragmaValue: String {
        switch self {
        case .noVacuuming:
            return "NONE"
        case .full:
            return "FULL"
        case .incremental:
            return "INCREMENTAL"
        }
    }
}
