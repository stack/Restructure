//
//  RestructureError.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/3/18.
//  Copyright © 2018 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import SQLite3

public enum StructureError: Error {
    case error(String)
    case internalError(Int32, String)
    
    internal static func from(result: Int32) -> StructureError {
        if let message = String.from(sqliteResult: result) {
            return internalError(result, message)
        } else {
            return internalError(0, "Unknown error")
        }
    }
}
