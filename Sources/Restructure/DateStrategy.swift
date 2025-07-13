//
//  DateStrategy.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 2018-11-04.
//  SPDX-License-Identifier: MIT
//

import Foundation

/// The strategy used when reading and writing dates
public enum DateStrategy {
    /// Dates are stored as seconds from January 1, 1970
    case integer
    /// Dates are stored in Julian days since January 1, 4713 BC
    case real
    /// Dates are stored in ISO 8601 format
    case text
}
