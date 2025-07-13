//
//  RestructureError.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 2018-11-03.
//  SPDX-License-Identifier: MIT
//

import Foundation
import SQLite3

/// The error container for all Resturcture errors
public enum RestructureError: Error {
    /// An error unrelated to SQLite
    case error(String)

    /// An error related to SQLite
    case internalError(Int32, String)

    static func from(result: Int32) -> Self {
        if let message = String.from(sqliteResult: result) {
            return internalError(result, message)
        } else {
            return internalError(0, "Unknown error")
        }
    }
}
