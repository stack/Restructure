//
//  PragmaRepresentable.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 8/12/19.
//  Copyright @ 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

protocol PragmaRepresentable {

    static func from(string value: String) -> Self
    var pragmaString: String { get }
    
}
