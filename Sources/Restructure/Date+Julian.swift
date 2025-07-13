//
//  Date+Julian.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 2018-11-04.
//  SPDX-License-Identifier: MIT
//

import Foundation

// swiftlint:disable:next identifier_name
private let JD_JAN_1_1970_0000GMT = 2_440_587.5

extension Date {
    /// Initialize a Date with the given Julian dates since January 1, 4713 BC GMT
    init(julianDays: Double) {
        self.init(timeIntervalSince1970: (julianDays - JD_JAN_1_1970_0000GMT) * 86_400)
    }

    /// Get the Julian days since January 1, 4713 BC GMT
    var julianDays: Double {
        JD_JAN_1_1970_0000GMT + (timeIntervalSince1970 / 86_400)
    }
}
