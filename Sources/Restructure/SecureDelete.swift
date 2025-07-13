//
//  SecureDelete.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 2019-08-12.
//  SPDX-License-Identifier: MIT
//

import Foundation

/// The delete mode used when removing data.
public enum SecureDelete: CaseIterable, PragmaRepresentable {
    /// Deleted data is zeroed only when it exists on the filesystem
    case fast
    /// Deleted data is not zeroed
    case off
    /// Deleted data is zeroed
    case on

    static func from(value: String) -> Self {
        switch value.uppercased() {
        case "1":
            return .on
        case "0":
            return .off
        case "2":
            return .fast
        default:
            fatalError("Unsupported SecureDelete string: \(value)")
        }
    }

    var pragmaValue: String {
        switch self {
        case .on:
            return "1"
        case .off:
            return "0"
        case .fast:
            return "FAST"
        }
    }
}
