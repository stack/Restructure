//
//  Bindable.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/3/18.
//  Copyright © 2018 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

/// An empty protocol to define which data type can be bound to
public protocol Structurable { }

extension Bool: Structurable { }

extension Int: Structurable { }
extension Int8: Structurable { }
extension Int16: Structurable { }
extension Int32: Structurable { }
extension Int64: Structurable { }

extension UInt: Structurable { }
extension UInt8: Structurable { }
extension UInt16: Structurable { }
extension UInt32: Structurable { }

extension Float: Structurable { }
extension Double: Structurable { }

extension Data: Structurable { }
extension Date: Structurable { }
extension String: Structurable { }
