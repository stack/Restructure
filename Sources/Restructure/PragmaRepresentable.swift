//
//  PragmaRepresentable.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 8/12/19.
//  Copyright @ 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

protocol PragmaRepresentable {
    associatedtype PragmaType: Structurable

    static func from(value: PragmaType) -> Self
    var pragmaValue: PragmaType { get }
    
}

extension Int: PragmaRepresentable {
    
    static func from(value: Int) -> Int {
        return value
    }
    
    var pragmaValue: Int {
        return self
    }
}
