//
//  AutoVacuum.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 8/12/19.
//  Copyright @ 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

public enum AutoVacuum: CaseIterable, PragmaRepresentable{
    case none
    case full
    case incremental
    
    static func from(string value: String) -> AutoVacuum {
        switch value.uppercased() {
        case "0", "NONE":
            return .none
        case "1", "FULL":
            return .full
        case "2", "INCREMENTAL":
            return .incremental
        default:
            fatalError("Unhandled auto_vacuum string: \(value)")
        }
    }
    
    var pragmaString: String {
        switch self {
        case .none:
            return "NONE"
        case .full:
            return "FULL"
        case .incremental:
            return "INCREMENTAL"
        }
    }
}
