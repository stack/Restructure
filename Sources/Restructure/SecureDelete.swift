//
//  SecureDelete.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 8/12/19.
//  Copyright @ 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

/// The delete mode used when removing data.
public enum SecureDelete: CaseIterable, PragmaRepresentable {
    /// Deleted data is zeroed
    case on
    /// Deleted data is not zeroed
    case off
    /// Deleted data is zeroed only when it exists on the filesystem
    case fast
    
    static func from(value: String) -> SecureDelete {
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
