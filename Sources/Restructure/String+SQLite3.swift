//
//  String+SQLite3.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/3/18.
//  Copyright @ 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import SQLite3

internal extension String {
    static func from(sqliteResult: Int32) -> String? {
        if let message = sqlite3_errstr(sqliteResult) {
            return String(validatingUTF8: message)
        }
        
        return nil
    }
}
