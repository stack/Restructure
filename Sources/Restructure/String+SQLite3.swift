//
//  String+SQLite3.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 2018-11-03.
//  SPDX-License-Identifier: MIT
//

import Foundation
import SQLite3

extension String {
    static func from(sqliteResult: Int32) -> String? {
        guard let message = sqlite3_errstr(sqliteResult) else {
            return nil
        }

        return String(validatingCString: message)
    }
}
