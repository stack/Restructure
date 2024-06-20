//
//  ArrayStrategy.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/10/18.
//  SPDX-License-Identifier: MIT
//

import Foundation

/// The strategy used when reading or writing arrays.
public enum ArrayStrategy {
    /// The array is encoded as a binary plist.
    case bplist
    
    /// The array is encoded as JSON.
    case json
}
