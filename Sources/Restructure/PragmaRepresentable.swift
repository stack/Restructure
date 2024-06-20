//
//  PragmaRepresentable.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 8/12/19.
//  SPDX-License-Identifier: MIT
//

import Foundation

/// A simple protocol to transition between SQlite pragma values and their representation in the program.
protocol PragmaRepresentable {
    associatedtype PragmaType: Structurable

    /// Convert a raw SQlite value to their representable type.
    static func from(value: PragmaType) -> Self
    /// Convert the representable type to the SQlite value.
    var pragmaValue: PragmaType { get }
    
}

extension Int: PragmaRepresentable {
    
    /// Integer conversion from an SQlite value to an `Int`.
    static func from(value: Int) -> Int {
        return value
    }
    
    /// Integer conversion from an `Int` to a SQlite value.
    var pragmaValue: Int {
        return self
    }
}
