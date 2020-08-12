//
//  Date+Julian.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/4/18.
//  Copyright @ 2020 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

fileprivate let JD_JAN_1_1970_0000GMT = 2440587.5

extension Date {
    /// Initialize a Date with the given Julian dates since January 1, 4713 BC GMT
    init(julianDays: Double) {
        self.init(timeIntervalSince1970: (julianDays - JD_JAN_1_1970_0000GMT) * 86400)
    }
    
    /// Get the Julian days since January 1, 4713 BC GMT
    var julianDays: Double {
        return JD_JAN_1_1970_0000GMT + (timeIntervalSince1970 / 86400)
    }
}
