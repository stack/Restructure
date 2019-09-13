//
//  AutoVacuum.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 8/12/19.
//  Copyright @ 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

/// The automatic vacuuming setting to use for the database
public enum AutoVacuum: CaseIterable, PragmaRepresentable {
    /// No auto vacuuming is done.
    case none
    /// Auto vacuuming occurs after every transaction.
    case full
    /// Auto vacuuming occurs with the `Restructure.incrementalVacuum` call.
    case incremental
    
    /// Create an `AutoVacuum` value from a database string.
    static func from(value: String) -> AutoVacuum {
        switch value.uppercased() {
        case "0", "NONE":
            return .none
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
        case .none:
            return "NONE"
        case .full:
            return "FULL"
        case .incremental:
            return "INCREMENTAL"
        }
    }
}
